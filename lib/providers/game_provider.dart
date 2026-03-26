import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/iap_service.dart';
import '../services/audio_service.dart';
import '../game/levels_data.dart';

class GameProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final IAPService _iapService = IAPService();

  bool _isPremium = false;
  int _totalStars = 0;
  int _totalCoins = 0;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  Locale? _currentLocale;

  bool get isPremium => _isPremium;
  int get totalStars => _totalStars;
  int get totalCoins => _totalCoins;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  Locale? get currentLocale => _currentLocale;

  Future<void> initialize() async {
    _totalStars = _storage.getTotalStars();
    _totalCoins = _storage.getTotalCoins();
    _soundEnabled = _storage.isSoundEnabled();
    _musicEnabled = _storage.isMusicEnabled();
    _isPremium = _iapService.isPremiumUnlocked;
    
    final savedLocale = _storage.getLocale();
    if (savedLocale != null) {
      _currentLocale = Locale(savedLocale);
    }

    AudioService().setSoundEnabled(_soundEnabled);
    AudioService().setMusicEnabled(_musicEnabled);

    _iapService.onPurchaseStatusChanged = (purchased) {
      _isPremium = purchased;
      notifyListeners();
    };

    notifyListeners();
  }

  bool isLevelUnlocked(int levelId) {
    // First 3 levels are always free
    if (levelId <= LevelsData.freeLevelCount) {
      // Level 1 always unlocked, others need previous level completed
      if (levelId == 1) return true;
      return _storage.isLevelCompleted(levelId - 1);
    }

    // Premium levels need purchase + previous level completed
    if (!_isPremium) return false;
    return _storage.isLevelCompleted(levelId - 1);
  }

  bool isLevelCompleted(int levelId) {
    return _storage.isLevelCompleted(levelId);
  }

  int getLevelStars(int levelId) {
    return _storage.getStars(levelId);
  }

  int getLevelHighScore(int levelId) {
    return _storage.getHighScore(levelId);
  }

  Future<void> completeLevel(int levelId, int score, int stars) async {
    await _storage.setLevelCompleted(levelId);
    await _storage.saveHighScore(levelId, score);
    await _storage.saveStars(levelId, stars);
    _totalStars = _storage.getTotalStars();
    notifyListeners();
  }

  Future<void> addCoins(int amount) async {
    await _storage.addCoins(amount);
    _totalCoins = _storage.getTotalCoins();
    notifyListeners();
  }

  Future<void> purchasePremium() async {
    await _iapService.purchasePremium();
  }

  Future<void> restorePurchases() async {
    await _iapService.restorePurchases();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _storage.setSoundEnabled(enabled);
    AudioService().setSoundEnabled(enabled);
    notifyListeners();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await _storage.setMusicEnabled(enabled);
    AudioService().setMusicEnabled(enabled);
    if (!enabled) {
      AudioService().stopBackgroundMusic();
    } else {
      AudioService().playBackgroundMusic();
    }
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    _currentLocale = Locale(languageCode);
    await _storage.setLocale(languageCode);
    notifyListeners();
  }
}
