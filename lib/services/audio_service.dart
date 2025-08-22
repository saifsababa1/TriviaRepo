import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Background music player
  late AudioPlayer _backgroundMusicPlayer;

  // Sound effects player
  late AudioPlayer _soundEffectsPlayer;

  // Settings
  bool _backgroundMusicEnabled = true;
  bool _soundEffectsEnabled = true;
  double _musicVolume = 0.7;
  double _effectsVolume = 0.8;

  // Audio assets
  static const String _backgroundMusicPath = 'assets/audio/background.wav';
  static const String _buttonClickPath = 'assets/audio/buttonsoundeffect.wav';
  static const String _correctAnswerPath = 'assets/audio/buttonsoundeffect.wav';
  static const String _wrongAnswerPath = 'assets/audio/buttonsoundeffect.wav';
  static const String _wheelSpinPath = 'assets/audio/wheel.mp3';
  static const String _coinCollectPath = 'assets/audio/buttonsoundeffect.wav';
  static const String _levelUpPath = 'assets/audio/buttonsoundeffect.wav';
  static const String _gameWinPath = 'assets/audio/win.wav';
  static const String _gameLosePath = 'assets/audio/buttonsoundeffect.wav';

  // Initialize the audio service
  Future<void> initialize() async {
    try {
      // Initialize background music player with timeout
      _backgroundMusicPlayer = AudioPlayer();
      await Future.delayed(const Duration(milliseconds: 100));

      // Initialize sound effects player with timeout
      _soundEffectsPlayer = AudioPlayer();
      await Future.delayed(const Duration(milliseconds: 100));

      // Load settings
      await _loadSettings();

      // Set up background music with timeout
      await _setupBackgroundMusic().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Background music setup timed out, continuing...
        },
      );
    } catch (e) {
      // Error initializing Audio Service - app will continue to work normally
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

  // Set up background music
  Future<void> _setupBackgroundMusic() async {
    try {
      // Load the background music asset
      await _backgroundMusicPlayer.setAsset(_backgroundMusicPath);
      await _backgroundMusicPlayer.setLoopMode(LoopMode.all);
      await _backgroundMusicPlayer.setVolume(_musicVolume);

      // Start background music if enabled
      if (_backgroundMusicEnabled) {
        await playBackgroundMusic();
      }
    } catch (e) {
      // Error setting up background music
      // Continue without background music
    }
  }

  // Play background music
  Future<void> playBackgroundMusic() async {
    if (!_backgroundMusicEnabled) return;

    try {
      // Set volume
      await _backgroundMusicPlayer.setVolume(_musicVolume);

      // Start playing the background music
      await _backgroundMusicPlayer.play();
    } catch (e) {
      // Error playing background music
      // Continue without playing music
    }
  }

  // Stop background music
  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.stop();
    } catch (e) {
      // Error stopping background music
      // Continue without stopping music
    }
  }

  // Pause background music
  Future<void> pauseBackgroundMusic() async {
    try {
      await _backgroundMusicPlayer.pause();
    } catch (e) {
      // Error pausing background music
      // Continue without pausing music
    }
  }

  // Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (!_backgroundMusicEnabled) return;

    try {
      await _backgroundMusicPlayer.play();
    } catch (e) {
      // Error resuming background music
      // Continue without resuming music
    }
  }

  // Play sound effect
  Future<void> playSoundEffect(String effectType) async {
    if (!_soundEffectsEnabled) return;

    try {
      String audioPath;

      switch (effectType) {
        case 'button_click':
          audioPath = _buttonClickPath;
          break;
        case 'correct_answer':
          audioPath = _correctAnswerPath;
          break;
        case 'wrong_answer':
          audioPath = _wrongAnswerPath;
          break;
        case 'wheel_spin':
          audioPath = _wheelSpinPath;
          break;
        case 'coin_collect':
          audioPath = _coinCollectPath;
          break;
        case 'level_up':
          audioPath = _levelUpPath;
          break;
        case 'game_win':
          audioPath = _gameWinPath;
          break;
        case 'game_lose':
          audioPath = _gameLosePath;
          break;
        default:
          audioPath = _buttonClickPath;
      }

      // Set volume for sound effects
      await _soundEffectsPlayer.setVolume(_effectsVolume);

      // Load and play the sound effect
      await _soundEffectsPlayer.setAsset(audioPath);
      await _soundEffectsPlayer.play();
    } catch (e) {
      // Error playing sound effect
      // Continue without playing sound effect
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
    await _backgroundMusicPlayer.setVolume(volume);
  }

  Future<void> updateEffectsVolume(double volume) async {
    _effectsVolume = volume;
    await _saveSettings();
  }

  // Get current settings
  bool get backgroundMusicEnabled => _backgroundMusicEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  double get musicVolume => _musicVolume;
  double get effectsVolume => _effectsVolume;

  // Dispose resources
  Future<void> dispose() async {
    try {
      await _backgroundMusicPlayer.dispose();
      await _soundEffectsPlayer.dispose();
    } catch (e) {
      // Error disposing Audio Service
      // Continue without disposing audio players
    }
  }
}
