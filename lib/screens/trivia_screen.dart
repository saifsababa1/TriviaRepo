import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../models/trivia_question.dart';
import '../services/trivia_service.dart';
import '../services/game_state_service.dart';
import '../widgets/star_coin.dart';

class TriviaScreen extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedDifficulty;
  final int questionCount;

  const TriviaScreen({
    super.key,
    this.selectedCategory,
    this.selectedDifficulty,
    this.questionCount = 10,
  });

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen>
    with TickerProviderStateMixin {
  late GameSession _currentSession;
  late AnimationController _progressController;
  late AnimationController _questionController;
  late AnimationController _answerController;
  late AnimationController _timerController;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _questionSlideAnimation;
  late Animation<double> _answerFadeAnimation;

  Timer? _questionTimer;
  bool _isAnswering = false;
  int? _selectedAnswer;
  bool? _isCorrect;
  String _feedback = '';
  final Duration _questionTimeLimit = const Duration(seconds: 30);
  late DateTime _questionStartTime;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGame();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _questionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _questionSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeOutCubic),
    );

    _answerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _answerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _answerController, curve: Curves.easeIn));

    _timerController = AnimationController(
      duration: _questionTimeLimit,
      vsync: this,
    );
  }

  void _initializeGame() {
    _currentSession = TriviaService().createGameSession(
      category: widget.selectedCategory,
      difficulty: widget.selectedDifficulty,
      questionCount: widget.questionCount,
    );
    _startQuestion();
  }

  void _startQuestion() {
    _questionStartTime = DateTime.now();
    _selectedAnswer = null;
    _isCorrect = null;
    _feedback = '';
    _isAnswering = false;

    _questionController.forward();
    _progressController.animateTo(_currentSession.progressPercentage);
    _timerController.forward();

    _questionTimer?.cancel();
    _questionTimer = Timer(_questionTimeLimit, () {
      if (mounted && !_isAnswering) {
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    if (_isAnswering) return;

    setState(() {
      _isAnswering = true;
      _feedback = '⏰ Time\'s up!';
    });

    _submitAnswer(-1);
  }

  void _selectAnswer(int index) {
    if (_isAnswering) return;

    setState(() {
      _selectedAnswer = index;
      _isAnswering = true;
    });

    _questionTimer?.cancel();
    _timerController.stop();

    Future.delayed(const Duration(milliseconds: 300), () {
      _submitAnswer(index);
    });
  }

  void _submitAnswer(int selectedIndex) {
    final currentQuestion = _currentSession.currentQuestion!;
    final timeTaken = DateTime.now().difference(_questionStartTime);
    final isCorrect = selectedIndex == currentQuestion.correctAnswerIndex;

    int points = 0;
    if (isCorrect) {
      points = currentQuestion.points;
      final speedBonus = (30 - timeTaken.inSeconds).clamp(0, 20);
      points += speedBonus;
    }

    final userAnswer = UserAnswer(
      questionId: currentQuestion.id,
      selectedAnswerIndex: selectedIndex,
      isCorrect: isCorrect,
      pointsEarned: points,
      timeTaken: timeTaken,
      timestamp: DateTime.now(),
    );

    _currentSession.addAnswer(userAnswer);

    setState(() {
      _isCorrect = isCorrect;
      if (isCorrect) {
        _feedback = _getCorrectFeedback();
      } else if (selectedIndex == -1) {
        _feedback =
            '⏰ Time\'s up! The correct answer was: ${currentQuestion.correctAnswer}';
      } else {
        _feedback =
            '❌ Incorrect! The correct answer was: ${currentQuestion.correctAnswer}';
      }
    });

    HapticFeedback.mediumImpact();
    _answerController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  String _getCorrectFeedback() {
    final responses = [
      '🎉 Excellent!',
      '⭐ Great job!',
      '🔥 On fire!',
      '💡 Brilliant!',
      '🏆 Perfect!',
      '🌟 Outstanding!',
      '🎯 Bullseye!',
    ];
    return responses[_currentSession.streak % responses.length];
  }

  void _nextQuestion() {
    if (_currentSession.isCompleted) {
      _finishGame();
      return;
    }

    _answerController.reset();
    _questionController.reset();
    _timerController.reset();

    _startQuestion();
  }

  void _finishGame() async {
    _currentSession.completeSession();
    await GameStateService().updatePlayerStats(_currentSession);
    await GameStateService().addGameSession(_currentSession);

    if (mounted) {
      _showGameCompletionDialog();
    }
  }

  void _showGameCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameCompletionDialog(session: _currentSession),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    _timerController.dispose();
    _questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _currentSession.currentQuestion;

    if (currentQuestion == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTimer(),
              const SizedBox(height: 20),
              Expanded(
                child: SlideTransition(
                  position: _questionSlideAnimation,
                  child: _buildQuestionCard(currentQuestion),
                ),
              ),
              if (_feedback.isNotEmpty) _buildFeedback(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'Question ${_currentSession.currentQuestionIndex + 1} of ${_currentSession.questions.length}',
                style: GoogleFonts.luckiestGuy(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isCorrect == true
                          ? Colors.green
                          : _isCorrect == false
                          ? Colors.red
                          : Colors.yellow,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Column(
          children: [
            StarCoinCredit(creditAmount: _currentSession.totalScore, size: 50),
            Text(
              'Streak: ${_currentSession.streak}',
              style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimer() {
    return AnimatedBuilder(
      animation: _timerController,
      builder: (context, child) {
        final remainingTime =
            _questionTimeLimit.inSeconds -
            (_timerController.value * _questionTimeLimit.inSeconds).round();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: remainingTime <= 5 ? Colors.red : Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '${remainingTime}s',
                style: GoogleFonts.luckiestGuy(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(TriviaQuestion question) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8F9FA)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(question.category),
                  backgroundColor: _getCategoryColor(question.category),
                ),
                Chip(
                  label: Text(question.difficulty),
                  backgroundColor: _getDifficultyColor(question.difficulty),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              question.question,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  return _buildAnswerOption(question, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(TriviaQuestion question, int index) {
    final isSelected = _selectedAnswer == index;
    final isCorrectAnswer = index == question.correctAnswerIndex;

    Color backgroundColor = Colors.grey[100]!;
    Color borderColor = Colors.grey[300]!;

    if (_isAnswering) {
      if (isCorrectAnswer) {
        backgroundColor = Colors.green[100]!;
        borderColor = Colors.green;
      } else if (isSelected && !isCorrectAnswer) {
        backgroundColor = Colors.red[100]!;
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue[100]!;
      borderColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isAnswering ? null : () => _selectAnswer(index),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: borderColor,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: GoogleFonts.luckiestGuy(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    question.options[index],
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (_isAnswering && isCorrectAnswer)
                  const Icon(Icons.check_circle, color: Colors.green),
                if (_isAnswering && isSelected && !isCorrectAnswer)
                  const Icon(Icons.cancel, color: Colors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    return FadeTransition(
      opacity: _answerFadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isCorrect == true ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              _feedback,
              style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (_currentSession.currentQuestion?.explanation.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _currentSession.currentQuestion!.explanation,
                  style: GoogleFonts.roboto(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Science': Colors.blue[200]!,
      'History': Colors.brown[200]!,
      'Geography': Colors.green[200]!,
      'Sports': Colors.orange[200]!,
      'Entertainment': Colors.purple[200]!,
      'Technology': Colors.cyan[200]!,
      'Literature': Colors.pink[200]!,
    };
    return colors[category] ?? Colors.grey[200]!;
  }

  Color _getDifficultyColor(String difficulty) {
    final colors = {
      'Easy': Colors.green[200]!,
      'Medium': Colors.orange[200]!,
      'Hard': Colors.red[200]!,
    };
    return colors[difficulty] ?? Colors.grey[200]!;
  }
}

class GameCompletionDialog extends StatelessWidget {
  final GameSession session;

  const GameCompletionDialog({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final correctAnswers = session.userAnswers.where((a) => a.isCorrect).length;
    final accuracy = session.accuracy;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7B3EFF), Color(0xFF9854FF)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 60, color: Colors.yellow),
            const SizedBox(height: 16),
            Text(
              'Game Complete!',
              style: GoogleFonts.luckiestGuy(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildStatRow('Questions Answered', '${session.questionsAnswered}'),
            _buildStatRow('Correct Answers', '$correctAnswers'),
            _buildStatRow(
              'Accuracy',
              '${(accuracy * 100).toStringAsFixed(1)}%',
            ),
            _buildStatRow('Total Score', '${session.totalScore}'),
            _buildStatRow('Coins Earned', '${session.coinsEarned}'),
            _buildStatRow('Longest Streak', '${session.streak}'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Home',
                      style: GoogleFonts.luckiestGuy(
                        color: const Color(0xFF7B3EFF),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => TriviaScreen(
                                selectedCategory:
                                    session.questions.first.category,
                                selectedDifficulty:
                                    session.questions.first.difficulty,
                                questionCount: session.questions.length,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Play Again',
                      style: GoogleFonts.luckiestGuy(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
