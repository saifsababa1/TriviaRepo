import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trivia_question.dart';

class GameStateService {
  static final GameStateService _instance = GameStateService._internal();
  factory GameStateService() => _instance;
  GameStateService._internal();

  static const String _playerStatsKey = 'player_stats';
  static const String _currentCoinsKey = 'current_coins';
  static const String _highScoreKey = 'high_score';
  static const String _gameHistoryKey = 'game_history';
  static const String _settingsKey = 'game_settings';

  PlayerStats _currentStats = const PlayerStats();
  int _currentCoins = 100; // Starting coins
  int _highScore = 0;
  List<GameSession> _gameHistory = [];
  Map<String, dynamic> _settings = {
    'soundEnabled': true,
    'vibrationEnabled': true,
    'autoNext': false,
    'showExplanations': true,
    'theme': 'purple',
  };

  // Getters
  PlayerStats get currentStats => _currentStats;
  int get currentCoins => _currentCoins;
  int get highScore => _highScore;
  List<GameSession> get gameHistory => List.unmodifiable(_gameHistory);
  Map<String, dynamic> get settings => Map.unmodifiable(_settings);

  // Initialize the service
  Future<void> initialize() async {
    await _loadPlayerStats();
    await _loadCoins();
    await _loadHighScore();
    await _loadGameHistory();
    await _loadSettings();
  }

  // Player Stats Management
  Future<void> _loadPlayerStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_playerStatsKey);
    if (statsJson != null) {
      final statsMap = jsonDecode(statsJson);
      _currentStats = PlayerStats.fromJson(statsMap);
    }
  }

  Future<void> _savePlayerStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerStatsKey, jsonEncode(_currentStats.toJson()));
  }

  Future<void> updatePlayerStats(GameSession completedSession) async {
    final correctAnswers =
        completedSession.userAnswers.where((a) => a.isCorrect).length;
    final newLevel = _calculateLevel(
      _currentStats.totalScore + completedSession.totalScore,
    );

    _currentStats = _currentStats.copyWith(
      totalGamesPlayed: _currentStats.totalGamesPlayed + 1,
      totalQuestionsAnswered:
          _currentStats.totalQuestionsAnswered +
          completedSession.questionsAnswered,
      totalCorrectAnswers: _currentStats.totalCorrectAnswers + correctAnswers,
      totalScore: _currentStats.totalScore + completedSession.totalScore,
      totalCoinsEarned:
          _currentStats.totalCoinsEarned + completedSession.coinsEarned,
      longestStreak:
          _currentStats.longestStreak > completedSession.streak
              ? _currentStats.longestStreak
              : completedSession.streak,
      currentLevel: newLevel,
    );

    await _savePlayerStats();
    await updateCoins(_currentCoins + completedSession.coinsEarned);

    if (completedSession.totalScore > _highScore) {
      await updateHighScore(completedSession.totalScore);
    }
  }

  int _calculateLevel(int totalScore) {
    // Level = sqrt(totalScore / 100) + 1, with minimum of 1
    return (totalScore / 1000).floor() + 1;
  }

  // Coins Management
  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCoins = prefs.getInt(_currentCoinsKey) ?? 100;
  }

  Future<void> updateCoins(int newAmount) async {
    _currentCoins = newAmount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentCoinsKey, _currentCoins);
  }

  Future<bool> spendCoins(int amount) async {
    if (_currentCoins >= amount) {
      await updateCoins(_currentCoins - amount);
      return true;
    }
    return false;
  }

  Future<void> earnCoins(int amount) async {
    await updateCoins(_currentCoins + amount);
  }

  // High Score Management
  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt(_highScoreKey) ?? 0;
  }

  Future<void> updateHighScore(int score) async {
    if (score > _highScore) {
      _highScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, _highScore);
    }
  }

  // Game History Management
  Future<void> _loadGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_gameHistoryKey);
    if (historyJson != null) {
      _gameHistory =
          historyJson
              .map((sessionJson) => _gameSessionFromJson(sessionJson))
              .where((session) => session != null)
              .cast<GameSession>()
              .toList();
    }
  }

  GameSession? _gameSessionFromJson(String json) {
    try {
      final data = jsonDecode(json);
      return GameSession(
        id: data['id'],
        startTime: DateTime.parse(data['startTime']),
        endTime:
            data['endTime'] != null ? DateTime.parse(data['endTime']) : null,
        questions:
            (data['questions'] as List)
                .map((q) => TriviaQuestion.fromJson(q))
                .toList(),
        userAnswers:
            (data['userAnswers'] as List)
                .map((a) => UserAnswer.fromJson(a))
                .toList(),
        currentQuestionIndex: data['currentQuestionIndex'] ?? 0,
        totalScore: data['totalScore'] ?? 0,
        streak: data['streak'] ?? 0,
        coinsEarned: data['coinsEarned'] ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  String _gameSessionToJson(GameSession session) {
    return jsonEncode({
      'id': session.id,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime?.toIso8601String(),
      'questions': session.questions.map((q) => q.toJson()).toList(),
      'userAnswers': session.userAnswers.map((a) => a.toJson()).toList(),
      'currentQuestionIndex': session.currentQuestionIndex,
      'totalScore': session.totalScore,
      'streak': session.streak,
      'coinsEarned': session.coinsEarned,
    });
  }

  Future<void> addGameSession(GameSession session) async {
    _gameHistory.insert(0, session); // Add to beginning

    // Keep only last 50 games to prevent storage overflow
    if (_gameHistory.length > 50) {
      _gameHistory = _gameHistory.take(50).toList();
    }

    final prefs = await SharedPreferences.getInstance();
    final historyJson = _gameHistory.map((s) => _gameSessionToJson(s)).toList();
    await prefs.setStringList(_gameHistoryKey, historyJson);
  }

  // Settings Management
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    if (settingsJson != null) {
      _settings = Map<String, dynamic>.from(jsonDecode(settingsJson));
    }
  }

  Future<void> updateSetting(String key, dynamic value) async {
    _settings[key] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_settings));
  }

  // Leaderboard & Statistics
  List<GameSession> getTopScoringSessions([int limit = 10]) {
    final sortedSessions = List<GameSession>.from(_gameHistory);
    sortedSessions.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return sortedSessions.take(limit).toList();
  }

  Map<String, double> getCategoryPerformance() {
    final categoryStats = <String, List<double>>{};

    for (final session in _gameHistory) {
      for (
        int i = 0;
        i < session.questions.length && i < session.userAnswers.length;
        i++
      ) {
        final question = session.questions[i];
        final answer = session.userAnswers[i];
        final accuracy = answer.isCorrect ? 1.0 : 0.0;

        categoryStats.putIfAbsent(question.category, () => []).add(accuracy);
      }
    }

    final categoryPerformance = <String, double>{};
    categoryStats.forEach((category, accuracies) {
      categoryPerformance[category] =
          accuracies.reduce((a, b) => a + b) / accuracies.length;
    });

    return categoryPerformance;
  }

  double getRecentPerformance([int sessionCount = 5]) {
    if (_gameHistory.isEmpty) return 0.0;

    final recentSessions = _gameHistory.take(sessionCount);
    int totalQuestions = 0;
    int totalCorrect = 0;

    for (final session in recentSessions) {
      totalQuestions += session.questionsAnswered;
      totalCorrect += session.userAnswers.where((a) => a.isCorrect).length;
    }

    return totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0;
  }

  // Achievements System
  List<Achievement> getUnlockedAchievements() {
    final achievements = <Achievement>[];

    // Score-based achievements
    if (_currentStats.totalScore >= 1000) {
      achievements.add(
        const Achievement(
          id: 'score_1k',
          title: 'Knowledge Seeker',
          description: 'Earned 1,000 points',
          icon: '🎯',
        ),
      );
    }

    if (_currentStats.totalScore >= 5000) {
      achievements.add(
        const Achievement(
          id: 'score_5k',
          title: 'Trivia Master',
          description: 'Earned 5,000 points',
          icon: '🏆',
        ),
      );
    }

    // Streak-based achievements
    if (_currentStats.longestStreak >= 10) {
      achievements.add(
        const Achievement(
          id: 'streak_10',
          title: 'On Fire!',
          description: 'Answered 10 questions correctly in a row',
          icon: '🔥',
        ),
      );
    }

    // Games played achievements
    if (_currentStats.totalGamesPlayed >= 10) {
      achievements.add(
        const Achievement(
          id: 'games_10',
          title: 'Regular Player',
          description: 'Played 10 games',
          icon: '🎮',
        ),
      );
    }

    if (_currentStats.totalGamesPlayed >= 50) {
      achievements.add(
        const Achievement(
          id: 'games_50',
          title: 'Trivia Enthusiast',
          description: 'Played 50 games',
          icon: '⭐',
        ),
      );
    }

    // Accuracy achievements
    if (_currentStats.overallAccuracy >= 0.8) {
      achievements.add(
        const Achievement(
          id: 'accuracy_80',
          title: 'Sharp Mind',
          description: 'Maintain 80% accuracy',
          icon: '🧠',
        ),
      );
    }

    return achievements;
  }

  // Data reset (for testing or user request)
  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playerStatsKey);
    await prefs.remove(_currentCoinsKey);
    await prefs.remove(_highScoreKey);
    await prefs.remove(_gameHistoryKey);

    _currentStats = const PlayerStats();
    _currentCoins = 100;
    _highScore = 0;
    _gameHistory = [];
  }

  // Export data (for backup)
  Map<String, dynamic> exportData() {
    return {
      'playerStats': _currentStats.toJson(),
      'currentCoins': _currentCoins,
      'highScore': _highScore,
      'gameHistory': _gameHistory.map((s) => _gameSessionToJson(s)).toList(),
      'settings': _settings,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'description': description, 'icon': icon};
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}



