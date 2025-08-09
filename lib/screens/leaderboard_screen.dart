import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_state_service.dart';
import '../models/trivia_question.dart';
import '../widgets/star_coin.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  List<GameSession> _topSessions = [];
  bool _isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLeaderboardData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _loadLeaderboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gameState = GameStateService();
      _topSessions = gameState.getTopScoringSessions(10);

      // If no real data, show demo data
      if (_topSessions.isEmpty) {
        _createDemoData();
      }

      // Start animations after data loads
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      // Handle error - show demo data
      _createDemoData();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _createDemoData() {
    // Create realistic demo data for visual purposes
    final playerNames = [
      'Alex',
      'Sam',
      'Jordan',
      'Casey',
      'Riley',
      'Taylor',
      'Morgan',
      'Quinn',
    ];
    final categories = [
      'Science',
      'History',
      'Geography',
      'Sports',
      'Entertainment',
      'Literature',
    ];
    final difficulties = ['Easy', 'Medium', 'Hard'];

    _topSessions = List.generate(8, (index) {
      // Vary the number of questions (8-12)
      final questionCount = 8 + (index % 5);
      final correctCount = questionCount - index - 1; // Decreasing accuracy

      // Create realistic questions
      final dummyQuestions = List.generate(
        questionCount,
        (qIndex) => TriviaQuestion(
          id: 'demo_q_${index}_$qIndex',
          question:
              'What is the ${categories[qIndex % categories.length]} question ${qIndex + 1}?',
          options: ['Option A', 'Option B', 'Option C', 'Option D'],
          correctAnswerIndex: qIndex % 4,
          category: categories[qIndex % categories.length],
          difficulty: difficulties[qIndex % difficulties.length],
          explanation: 'This is the explanation for question ${qIndex + 1}',
          points:
              difficulties[qIndex % difficulties.length] == 'Hard'
                  ? 30
                  : difficulties[qIndex % difficulties.length] == 'Medium'
                  ? 20
                  : 10,
        ),
      );

      // Create realistic user answers with varying performance
      final dummyAnswers = List<UserAnswer>.generate(questionCount, (aIndex) {
        final isCorrect = aIndex < correctCount;
        final points = isCorrect ? dummyQuestions[aIndex].points : 0;
        return UserAnswer(
          questionId: 'demo_q_${index}_$aIndex',
          selectedAnswerIndex:
              isCorrect
                  ? dummyQuestions[aIndex].correctAnswerIndex
                  : (dummyQuestions[aIndex].correctAnswerIndex + 1) % 4,
          isCorrect: isCorrect,
          pointsEarned: points,
          timeTaken: Duration(seconds: 10 + (aIndex % 20)), // Varying time
          timestamp: DateTime.now().subtract(
            Duration(days: index, hours: aIndex, minutes: aIndex * 2),
          ),
        );
      });

      // Calculate realistic total score
      final totalScore = dummyAnswers.fold<int>(
        0,
        (sum, answer) => sum + answer.pointsEarned,
      );

      return GameSession(
          id: 'demo_${playerNames[index]}_$index',
          startTime: DateTime.now().subtract(Duration(days: index, hours: 2)),
          questions: dummyQuestions,
          userAnswers: dummyAnswers,
        )
        ..totalScore = totalScore
        ..streak = correctCount > 5 ? correctCount - 2 : correctCount
        ..endTime = DateTime.now().subtract(Duration(days: index, hours: 1));
    });

    // Sort by score descending to make it a proper leaderboard
    _topSessions.sort((a, b) => b.totalScore.compareTo(a.totalScore));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A), Color(0xFF4A148C)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              SizedBox(height: 16),
              Text(
                'Loading Rankings...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 2.0,
          colors: [Color(0xFF3F51B5), Color(0xFF303F9F), Color(0xFF1A237E)],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Enhanced Header with Stats
              _buildHeader(),

              // Top Scores Content
              Expanded(child: _buildScoresTab()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final totalGames = _topSessions.length;
    final highScore =
        _topSessions.isNotEmpty ? _topSessions.first.totalScore : 0;
    final avgScore =
        _topSessions.isNotEmpty
            ? (_topSessions.map((s) => s.totalScore).reduce((a, b) => a + b) /
                    _topSessions.length)
                .round()
            : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8F00)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leaderboard',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 24,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 2,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Track Your Progress',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Games', '$totalGames', Icons.gamepad),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('High Score', '$highScore', Icons.star),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Average',
                  '$avgScore',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.luckiestGuy(fontSize: 16, color: Colors.white),
          ),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresTab() {
    if (_topSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 80,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Games Yet!',
              style: GoogleFonts.luckiestGuy(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Play trivia games to see your scores here',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to trivia or refresh
                _loadLeaderboardData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _topSessions.length,
      itemBuilder: (context, index) {
        final session = _topSessions[index];
        return _buildScoreCard(session, index + 1);
      },
    );
  }

  Widget _buildScoreCard(GameSession session, int rank) {
    final correctAnswers = session.userAnswers.where((a) => a.isCorrect).length;
    final accuracy = session.accuracy;

    Color rankColor = const Color(0xFF616161);
    Color cardColor = Colors.white.withOpacity(0.15);
    IconData rankIcon = Icons.emoji_events;
    List<Color> gradientColors = [cardColor, cardColor];

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
      gradientColors = [
        const Color(0xFFFFD700).withOpacity(0.3),
        const Color(0xFFFFA500).withOpacity(0.2),
      ];
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      gradientColors = [
        const Color(0xFFC0C0C0).withOpacity(0.3),
        const Color(0xFFE8E8E8).withOpacity(0.2),
      ];
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      gradientColors = [
        const Color(0xFFCD7F32).withOpacity(0.3),
        const Color(0xFFB87333).withOpacity(0.2),
      ];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              rank <= 3
                  ? rankColor.withOpacity(0.6)
                  : Colors.white.withOpacity(0.3),
          width: rank <= 3 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Enhanced Rank Badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient:
                    rank <= 3
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [rankColor, rankColor.withOpacity(0.8)],
                        )
                        : null,
                color: rank > 3 ? rankColor : null,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: rankColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child:
                    rank <= 3
                        ? Icon(rankIcon, color: Colors.white, size: 24)
                        : Text(
                          '$rank',
                          style: GoogleFonts.luckiestGuy(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 20),

            // Score info with better layout
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${session.totalScore}',
                        style: GoogleFonts.luckiestGuy(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getAccuracyColor(accuracy).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getAccuracyColor(accuracy),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${(accuracy * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.roboto(
                            color: _getAccuracyColor(accuracy),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Points',
                    style: GoogleFonts.roboto(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[300],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$correctAnswers/${session.questionsAnswered}',
                        style: GoogleFonts.roboto(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange[300],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${session.streak}',
                        style: GoogleFonts.roboto(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (session.endTime != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(session.endTime!),
                      style: GoogleFonts.roboto(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.9) return Colors.green;
    if (accuracy >= 0.7) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
