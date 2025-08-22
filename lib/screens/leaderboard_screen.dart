import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_state_service.dart';
import '../models/trivia_question.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  List<GameSession> _topSessions = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _tabController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _tabAnimation;

  final List<String> _tabs = ['Top Scores', 'Recent Games', 'Achievements'];

  // Responsive tab names for smaller screens
  List<String> _getResponsiveTabs(double screenWidth) {
    if (screenWidth < 320) {
      return ['Top', 'Recent', 'Achieve'];
    } else if (screenWidth < 400) {
      return ['Top Scores', 'Recent', 'Achieve'];
    } else {
      return _tabs;
    }
  }

  // Responsive font size based on screen width
  double _getResponsiveFontSize(double screenWidth) {
    if (screenWidth < 320) {
      return 10.0;
    } else if (screenWidth < 400) {
      return 11.0;
    } else {
      return 12.0;
    }
  }

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

    _tabController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

    _tabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _tabController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _tabController.dispose();
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

  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
    _tabController.forward().then((_) => _tabController.reverse());
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB16DFF),
              Color(0xFF9854FF),
              Color(0xFF7B3EFF),
              Color(0xFF5B2CFF),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB16DFF),
            Color(0xFF9854FF),
            Color(0xFF7B3EFF),
            Color(0xFF5B2CFF),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Fixed Leaderboard Title
              _buildLeaderboardTitle(),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Enhanced Header with Stats
                      _buildHeader(),

                      // Tab Bar
                      _buildTabBar(),

                      // Tab Content
                      _buildTabContent(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
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
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width > 600 ? 24 : 20,
      ),
      margin: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 20 : 16),
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
      child: Row(
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
            child: _buildStatCard('Average', '$avgScore', Icons.trending_up),
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

  Widget _buildTabBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsiveTabs = _getResponsiveTabs(constraints.maxWidth);
        final responsiveFontSize = _getResponsiveFontSize(constraints.maxWidth);

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 400 ? 8 : 16,
            vertical: constraints.maxHeight < 700 ? 8 : 12,
          ),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, innerConstraints) {
              final availableWidth = innerConstraints.maxWidth - 8;
              final tabWidth = availableWidth / responsiveTabs.length;

              return SizedBox(
                height: 48,
                child: Stack(
                  children: [
                    // Animated sliding indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: _selectedTab * tabWidth + 2,
                      top: 2,
                      bottom: 2,
                      width: tabWidth - 4,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.6),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Tab buttons
                    Row(
                      children:
                          responsiveTabs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final tab = entry.value;
                            final isSelected = _selectedTab == index;

                            return Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _onTabChanged(index),
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          constraints.maxWidth < 400 ? 4 : 8,
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      tab,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : const Color(0xFF64748B),
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                        fontSize: responsiveFontSize,
                                        letterSpacing: isSelected ? 0.2 : 0.1,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildTopScoresTab();
      case 1:
        return _buildRecentGamesTab();
      case 2:
        return _buildAchievementsTab();
      default:
        return _buildTopScoresTab();
    }
  }

  Widget _buildTopScoresTab() {
    if (_topSessions.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ...List.generate(_topSessions.length, (index) {
            final session = _topSessions[index];
            return _buildScoreCard(session, index + 1);
          }),
          // Extra padding at bottom for better scrolling
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildRecentGamesTab() {
    final recentGames = _topSessions.take(5).toList();

    if (recentGames.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ...List.generate(recentGames.length, (index) {
            final session = recentGames[index];
            return _buildRecentGameCard(session);
          }),
          // Extra padding at bottom for better scrolling
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final achievements = [
      {
        'title': 'Score Master',
        'description': 'Reach 1000+ points in a single game',
        'icon': Icons.star_rounded,
        'color': const Color(0xFFFFD700),
        'isUnlocked': true,
      },
      {
        'title': 'Perfect Streak',
        'description': 'Answer 10 questions correctly in a row',
        'icon': Icons.local_fire_department_rounded,
        'color': const Color(0xFFFF5722),
        'isUnlocked': false,
      },
      {
        'title': 'Quick Thinker',
        'description': 'Answer 5 questions in under 30 seconds',
        'icon': Icons.flash_on_rounded,
        'color': const Color(0xFF2196F3),
        'isUnlocked': true,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ...List.generate(achievements.length, (index) {
            final achievement = achievements[index];
            return _buildAchievementCard(
              achievement['title'] as String,
              achievement['description'] as String,
              achievement['icon'] as IconData,
              achievement['color'] as Color,
              achievement['isUnlocked'] as bool,
            );
          }),
          // Extra padding at bottom for better scrolling
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
              _loadLeaderboardData();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: const Color(0xFF1A237E),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildRecentGameCard(GameSession session) {
    final accuracy = session.accuracy;
    final correctAnswers = session.userAnswers.where((a) => a.isCorrect).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.3),
            const Color(0xFF6366F1).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Score display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${session.totalScore} POINTS',
                    style: GoogleFonts.luckiestGuy(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${session.questionsAnswered} Q',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(accuracy * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${session.streak}',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Date
            Text(
              _formatDate(session.endTime ?? session.startTime),
              style: GoogleFonts.roboto(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    String title,
    String description,
    IconData icon,
    Color color,
    bool isUnlocked,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isUnlocked
                  ? [color.withOpacity(0.3), color.withOpacity(0.1)]
                  : [
                    Colors.grey.withOpacity(0.2),
                    Colors.grey.withOpacity(0.1),
                  ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isUnlocked
                  ? color.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isUnlocked
                    ? color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    isUnlocked
                        ? color.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isUnlocked ? color : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.luckiestGuy(
                      color: isUnlocked ? Colors.white : Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.roboto(
                      color: isUnlocked ? Colors.white70 : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isUnlocked ? Icons.check_circle : Icons.lock,
              color: isUnlocked ? Colors.green : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
