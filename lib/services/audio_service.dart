import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> initialize() async {
    await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _bgMusicPlayer.stop();
    }
  }

  Future<void> playJumpSound() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/jump.wav'));
  }

  Future<void> playCoinSound() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/coin.wav'));
  }

  Future<void> playLevelCompleteSound() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/level_complete.wav'));
  }

  Future<void> playGameOverSound() async {
    if (!_soundEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/game_over.wav'));
  }

  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    await _bgMusicPlayer.play(AssetSource('audio/bg_music.wav'));
  }

  Future<void> stopBackgroundMusic() async {
    await _bgMusicPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgMusicPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_musicEnabled) return;
    await _bgMusicPlayer.resume();
  }

  void dispose() {
    _bgMusicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
