import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // High scores per level
  Future<void> saveHighScore(int levelId, int score) async {
    int currentHigh = getHighScore(levelId);
    if (score > currentHigh) {
      await _prefs.setInt('high_score_$levelId', score);
    }
  }

  int getHighScore(int levelId) {
    return _prefs.getInt('high_score_$levelId') ?? 0;
  }

  // Stars per level
  Future<void> saveStars(int levelId, int stars) async {
    int currentStars = getStars(levelId);
    if (stars > currentStars) {
      await _prefs.setInt('stars_$levelId', stars);
    }
  }

  int getStars(int levelId) {
    return _prefs.getInt('stars_$levelId') ?? 0;
  }

  int getTotalStars() {
    int total = 0;
    for (int i = 1; i <= 10; i++) {
      total += getStars(i);
    }
    return total;
  }

  // Level completion
  Future<void> setLevelCompleted(int levelId) async {
    await _prefs.setBool('level_completed_$levelId', true);
  }

  bool isLevelCompleted(int levelId) {
    return _prefs.getBool('level_completed_$levelId') ?? false;
  }

  int getLastUnlockedLevel() {
    for (int i = 10; i >= 1; i--) {
      if (isLevelCompleted(i)) return i + 1;
    }
    return 1;
  }

  // Sound settings
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool('sound_enabled', enabled);
  }

  bool isSoundEnabled() {
    return _prefs.getBool('sound_enabled') ?? true;
  }

  // Music settings
  Future<void> setMusicEnabled(bool enabled) async {
    await _prefs.setBool('music_enabled', enabled);
  }

  bool isMusicEnabled() {
    return _prefs.getBool('music_enabled') ?? true;
  }

  // Total coins
  Future<void> addCoins(int amount) async {
    int current = getTotalCoins();
    await _prefs.setInt('total_coins', current + amount);
  }

  int getTotalCoins() {
    return _prefs.getInt('total_coins') ?? 0;
  }

  // First launch
  bool isFirstLaunch() {
    return _prefs.getBool('first_launch') ?? true;
  }

  Future<void> setFirstLaunchDone() async {
    await _prefs.setBool('first_launch', false);
  }
}
