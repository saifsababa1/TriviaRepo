import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../services/game_state_service.dart';

class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;
  late Animation<double> _spinAnimation;
  late Animation<double> _pulseAnimation;

  bool _isSpinning = false;
  bool _canSpin = true;
  int _selectedReward = 0;
  int _currentCoins = 0;

  final List<SpinReward> _rewards = [
    SpinReward('5 Coins', 5, Colors.green, Icons.monetization_on),
    SpinReward('10 Coins', 10, Colors.blue, Icons.monetization_on),
    SpinReward('15 Coins', 15, Colors.orange, Icons.monetization_on),
    SpinReward('25 Coins', 25, Colors.purple, Icons.monetization_on),
    SpinReward('50 Coins', 50, Colors.red, Icons.monetization_on),
    SpinReward('100 Coins', 100, Colors.yellow[700]!, Icons.stars),
    SpinReward('5 Coins', 5, Colors.green, Icons.monetization_on),
    SpinReward('Lucky!', 200, Colors.pink, Icons.celebration),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentCoins();
    _initializeAnimations();
  }

  void _loadCurrentCoins() {
    _currentCoins = GameStateService().currentCoins;
  }

  void _initializeAnimations() {
    _spinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _spinAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _spin() async {
    if (!_canSpin || _isSpinning) return;

    // Check if user has enough coins to spin (cost: 10 coins)
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

    // Generate random result
    final random = math.Random();
    _selectedReward = random.nextInt(_rewards.length);

    // Calculate the angle to land on the selected reward
    final targetAngle = (_selectedReward * (360 / _rewards.length)) / 360;
    final finalAngle = (3 + targetAngle); // 3 full rotations + target

    _spinAnimation = Tween<double>(begin: 0.0, end: finalAngle).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    _spinController.reset();
    await _spinController.forward();

    // Award the reward
    final reward = _rewards[_selectedReward];
    await GameStateService().earnCoins(reward.value);
    _currentCoins += reward.value;

    setState(() {
      _isSpinning = false;
    });

    HapticFeedback.heavyImpact();
    _showRewardDialog(reward);

    // Allow spinning again after 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      _canSpin = true;
    });
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Not Enough Coins',
              style: GoogleFonts.luckiestGuy(color: const Color(0xFF7B3EFF)),
            ),
            content: Text(
              'You need 10 coins to spin the wheel. Play trivia games to earn more coins!',
              style: GoogleFonts.roboto(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.luckiestGuy(
                    color: const Color(0xFF7B3EFF),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showRewardDialog(SpinReward reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [reward.color.withOpacity(0.8), reward.color],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(reward.icon, size: 60, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Congratulations!',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You won ${reward.label}!',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total Coins: $_currentCoins',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Awesome!',
                      style: GoogleFonts.luckiestGuy(
                        color: reward.color,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Text(
            'Lucky Spin Wheel',
            style: GoogleFonts.luckiestGuy(fontSize: 28, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Cost: 10 coins per spin',
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),

          // Current coins display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.yellow),
                const SizedBox(width: 8),
                Text(
                  '$_currentCoins Coins',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Spin wheel
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Wheel
                  AnimatedBuilder(
                    animation: _spinAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _spinAnimation.value * 2 * math.pi,
                        child: _buildWheel(),
                      );
                    },
                  ),

                  // Center button
                  if (!_isSpinning)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _canSpin ? _pulseAnimation.value : 1.0,
                          child: GestureDetector(
                            onTap: _spin,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors:
                                      _canSpin
                                          ? [
                                            Colors.yellow[400]!,
                                            Colors.orange[600]!,
                                          ]
                                          : [
                                            Colors.grey[400]!,
                                            Colors.grey[600]!,
                                          ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'SPIN',
                                  style: GoogleFonts.luckiestGuy(
                                    fontSize: 18,
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
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  if (_isSpinning)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.grey, Colors.blueGrey],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),

                  // Pointer
                  Positioned(
                    top: -10,
                    child: Container(
                      width: 0,
                      height: 0,
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            width: 15,
                            color: Colors.transparent,
                          ),
                          right: BorderSide(
                            width: 15,
                            color: Colors.transparent,
                          ),
                          bottom: BorderSide(width: 30, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Instructions
          if (!_canSpin && !_isSpinning)
            Text(
              'Wait a moment before spinning again...',
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildWheel() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(
        painter: WheelPainter(_rewards),
        size: const Size(300, 300),
      ),
    );
  }
}

class SpinReward {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  SpinReward(this.label, this.value, this.color, this.icon);
}

class WheelPainter extends CustomPainter {
  final List<SpinReward> rewards;

  WheelPainter(this.rewards);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sectionAngle = 2 * math.pi / rewards.length;

    for (int i = 0; i < rewards.length; i++) {
      final startAngle = i * sectionAngle - math.pi / 2;
      final paint =
          Paint()
            ..color = rewards[i].color
            ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        borderPaint,
      );

      // Draw text
      final textAngle = startAngle + sectionAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: rewards[i].label,
          style: GoogleFonts.luckiestGuy(
            color: Colors.white,
            fontSize: 12,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 2,
                offset: const Offset(1, 1),
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
