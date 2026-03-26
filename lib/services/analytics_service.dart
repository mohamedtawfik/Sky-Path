import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ─── App Lifecycle ───

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  // ─── Level Events ───

  Future<void> logLevelStart(int levelId, String levelName) async {
    await _analytics.logLevelStart(levelName: '${levelId}_$levelName');
    await _analytics.logEvent(
      name: 'level_start',
      parameters: {
        'level_id': levelId,
        'level_name': levelName,
      },
    );
  }

  Future<void> logLevelEnd(
    int levelId,
    String levelName, {
    required int score,
    required int stars,
    required bool success,
  }) async {
    await _analytics.logLevelEnd(
      levelName: '${levelId}_$levelName',
      success: success ? 1 : 0,
    );
    await _analytics.logEvent(
      name: 'level_end',
      parameters: {
        'level_id': levelId,
        'level_name': levelName,
        'score': score,
        'stars': stars,
        'success': success ? 1 : 0,
      },
    );
  }

  Future<void> logLevelRetry(int levelId, String levelName) async {
    await _analytics.logEvent(
      name: 'level_retry',
      parameters: {
        'level_id': levelId,
        'level_name': levelName,
      },
    );
  }

  // ─── In-App Purchase Events ───

  Future<void> logPurchasePromptShown() async {
    await _analytics.logEvent(name: 'purchase_prompt_shown');
  }

  Future<void> logPurchaseStarted() async {
    await _analytics.logEvent(name: 'purchase_started');
  }

  Future<void> logPurchaseCompleted(String productId, double price) async {
    await _analytics.logPurchase(
      currency: 'USD',
      value: price,
    );
    await _analytics.logEvent(
      name: 'premium_unlocked',
      parameters: {
        'product_id': productId,
      },
    );
  }

  Future<void> logPurchaseCancelled() async {
    await _analytics.logEvent(name: 'purchase_cancelled');
  }

  Future<void> logPurchaseError(String error) async {
    await _analytics.logEvent(
      name: 'purchase_error',
      parameters: {'error': error},
    );
  }

  Future<void> logRestorePurchases(bool success) async {
    await _analytics.logEvent(
      name: 'restore_purchases',
      parameters: {'success': success ? 1 : 0},
    );
  }

  // ─── Gameplay Events ───

  Future<void> logGameOver(int levelId, int score, int maxHeight) async {
    await _analytics.logEvent(
      name: 'game_over',
      parameters: {
        'level_id': levelId,
        'score': score,
        'max_height': maxHeight,
      },
    );
  }

  Future<void> logNewHighScore(int levelId, int score) async {
    await _analytics.logEvent(
      name: 'new_high_score',
      parameters: {
        'level_id': levelId,
        'score': score,
      },
    );
  }

  Future<void> logCoinsCollected(int levelId, int coins) async {
    await _analytics.logEvent(
      name: 'coins_collected',
      parameters: {
        'level_id': levelId,
        'coins': coins,
      },
    );
  }

  // ─── Navigation Events ───

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ─── Settings Events ───

  Future<void> logSettingChanged(String setting, bool value) async {
    await _analytics.logEvent(
      name: 'setting_changed',
      parameters: {
        'setting': setting,
        'value': value ? 1 : 0,
      },
    );
  }

  // ─── Force Update ───

  Future<void> logForceUpdateShown(String minVersion) async {
    await _analytics.logEvent(
      name: 'force_update_shown',
      parameters: {
        'min_version': minVersion,
      },
    );
  }

  Future<void> logForceUpdateClicked() async {
    await _analytics.logEvent(name: 'force_update_clicked');
  }
}
