import 'package:flutter/foundation.dart';
import 'audio_service.dart';
import 'web_audio_service.dart';

// Unified audio service that works on all platforms
class UnifiedAudioService {
  static final UnifiedAudioService _instance = UnifiedAudioService._internal();
  factory UnifiedAudioService() => _instance;
  UnifiedAudioService._internal();

  late dynamic _audioService;

  // Initialize the appropriate audio service
  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Use web audio service for web platform
        _audioService = WebAudioService();
      } else {
        // Use mobile audio service for mobile platforms
        _audioService = AudioService();
      }

      await _audioService.initialize();
    } catch (e) {
      // Error initializing Unified Audio Service - creating fallback service
      _audioService = _createFallbackService();
    }
  }

  // Create a minimal fallback service that does nothing
  dynamic _createFallbackService() {
    return _FallbackAudioService();
  }

  // Delegate all methods to the appropriate service
  Future<void> playBackgroundMusic() async =>
      await _audioService.playBackgroundMusic();
  Future<void> stopBackgroundMusic() async =>
      await _audioService.stopBackgroundMusic();
  Future<void> pauseBackgroundMusic() async =>
      await _audioService.pauseBackgroundMusic();
  Future<void> resumeBackgroundMusic() async =>
      await _audioService.resumeBackgroundMusic();

  Future<void> playButtonClick() async => await _audioService.playButtonClick();
  Future<void> playCorrectAnswer() async =>
      await _audioService.playCorrectAnswer();
  Future<void> playWrongAnswer() async => await _audioService.playWrongAnswer();
  Future<void> playWheelSpin() async => await _audioService.playWheelSpin();
  Future<void> playCoinCollect() async => await _audioService.playCoinCollect();
  Future<void> playLevelUp() async => await _audioService.playLevelUp();
  Future<void> playGameWin() async => await _audioService.playGameWin();
  Future<void> playGameLose() async => await _audioService.playGameLose();

  Future<void> updateBackgroundMusicEnabled(bool enabled) async =>
      await _audioService.updateBackgroundMusicEnabled(enabled);
  Future<void> updateSoundEffectsEnabled(bool enabled) async =>
      await _audioService.updateSoundEffectsEnabled(enabled);
  Future<void> updateMusicVolume(double volume) async =>
      await _audioService.updateMusicVolume(volume);
  Future<void> updateEffectsVolume(double volume) async =>
      await _audioService.updateEffectsVolume(volume);

  bool get backgroundMusicEnabled => _audioService.backgroundMusicEnabled;
  bool get soundEffectsEnabled => _audioService.soundEffectsEnabled;
  double get musicVolume => _audioService.musicVolume;
  double get effectsVolume => _audioService.effectsVolume;

  Future<void> dispose() async => await _audioService.dispose();
}

// Minimal fallback audio service that does nothing
class _FallbackAudioService {
  Future<void> initialize() async {}
  Future<void> playBackgroundMusic() async {}
  Future<void> stopBackgroundMusic() async {}
  Future<void> pauseBackgroundMusic() async {}
  Future<void> resumeBackgroundMusic() async {}

  Future<void> playButtonClick() async {}
  Future<void> playCorrectAnswer() async {}
  Future<void> playWrongAnswer() async {}
  Future<void> playWheelSpin() async {}
  Future<void> playCoinCollect() async {}
  Future<void> playLevelUp() async {}
  Future<void> playGameWin() async {}
  Future<void> playGameLose() async {}

  Future<void> updateBackgroundMusicEnabled(bool enabled) async {}
  Future<void> updateSoundEffectsEnabled(bool enabled) async {}
  Future<void> updateMusicVolume(double volume) async {}
  Future<void> updateEffectsVolume(double volume) async {}

  bool get backgroundMusicEnabled => false;
  bool get soundEffectsEnabled => false;
  double get musicVolume => 0.0;
  double get effectsVolume => 0.0;

  Future<void> dispose() async {}
}
