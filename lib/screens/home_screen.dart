import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/play_button.dart';

import '../services/trivia_service.dart';
import '../services/game_state_service.dart';
import 'trivia_screen.dart';
import 'app_shell.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback onNextPressed;
  final VoidCallback onContinuePressed;

  const HomeScreen({
    super.key,
    required this.onPlayPressed,
    required this.onNextPressed,
    required this.onContinuePressed,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showGameSetupDialog() {
    showDialog(context: context, builder: (context) => const GameSetupDialog());
  }

  @override
  Widget build(BuildContext context) {
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
      child: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game title
                  Text(
                    'ULTIMATE',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 36,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'TRIVIA GAME',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 28,
                      color: Colors.yellow[300],
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Pulsing Play Button
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: PlayButton(
                          text: 'PLAY NOW',
                          onPressed: _showGameSetupDialog,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Quick stats
                  FutureBuilder<GameStateService>(
                    future: Future.value(GameStateService()),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final gameState = snapshot.data!;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              'High Score',
                              '${gameState.highScore}',
                              Icons.emoji_events,
                              Colors.yellow[300]!,
                            ),
                            _buildStatCard(
                              'Coins',
                              '${gameState.currentCoins}',
                              Icons.monetization_on,
                              Colors.green[300]!,
                            ),
                            _buildStatCard(
                              'Level',
                              '${gameState.currentStats.currentLevel}',
                              Icons.trending_up,
                              Colors.blue[300]!,
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            // Top-right button to switch to AllComponentsPreview
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.grid_view_rounded,
                  size: 28,
                  color: Colors.white,
                ),
                tooltip: 'Show All Components',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AllComponentsPreview(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.luckiestGuy(fontSize: 18, color: Colors.white),
          ),
          Text(
            label,
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class GameSetupDialog extends StatefulWidget {
  const GameSetupDialog({super.key});

  @override
  State<GameSetupDialog> createState() => _GameSetupDialogState();
}

class _GameSetupDialogState extends State<GameSetupDialog> {
  String? _selectedCategory;
  String? _selectedDifficulty = 'Easy';
  int _questionCount = 10;

  @override
  Widget build(BuildContext context) {
    final categories = TriviaService().getAvailableCategories();

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
            Text(
              'Setup Your Game',
              style: GoogleFonts.luckiestGuy(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 24),

            // Category selection
            Text(
              'Category (Optional)',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Text('All Categories'),
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Difficulty selection
            Text(
              'Difficulty',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children:
                  ['Easy', 'Medium', 'Hard'].map((difficulty) {
                    final isSelected = _selectedDifficulty == difficulty;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDifficulty = difficulty;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              difficulty,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                color:
                                    isSelected
                                        ? const Color(0xFF7B3EFF)
                                        : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 16),

            // Question count
            Text(
              'Number of Questions: $_questionCount',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _questionCount.toDouble(),
              min: 5,
              max: 20,
              divisions: 3,
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.3),
              onChanged: (value) {
                setState(() {
                  _questionCount = value.round();
                });
              },
            ),

            const SizedBox(height: 24),

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TriviaScreen(
                            selectedCategory: _selectedCategory,
                            selectedDifficulty: _selectedDifficulty,
                            questionCount: _questionCount,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'START GAME',
                  style: GoogleFonts.luckiestGuy(
                    color: const Color(0xFF7B3EFF),
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
