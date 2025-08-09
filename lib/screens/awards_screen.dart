import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_state_service.dart';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  List<Achievement> _unlockedAchievements = [];
  List<Achievement> _lockedAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  void _loadAchievements() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gameState = GameStateService();
      _unlockedAchievements = gameState.getUnlockedAchievements();
      _lockedAchievements =
          _getAllAchievements()
              .where(
                (achievement) =>
                    !_unlockedAchievements.any(
                      (unlocked) => unlocked.id == achievement.id,
                    ),
              )
              .toList();
    } catch (e) {
      // Handle error
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<Achievement> _getAllAchievements() {
    return [
      const Achievement(
        id: 'first_game',
        title: 'Getting Started',
        description: 'Play your first trivia game',
        icon: '🎮',
      ),
      const Achievement(
        id: 'score_1k',
        title: 'Knowledge Seeker',
        description: 'Earned 1,000 points',
        icon: '🎯',
      ),
      const Achievement(
        id: 'score_5k',
        title: 'Trivia Master',
        description: 'Earned 5,000 points',
        icon: '🏆',
      ),
      const Achievement(
        id: 'score_10k',
        title: 'Legend',
        description: 'Earned 10,000 points',
        icon: '👑',
      ),
      const Achievement(
        id: 'streak_5',
        title: 'Hot Streak',
        description: 'Answered 5 questions correctly in a row',
        icon: '🔥',
      ),
      const Achievement(
        id: 'streak_10',
        title: 'On Fire!',
        description: 'Answered 10 questions correctly in a row',
        icon: '🔥',
      ),
      const Achievement(
        id: 'streak_20',
        title: 'Unstoppable',
        description: 'Answered 20 questions correctly in a row',
        icon: '⚡',
      ),
      const Achievement(
        id: 'games_10',
        title: 'Regular Player',
        description: 'Played 10 games',
        icon: '🎮',
      ),
      const Achievement(
        id: 'games_50',
        title: 'Trivia Enthusiast',
        description: 'Played 50 games',
        icon: '⭐',
      ),
      const Achievement(
        id: 'games_100',
        title: 'Dedicated Player',
        description: 'Played 100 games',
        icon: '💪',
      ),
      const Achievement(
        id: 'accuracy_80',
        title: 'Sharp Mind',
        description: 'Maintain 80% accuracy',
        icon: '🧠',
      ),
      const Achievement(
        id: 'accuracy_90',
        title: 'Precision Expert',
        description: 'Maintain 90% accuracy',
        icon: '🎯',
      ),
      const Achievement(
        id: 'speed_demon',
        title: 'Speed Demon',
        description: 'Answer 10 questions in under 5 seconds each',
        icon: '⚡',
      ),
      const Achievement(
        id: 'science_master',
        title: 'Science Master',
        description: 'Answer 50 science questions correctly',
        icon: '🔬',
      ),
      const Achievement(
        id: 'history_buff',
        title: 'History Buff',
        description: 'Answer 50 history questions correctly',
        icon: '📚',
      ),
      const Achievement(
        id: 'geography_expert',
        title: 'Geography Expert',
        description: 'Answer 50 geography questions correctly',
        icon: '🌍',
      ),
      const Achievement(
        id: 'sports_fan',
        title: 'Sports Fan',
        description: 'Answer 50 sports questions correctly',
        icon: '⚽',
      ),
      const Achievement(
        id: 'entertainment_guru',
        title: 'Entertainment Guru',
        description: 'Answer 50 entertainment questions correctly',
        icon: '🎬',
      ),
      const Achievement(
        id: 'tech_wizard',
        title: 'Tech Wizard',
        description: 'Answer 50 technology questions correctly',
        icon: '💻',
      ),
      const Achievement(
        id: 'bookworm',
        title: 'Bookworm',
        description: 'Answer 50 literature questions correctly',
        icon: '📖',
      ),
    ];
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
          // Header with stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_unlockedAchievements.length}/${_getAllAchievements().length}',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withOpacity(0.3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor:
                  _unlockedAchievements.length / _getAllAchievements().length,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [Colors.yellow, Colors.orange],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Achievements list
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                        child: Text(
                          'Unlocked (${_unlockedAchievements.length})',
                          style: GoogleFonts.luckiestGuy(fontSize: 14),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Locked (${_lockedAchievements.length})',
                          style: GoogleFonts.luckiestGuy(fontSize: 14),
                        ),
                      ),
                    ],
                    indicatorColor: Colors.yellow,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Unlocked achievements
                        _unlockedAchievements.isNotEmpty
                            ? ListView.builder(
                              itemCount: _unlockedAchievements.length,
                              itemBuilder: (context, index) {
                                return _buildAchievementCard(
                                  _unlockedAchievements[index],
                                  isUnlocked: true,
                                );
                              },
                            )
                            : Center(
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
                                    'No achievements unlocked yet!',
                                    style: GoogleFonts.luckiestGuy(
                                      fontSize: 20,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    'Play games to start earning achievements',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                        // Locked achievements
                        ListView.builder(
                          itemCount: _lockedAchievements.length,
                          itemBuilder: (context, index) {
                            return _buildAchievementCard(
                              _lockedAchievements[index],
                              isUnlocked: false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    Achievement achievement, {
    required bool isUnlocked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isUnlocked
                ? Colors.white.withOpacity(0.15)
                : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isUnlocked
                  ? Colors.yellow.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isUnlocked
                      ? Colors.yellow.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
              border: Border.all(
                color: isUnlocked ? Colors.yellow : Colors.grey,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 18,
                          color: isUnlocked ? Colors.white : Colors.white60,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color:
                        isUnlocked
                            ? Colors.white70
                            : Colors.white.withOpacity(0.4),
                  ),
                ),
                if (isUnlocked) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'UNLOCKED',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 10,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
