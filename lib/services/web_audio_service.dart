import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Conditional import for web platform
import 'web_audio_html.dart' if (dart.library.io) 'web_audio_stub.dart';

class WebAudioService {
  static final WebAudioService _instance = WebAudioService._internal();
  factory WebAudioService() => _instance;
  WebAudioService._internal();

  // Settings
  bool _backgroundMusicEnabled = true;
  bool _soundEffectsEnabled = true;
  double _musicVolume = 0.7;
  double _effectsVolume = 0.8;

  // HTML5 Audio elements
  dynamic _backgroundMusicElement;
  dynamic _soundEffectsElement;

  // Web audio state
  bool _userInteracted = false;
  bool _backgroundMusicPlaying = false;

  // Audio assets
  static const String _backgroundMusicPath = 'assets/audio/background.wav';
  static const String _buttonClickPath = 'assets/audio/buttonsoundeffect.wav';

  // Initialize the web audio service
  Future<void> initialize() async {
    try {
      // Load settings
      await _loadSettings();

      // Initialize HTML5 audio elements
      _backgroundMusicElement = WebAudioHelper.createAudioElement(
        _backgroundMusicPath,
        true,
        _musicVolume,
      );
      _soundEffectsElement = WebAudioHelper.createAudioElement(
        _buttonClickPath,
        false,
        _effectsVolume,
      );

      // Start background music if enabled
      if (_backgroundMusicEnabled) {
        await playBackgroundMusic();
      }
    } catch (e) {
      // Error initializing Web Audio Service
    }
  }

  // Load audio settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _backgroundMusicEnabled =
          prefs.getBool('background_music_enabled') ?? true;
      _soundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? true;
      _musicVolume = prefs.getDouble('music_volume') ?? 0.7;
      _effectsVolume = prefs.getDouble('effects_volume') ?? 0.8;
    } catch (e) {
      // Error loading audio settings
    }
  }

  // Save audio settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('background_music_enabled', _backgroundMusicEnabled);
      await prefs.setBool('sound_effects_enabled', _soundEffectsEnabled);
      await prefs.setDouble('music_volume', _musicVolume);
      await prefs.setDouble('effects_volume', _effectsVolume);
    } catch (e) {
      // Error saving audio settings
    }
  }

  // Play background music (web implementation)
  Future<void> playBackgroundMusic() async {
    if (!_backgroundMusicEnabled ||
        _backgroundMusicElement == null ||
        _backgroundMusicPlaying)
      return;

    try {
      WebAudioHelper.setVolume(_backgroundMusicElement, _musicVolume);
      // Try to start immediately, don't wait for user interaction
      await WebAudioHelper.play(_backgroundMusicElement);
      _backgroundMusicPlaying = true;
    } catch (e) {
      // If it fails, it means we need user interaction
      print(
        '🎵 Web background music ready (will start after user interaction)',
      );
    }
  }

  // Stop background music
  Future<void> stopBackgroundMusic() async {
    try {
      if (_backgroundMusicElement != null) {
        WebAudioHelper.pause(_backgroundMusicElement);
        WebAudioHelper.setCurrentTime(_backgroundMusicElement, 0);
        _backgroundMusicPlaying = false;
      }
    } catch (e) {
      // Error stopping web background music
    }
  }

  // Pause background music
  Future<void> pauseBackgroundMusic() async {
    try {
      if (_backgroundMusicElement != null) {
        WebAudioHelper.pause(_backgroundMusicElement);
        _backgroundMusicPlaying = false;
      }
    } catch (e) {
      // Error pausing web background music
    }
  }

  // Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!_backgroundMusicEnabled ||
        _backgroundMusicElement == null ||
        _backgroundMusicPlaying)
      return;

    try {
      await WebAudioHelper.play(_backgroundMusicElement);
      _backgroundMusicPlaying = true;
    } catch (e) {
      // Error resuming web background music
    }
  }

  // Play sound effect (web implementation)
  Future<void> playSoundEffect(String effectType) async {
    if (!_soundEffectsEnabled || _soundEffectsElement == null) return;

    try {
      // Reset the audio to start for immediate playback
      WebAudioHelper.setCurrentTime(_soundEffectsElement, 0);
      WebAudioHelper.setVolume(_soundEffectsElement, _effectsVolume);

      // Mark that user has interacted
      _userInteracted = true;

      await WebAudioHelper.play(_soundEffectsElement);

      // Try to start background music if it was waiting for user interaction
      _tryStartBackgroundMusicAfterInteraction();
    } catch (e) {
      // Error playing web sound effect
    }
  }

  // Try to start background music after user interaction
  void _tryStartBackgroundMusicAfterInteraction() {
    if (_backgroundMusicEnabled &&
        _backgroundMusicElement != null &&
        _userInteracted &&
        !_backgroundMusicPlaying) {
      try {
        WebAudioHelper.play(_backgroundMusicElement);
        _backgroundMusicPlaying = true;
      } catch (e) {
        // Background music failed to start
      }
    }
  }

  // Convenience methods for common sound effects
  Future<void> playButtonClick() async => await playSoundEffect('button_click');
  Future<void> playCorrectAnswer() async =>
      await playSoundEffect('correct_answer');
  Future<void> playWrongAnswer() async => await playSoundEffect('wrong_answer');
  Future<void> playWheelSpin() async => await playSoundEffect('wheel_spin');
  Future<void> playCoinCollect() async => await playSoundEffect('coin_collect');
  Future<void> playLevelUp() async => await playSoundEffect('level_up');
  Future<void> playGameWin() async => await playSoundEffect('game_win');
  Future<void> playGameLose() async => await playSoundEffect('game_lose');

  // Update settings
  Future<void> updateBackgroundMusicEnabled(bool enabled) async {
    _backgroundMusicEnabled = enabled;
    await _saveSettings();

    if (enabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  Future<void> updateSoundEffectsEnabled(bool enabled) async {
    _soundEffectsEnabled = enabled;
    await _saveSettings();
  }

  Future<void> updateMusicVolume(double volume) async {
    _musicVolume = volume;
    await _saveSettings();
    if (_backgroundMusicElement != null) {
      WebAudioHelper.setVolume(_backgroundMusicElement, volume);
    }
  }

  Future<void> updateEffectsVolume(double volume) async {
    _effectsVolume = volume;
    await _saveSettings();
    if (_soundEffectsElement != null) {
      WebAudioHelper.setVolume(_soundEffectsElement, volume);
    }
  }

  // Get current settings
  bool get backgroundMusicEnabled => _backgroundMusicEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  double get musicVolume => _musicVolume;
  double get effectsVolume => _effectsVolume;

  // Dispose resources
  Future<void> dispose() async {
    try {
      if (_backgroundMusicElement != null) {
        WebAudioHelper.pause(_backgroundMusicElement);
        _backgroundMusicElement = null;
      }
      if (_soundEffectsElement != null) {
        WebAudioHelper.pause(_soundEffectsElement);
        _soundEffectsElement = null;
      }
    } catch (e) {
      // Error disposing Web Audio Service
    }
  }
}
