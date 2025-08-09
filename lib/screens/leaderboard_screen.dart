import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_state_service.dart';
import '../models/trivia_question.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<GameSession> _topSessions = [];
  Map<String, double> _categoryPerformance = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }

  void _loadLeaderboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gameState = GameStateService();
      _topSessions = gameState.getTopScoringSessions(10);
      _categoryPerformance = gameState.getCategoryPerformance();
    } catch (e) {
      // Handle error
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Your Best Scores',
            style: GoogleFonts.luckiestGuy(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Top scores list
          if (_topSessions.isNotEmpty)
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: _topSessions.length,
                itemBuilder: (context, index) {
                  final session = _topSessions[index];
                  return _buildScoreCard(session, index + 1);
                },
              ),
            )
          else
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 80,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No games played yet!',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Play your first game to see scores here',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Category performance
          if (_categoryPerformance.isNotEmpty) ...[
            Text(
              'Category Performance',
              style: GoogleFonts.luckiestGuy(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 2,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _categoryPerformance.length,
                itemBuilder: (context, index) {
                  final entry = _categoryPerformance.entries.elementAt(index);
                  return _buildCategoryCard(entry.key, entry.value);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreCard(GameSession session, int rank) {
    final correctAnswers = session.userAnswers.where((a) => a.isCorrect).length;
    final accuracy = session.accuracy;

    Color rankColor = Colors.grey;
    IconData rankIcon = Icons.emoji_events;

    if (rank == 1) {
      rankColor = Colors.yellow[600]!;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey[400]!;
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = Colors.brown[400]!;
      rankIcon = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3 ? rankColor : Colors.white.withOpacity(0.3),
          width: rank <= 3 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
            child: Center(
              child:
                  rank <= 3
                      ? Icon(rankIcon, color: Colors.white, size: 20)
                      : Text(
                        '$rank',
                        style: GoogleFonts.luckiestGuy(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
            ),
          ),
          const SizedBox(width: 16),

          // Score info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${session.totalScore} points',
                      style: GoogleFonts.luckiestGuy(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${(accuracy * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.luckiestGuy(
                        color: Colors.yellow[300],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$correctAnswers/${session.questionsAnswered} correct • Streak: ${session.streak}',
                  style: GoogleFonts.roboto(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (session.endTime != null)
                  Text(
                    'Played ${_formatDate(session.endTime!)}',
                    style: GoogleFonts.roboto(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, double performance) {
    final percentage = (performance * 100).round();
    Color performanceColor = Colors.red;

    if (percentage >= 80) {
      performanceColor = Colors.green;
    } else if (percentage >= 60) {
      performanceColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: performanceColor.withOpacity(0.5), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            category,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: GoogleFonts.luckiestGuy(
              color: performanceColor,
              fontSize: 20,
            ),
          ),
          Container(
            height: 4,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withOpacity(0.3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: performance,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: performanceColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
