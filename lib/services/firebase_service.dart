import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      await _remoteConfig.setDefaults({
        'min_version': '1.0.0',
      });

      await _remoteConfig.fetchAndActivate();
      _initialized = true;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack,
          reason: 'Failed to initialize Remote Config');
      _initialized = true; // Continue even if fetch fails
    }
  }

  /// Checks if a force update is needed based on min_version remote config.
  /// Returns true if the current app version is less than the min_version.
  Future<bool> isForceUpdateRequired() async {
    try {
      final minVersionStr = _remoteConfig.getString('min_version');
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionStr = packageInfo.version;

      return _compareVersions(currentVersionStr, minVersionStr) < 0;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack,
          reason: 'Failed to check force update');
      return false; // Don't block user if check fails
    }
  }

  /// Compares two version strings (e.g., "11.12.21" vs "10.2.3").
  /// Returns negative if v1 < v2, 0 if equal, positive if v1 > v2.
  int _compareVersions(String v1, String v2) {
    List<int> parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad to the same length
    while (parts1.length < parts2.length) {
      parts1.add(0);
    }
    while (parts2.length < parts1.length) {
      parts2.add(0);
    }

    for (int i = 0; i < parts1.length; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }

    return 0;
  }

  String getMinVersion() {
    return _remoteConfig.getString('min_version');
  }

  void logError(dynamic error, StackTrace? stack, {String? reason}) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: reason ?? 'Unknown error',
    );
  }

  void logMessage(String message) {
    FirebaseCrashlytics.instance.log(message);
  }

  void setUserIdentifier(String userId) {
    FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }
}
