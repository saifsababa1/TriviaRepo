class TriviaQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String difficulty;
  final String explanation;
  final int points;

  const TriviaQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    required this.difficulty,
    required this.explanation,
    required this.points,
  });

  String get correctAnswer => options[correctAnswerIndex];

  bool isCorrectAnswer(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'category': category,
      'difficulty': difficulty,
      'explanation': explanation,
      'points': points,
    };
  }

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    return TriviaQuestion(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      category: json['category'],
      difficulty: json['difficulty'],
      explanation: json['explanation'],
      points: json['points'],
    );
  }
}

class GameSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final List<TriviaQuestion> questions;
  final List<UserAnswer> userAnswers;
  int currentQuestionIndex;
  int totalScore;
  int streak;
  int coinsEarned;

  GameSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.questions,
    List<UserAnswer>? userAnswers,
    this.currentQuestionIndex = 0,
    this.totalScore = 0,
    this.streak = 0,
    this.coinsEarned = 0,
  }) : userAnswers = userAnswers ?? <UserAnswer>[];

  bool get isCompleted => currentQuestionIndex >= questions.length;
  int get questionsAnswered => userAnswers.length;
  int get questionsRemaining => questions.length - questionsAnswered;
  double get progressPercentage => questionsAnswered / questions.length;

  TriviaQuestion? get currentQuestion {
    if (currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  void addAnswer(UserAnswer answer) {
    userAnswers.add(answer);
    if (answer.isCorrect) {
      totalScore += answer.pointsEarned;
      streak++;
      coinsEarned += (answer.pointsEarned * (streak > 5 ? 2 : 1));
    } else {
      streak = 0;
    }
    currentQuestionIndex++;
  }

  void completeSession() {
    endTime = DateTime.now();
  }

  Duration? get sessionDuration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  double get accuracy {
    if (userAnswers.isEmpty) return 0.0;
    int correctAnswers = userAnswers.where((answer) => answer.isCorrect).length;
    return correctAnswers / userAnswers.length;
  }
}

class UserAnswer {
  final String questionId;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final int pointsEarned;
  final Duration timeTaken;
  final DateTime timestamp;

  const UserAnswer({
    required this.questionId,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.pointsEarned,
    required this.timeTaken,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswerIndex': selectedAnswerIndex,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
      'timeTaken': timeTaken.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory UserAnswer.fromJson(Map<String, dynamic> json) {
    return UserAnswer(
      questionId: json['questionId'],
      selectedAnswerIndex: json['selectedAnswerIndex'],
      isCorrect: json['isCorrect'],
      pointsEarned: json['pointsEarned'],
      timeTaken: Duration(milliseconds: json['timeTaken']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class PlayerStats {
  final int totalGamesPlayed;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final int totalScore;
  final int totalCoinsEarned;
  final int longestStreak;
  final int currentLevel;
  final Map<String, int> categoryScores;

  const PlayerStats({
    this.totalGamesPlayed = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    this.totalScore = 0,
    this.totalCoinsEarned = 0,
    this.longestStreak = 0,
    this.currentLevel = 1,
    this.categoryScores = const {},
  });

  double get overallAccuracy {
    if (totalQuestionsAnswered == 0) return 0.0;
    return totalCorrectAnswers / totalQuestionsAnswered;
  }

  int get experiencePoints => totalScore;
  int get experienceForNextLevel => (currentLevel * 1000);
  double get levelProgress => experiencePoints / experienceForNextLevel;

  PlayerStats copyWith({
    int? totalGamesPlayed,
    int? totalQuestionsAnswered,
    int? totalCorrectAnswers,
    int? totalScore,
    int? totalCoinsEarned,
    int? longestStreak,
    int? currentLevel,
    Map<String, int>? categoryScores,
  }) {
    return PlayerStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalQuestionsAnswered:
          totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalScore: totalScore ?? this.totalScore,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      longestStreak: longestStreak ?? this.longestStreak,
      currentLevel: currentLevel ?? this.currentLevel,
      categoryScores: categoryScores ?? this.categoryScores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalScore': totalScore,
      'totalCoinsEarned': totalCoinsEarned,
      'longestStreak': longestStreak,
      'currentLevel': currentLevel,
      'categoryScores': categoryScores,
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalQuestionsAnswered: json['totalQuestionsAnswered'] ?? 0,
      totalCorrectAnswers: json['totalCorrectAnswers'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      totalCoinsEarned: json['totalCoinsEarned'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      categoryScores: Map<String, int>.from(json['categoryScores'] ?? {}),
    );
  }
}
