// lib/screens/enhanced_spin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;
import '../services/game_state_service.dart';
import '../widgets/star_coin.dart';
import '../widgets/custom_icons.dart';

class EnhancedSpinScreen extends StatefulWidget {
  const EnhancedSpinScreen({super.key});

  @override
  State<EnhancedSpinScreen> createState() => _EnhancedSpinScreenState();
}

class _EnhancedSpinScreenState extends State<EnhancedSpinScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late AnimationController _wheelGlowController;
  late AnimationController _shineController;
  late ConfettiController _confettiController;

  late Animation<double> _spinAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _wheelGlowAnimation;
  late Animation<double> _shineAnimation;

  bool _isSpinning = false;
  bool _canSpin = true;
  int _selectedReward = 0;
  int _currentCoins = 0;
  int _dailySpinsUsed = 0;
  int _maxDailySpins = 5;

  // Enhanced rewards with better variety
  final List<SpinReward> _rewards = [
    SpinReward(
      '5 Coins',
      5,
      const Color(0xFF4CAF50),
      Icons.monetization_on,
      0.25,
    ),
    SpinReward(
      '10 Coins',
      10,
      const Color(0xFF2196F3),
      Icons.monetization_on,
      0.20,
    ),
    SpinReward(
      '15 Coins',
      15,
      const Color(0xFF9C27B0),
      Icons.monetization_on,
      0.18,
    ),
    SpinReward(
      '25 Coins',
      25,
      const Color(0xFFFF9800),
      Icons.monetization_on,
      0.15,
    ),
    SpinReward(
      '50 Coins',
      50,
      const Color(0xFFE91E63),
      Icons.monetization_on,
      0.12,
    ),
    SpinReward('100 Coins', 100, const Color(0xFFFFD700), Icons.stars, 0.08),
    SpinReward('Try Again', 0, const Color(0xFF607D8B), Icons.refresh, 0.01),
    SpinReward(
      'JACKPOT!',
      500,
      const Color(0xFFFF1744),
      Icons.celebration,
      0.01,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentCoins();
    _initializeAnimations();
    _startAmbientAnimations();
  }

  void _loadCurrentCoins() {
    _currentCoins = GameStateService().currentCoins;
    // Load daily spins from preferences (simplified for demo)
    _dailySpinsUsed = 0; // This would be loaded from SharedPreferences
  }

  void _initializeAnimations() {
    // Spin animation - longer and more dramatic
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _spinAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    // Pulse animation for spin button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Glow animation for wheel
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    // Wheel glow animation
    _wheelGlowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _wheelGlowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _wheelGlowController, curve: Curves.easeInOut),
    );

    // Shine animation
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _shineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    // Confetti controller
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  void _startAmbientAnimations() {
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _wheelGlowController.repeat(reverse: true);
    _shineController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _wheelGlowController.dispose();
    _shineController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _spin() async {
    if (!_canSpin || _isSpinning) return;

    // Check daily limit
    if (_dailySpinsUsed >= _maxDailySpins) {
      _showDailyLimitDialog();
      return;
    }

    // Check if user has enough coins
    if (_currentCoins < 10) {
      _showInsufficientCoinsDialog();
      return;
    }

    setState(() {
      _isSpinning = true;
      _canSpin = false;
    });

    // Deduct spin cost
    await GameStateService().spendCoins(10);
    _currentCoins -= 10;
    _dailySpinsUsed++;

    // Enhanced reward selection with weighted probability
    _selectedReward = _getWeightedRandomReward();

    // Calculate the angle to land on the selected reward
    final baseAngle = (_selectedReward * (360 / _rewards.length)) / 360;
    final extraRotations = 4 + math.Random().nextDouble() * 2; // 4-6 rotations
    final finalAngle = extraRotations + baseAngle;

    _spinAnimation = Tween<double>(begin: 0.0, end: finalAngle).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    // Start particle effect
    _particleController.forward();

    // Haptic feedback during spin
    HapticFeedback.mediumImpact();

    _spinController.reset();
    await _spinController.forward();

    // Award the reward
    final reward = _rewards[_selectedReward];

    if (reward.value > 0) {
      await GameStateService().earnCoins(reward.value);
      _currentCoins += reward.value;
    }

    setState(() {
      _isSpinning = false;
    });

    // Enhanced haptic feedback based on reward
    if (reward.value >= 100) {
      HapticFeedback.heavyImpact();
      _confettiController.play();
    } else if (reward.value >= 25) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    _showRewardDialog(reward);

    // Reset particle animation
    _particleController.reset();

    // Allow spinning again after cooldown
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _canSpin = true;
    });
  }

  int _getWeightedRandomReward() {
    final random = math.Random();
    double totalWeight = _rewards.fold(
      0.0,
      (sum, reward) => sum + reward.probability,
    );
    double randomValue = random.nextDouble() * totalWeight;

    double currentWeight = 0.0;
    for (int i = 0; i < _rewards.length; i++) {
      currentWeight += _rewards[i].probability;
      if (randomValue <= currentWeight) {
        return i;
      }
    }

    return 0; // Fallback
  }

  void _showDailyLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildGameDialog(
        title: 'Daily Limit Reached',
        icon: Icons.schedule,
        iconColor: Colors.orange,
        content:
            'You\'ve used all $_maxDailySpins daily spins! Come back tomorrow for more chances to win big!',
        buttonText: 'OK',
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildGameDialog(
        title: 'Not Enough Coins',
        icon: Icons.monetization_on,
        iconColor: Colors.red,
        content:
            'You need 10 coins to spin the wheel. Play trivia games to earn more coins!',
        buttonText: 'Play Trivia',
        onPressed: () {
          Navigator.pop(context);
          // Navigate to trivia game
        },
      ),
    );
  }

  void _showRewardDialog(SpinReward reward) {
    final isJackpot = reward.value >= 500;
    final isBigWin = reward.value >= 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildGameDialog(
        title: isJackpot
            ? 'JACKPOT!'
            : isBigWin
                ? 'BIG WIN!'
                : 'Congratulations!',
        icon: reward.icon,
        iconColor: reward.color,
        content: reward.value > 0
            ? 'You won ${reward.label}!\n\nTotal Coins: $_currentCoins'
            : 'Better luck next time! Keep spinning for amazing rewards!',
        buttonText: 'Awesome!',
        onPressed: () => Navigator.pop(context),
        isJackpot: isJackpot,
      ),
    );
  }

  Widget _buildGameDialog({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
    required String buttonText,
    required VoidCallback onPressed,
    bool isJackpot = false,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isJackpot
                ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                : [iconColor.withOpacity(0.8), iconColor],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.luckiestGuy(
                fontSize: isJackpot ? 28 : 24,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 3,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.white,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomIconButton(
              icon: Icons.check,
              color: Colors.white.withOpacity(0.9),
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with coins and daily spins info
                _buildHeader(),
                const SizedBox(height: 20),

                // Enhanced wheel section
                Expanded(child: Center(child: _buildEnhancedWheel())),

                // Bottom action section
                _buildBottomSection(),
              ],
            ),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                Colors.yellow,
                Colors.orange,
                Colors.purple,
                Colors.pink,
                Colors.cyan,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'LUCKY WHEEL',
            style: GoogleFonts.luckiestGuy(
              fontSize: 28,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 3,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Current coins
              StarCoinCredit(creditAmount: _currentCoins, size: 60),
              // Daily spins remaining
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Daily Spins',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_maxDailySpins - _dailySpinsUsed}/$_maxDailySpins',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Spin cost
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.orange,
                      size: 20,
                    ),
                    Text(
                      '10 Coins',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedWheel() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer atmospheric glow effect
        AnimatedBuilder(
          animation: _wheelGlowAnimation,
          builder: (context, child) {
            return Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  // Large atmospheric glow
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.15 * _wheelGlowAnimation.value),
                    blurRadius: 80,
                    spreadRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                  // Medium magical glow
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.12 * _wheelGlowAnimation.value),
                    blurRadius: 60,
                    spreadRadius: 15,
                    offset: const Offset(0, 0),
                  ),
                  // Inner energy glow
                  BoxShadow(
                    color: const Color(0xFFAA6BFF).withOpacity(0.1 * _wheelGlowAnimation.value),
                    blurRadius: 40,
                    spreadRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            );
          },
        ),

        // Subtle shadow foundation layers
        AnimatedBuilder(
          animation: _shineAnimation,
          builder: (context, child) {
            return Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  // Soft foundation shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 2,
                    offset: const Offset(0, 15),
                  ),
                  // Light depth layer
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 25,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            );
          },
        ),

        // Particle effects during spin
        if (_isSpinning)
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 350,
                height: 350,
                child: CustomPaint(
                  painter: ParticlePainter(_particleAnimation.value),
                ),
              );
            },
          ),

        // Shine effect overlay
        AnimatedBuilder(
          animation: _shineAnimation,
          builder: (context, child) {
            return Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  startAngle: _shineAnimation.value * 2 * math.pi,
                  endAngle: (_shineAnimation.value * 2 * math.pi) + (math.pi / 3),
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                ),
              ),
            );
          },
        ),

        // Enhanced main wheel with lighter shadows
        AnimatedBuilder(
          animation: _spinAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _spinAnimation.value * 2 * math.pi,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Main soft shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                      spreadRadius: -3,
                    ),
                    // Secondary definition shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: -2,
                    ),
                    // Close contact shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: EnhancedWheelPainter(_rewards),
                  size: const Size(300, 300),
                ),
              ),
            );
          },
        ),

        // Rim lighting effect
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 3,
              color: Colors.white.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 0),
                spreadRadius: 0,
              ),
            ],
          ),
        ),

        // Center spin button with enhanced shadows
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _canSpin && !_isSpinning ? _pulseAnimation.value : 1.0,
              child: GestureDetector(
                onTap: _spin,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: _canSpin && !_isSpinning
                          ? [
                              const Color(0xFFFFE57F),
                              const Color(0xFFFFD700),
                              const Color(0xFFFFA500),
                              const Color(0xFFFF8F00),
                            ]
                          : [
                              Colors.grey[300]!,
                              Colors.grey[500]!,
                              Colors.grey[700]!,
                              Colors.grey[900]!,
                            ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                    boxShadow: _canSpin && !_isSpinning
                        ? [
                            // Light button shadow
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                              spreadRadius: -2,
                            ),
                            // Soft depth shadow
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              spreadRadius: -1,
                            ),
                            // Golden glow effect
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 0),
                              spreadRadius: 1,
                            ),
                          ]
                        : [
                            // Disabled button shadows
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                              spreadRadius: -1,
                            ),
                          ],
                  ),
                  child: _isSpinning
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 4,
                          ),
                        )
                      : Center(
                          child: Text(
                            'SPIN',
                            style: GoogleFonts.luckiestGuy(
                              fontSize: 24,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            );
          },
        ),

        // Enhanced pointer/arrow with better shadow
        Positioned(
          top: 0,
          child: Container(
            width: 50,
            height: 50,
            child: CustomPaint(painter: EnhancedPointerPainter()),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              _getStatusMessage(),
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomIconButton(
                icon: Icons.info_outline,
                color: const Color(0xFF2196F3),
                onPressed: _showInfoDialog,
              ),
              CustomIconButton(
                icon: Icons.history,
                color: const Color(0xFF9C27B0),
                onPressed: _showSpinHistory,
              ),
              CustomIconButton(
                icon: Icons.card_giftcard,
                color: const Color(0xFFFF9800),
                onPressed: _showRewards,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusMessage() {
    if (!_canSpin && !_isSpinning) {
      return 'Wait a moment before spinning again...';
    } else if (_dailySpinsUsed >= _maxDailySpins) {
      return 'Daily limit reached! Come back tomorrow for more spins.';
    } else if (_currentCoins < 10) {
      return 'Not enough coins! Play trivia games to earn more.';
    } else {
      return 'Good luck! Spin the wheel to win amazing rewards!';
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildGameDialog(
        title: 'How to Play',
        icon: Icons.help_outline,
        iconColor: const Color(0xFF2196F3),
        content:
            '• Each spin costs 10 coins\n• Daily limit: $_maxDailySpins spins\n• Win coins, jackpots, and more!\n• Play trivia to earn coins',
        buttonText: 'Got it!',
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _showSpinHistory() {
    // This would show recent spin results
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Spin history feature coming soon!',
          style: GoogleFonts.luckiestGuy(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF9C27B0),
      ),
    );
  }

  void _showRewards() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
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
                'Available Rewards',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_rewards.length, (index) {
                final reward = _rewards[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(reward.icon, color: reward.color, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reward.label,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${(reward.probability * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.roboto(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              CustomIconButton(
                icon: Icons.close,
                color: Colors.red,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced Spin Reward class with probability
class SpinReward {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final double probability; // For weighted random selection

  SpinReward(this.label, this.value, this.color, this.icon, this.probability);
}

// Enhanced wheel painter with better visuals and shine effects
class EnhancedWheelPainter extends CustomPainter {
  final List<SpinReward> rewards;

  EnhancedWheelPainter(this.rewards);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sectionAngle = 2 * math.pi / rewards.length;

    for (int i = 0; i < rewards.length; i++) {
      final startAngle = i * sectionAngle - math.pi / 2;

      // Bright section gradient with vibrant colors
      final paint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Colors.white.withOpacity(0.4), // Bright highlight center
            rewards[i].color.withOpacity(0.98),
            rewards[i].color,
            rewards[i].color.withOpacity(0.9),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Enhanced section border with inner highlight
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        borderPaint,
      );

      // Inner border highlight
      final innerBorderPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        startAngle,
        sectionAngle,
        true,
        innerBorderPaint,
      );

      // Text positioning with better shadow
      final textAngle = startAngle + sectionAngle / 2;
      final textRadius = radius * 0.75;

      // Draw text with enhanced shadow
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: rewards[i].label,
          style: GoogleFonts.luckiestGuy(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0.5, 0.5),
              ),
            ],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Enhanced inner circle with 3D effect
    final innerGradient = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.4),
        Colors.white.withOpacity(0.2),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final innerPaint = Paint()
      ..shader = innerGradient.createShader(
        Rect.fromCircle(center: center, radius: radius * 0.3),
      );

    canvas.drawCircle(center, radius * 0.3, innerPaint);

    // Inner rim with metallic effect
    final rimPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius * 0.3, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Enhanced particle effect painter with more variety
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Multiple particle rings for better effect
    for (int ring = 0; ring < 3; ring++) {
      final particleCount = 8 + (ring * 4);
      for (int i = 0; i < particleCount; i++) {
        final angle = (i * (360 / particleCount)) * (math.pi / 180);
        final baseDistance = 70 + (ring * 30);
        final distance = baseDistance + (60 * animationValue);
        final x = center.dx + distance * math.cos(angle);
        final y = center.dy + distance * math.sin(angle);

        final colors = [
          Colors.yellow,
          Colors.orange,
          Colors.pink,
          Colors.purple,
          Colors.cyan,
          Colors.lime,
        ];

        paint.color = colors[i % colors.length].withOpacity(
          (1.0 - animationValue) * (1.0 - ring * 0.2),
        );

        final particleSize = (4 - ring) * (1.0 - animationValue);
        canvas.drawCircle(Offset(x, y), particleSize, paint);

        // Add trailing effect
        if (animationValue > 0.3) {
          for (int trail = 1; trail <= 3; trail++) {
            final trailDistance = distance - (trail * 10);
            final trailX = center.dx + trailDistance * math.cos(angle);
            final trailY = center.dy + trailDistance * math.sin(angle);
            
            paint.color = colors[i % colors.length].withOpacity(
              (1.0 - animationValue) * (1.0 - trail * 0.3) * (1.0 - ring * 0.2),
            );

            canvas.drawCircle(
              Offset(trailX, trailY),
              particleSize * (1.0 - trail * 0.2),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Enhanced pointer painter with 3D effect
class EnhancedPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Main pointer with gradient
    final path = Path();
    path.moveTo(centerX, size.height - 5); // Bottom point (tip)
    path.lineTo(centerX - 18, 5); // Top left
    path.lineTo(centerX + 18, 5); // Top right
    path.close();

    // Gradient paint for pointer
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw lighter shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 4, false);
    canvas.drawShadow(path, Colors.black.withOpacity(0.15), 2, false);

    // Draw the main pointer
    canvas.drawPath(path, gradientPaint);

    // Add lighter border with highlight
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);

    // Inner highlight
    final highlightPath = Path();
    highlightPath.moveTo(centerX, size.height - 8);
    highlightPath.lineTo(centerX - 15, 8);
    highlightPath.lineTo(centerX + 15, 8);
    highlightPath.close();

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}