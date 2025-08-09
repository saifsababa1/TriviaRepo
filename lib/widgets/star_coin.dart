// lib/star_coin.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class StarCoinCredit extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final int creditAmount;
  final VoidCallback? onTap;

  const StarCoinCredit({
    super.key,
    this.size = 80.0,
    this.primaryColor = const Color(0xFFFFD700),
    required this.creditAmount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Static coin image (no border, no animation)
            Container(
              width: size * 0.75,
              height: size * 0.75,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Image.asset(
                'assets/images/star_coin.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFE55C),
                          const Color(0xFFFFD700),
                          const Color(0xFFFFA500),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.white.withOpacity(0.9),
                      size: size * 0.35,
                    ),
                  );
                },
              ),
            ),
            // Number display (unchanged)
            Positioned(
              bottom: size * 0.05,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: size * 0.3,
                  maxWidth: size * 0.65,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.25),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  creditAmount.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.luckiestGuy(
                    fontSize: size * 0.12,
                    color: const Color(0xFF2D5016),
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 0.5,
                        offset: const Offset(0, 0.5),
                      ),
                    ],
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

// Game credit system demo
class GameCreditSystem extends StatefulWidget {
  const GameCreditSystem({super.key});

  @override
  State<GameCreditSystem> createState() => _GameCreditSystemState();
}

class _GameCreditSystemState extends State<GameCreditSystem> {
  int _totalCredits = 0;

  void _earnCredits(int amount) {
    setState(() {
      _totalCredits += amount;
    });

    // Show earning feedback
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 You earned $amount coins! Total: $_totalCredits',
          style: GoogleFonts.luckiestGuy(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFD700).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  void _spendCredits(int amount) {
    if (_totalCredits >= amount) {
      setState(() {
        _totalCredits -= amount;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '💸 Spent $amount coins! Remaining: $_totalCredits',
            style: GoogleFonts.luckiestGuy(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(milliseconds: 2000),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Not enough coins! You need $amount but have $_totalCredits',
            style: GoogleFonts.luckiestGuy(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.orange.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(milliseconds: 2000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Star Credits System',
            style: GoogleFonts.luckiestGuy(
              fontSize: 20, // Smaller, more efficient
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
          const SizedBox(height: 16), // Reduced spacing
          // Compact, efficient coin display
          StarCoinCredit(
            creditAmount: _totalCredits,
            size: 85, // Optimal size for mobile
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'You have $_totalCredits star credits! 🌟',
                    style: GoogleFonts.luckiestGuy(fontSize: 14),
                  ),
                  backgroundColor: const Color(0xFFFFD700),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),

          const SizedBox(height: 16), // Reduced spacing
          // Game actions with smooth transitions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Earn credits button
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _totalCredits += 25; // Smooth increase
                  });
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Earn +25',
                  style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              // Spend credits button for smooth decrease
              ElevatedButton.icon(
                onPressed:
                    _totalCredits >= 10
                        ? () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _totalCredits = (_totalCredits - 10).clamp(
                              0,
                              _totalCredits,
                            ); // Smooth decrease
                          });
                        }
                        : null,
                icon: const Icon(Icons.remove, color: Colors.white),
                label: Text(
                  'Spend -10',
                  style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _totalCredits >= 10
                          ? const Color(0xFFFF5722)
                          : Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Large change buttons for testing smooth animations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _totalCredits += 100; // Large smooth increase
                  });
                },
                child: Text(
                  'Big Win +100',
                  style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              ElevatedButton(
                onPressed:
                    _totalCredits >= 50
                        ? () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _totalCredits = (_totalCredits - 50).clamp(
                              0,
                              _totalCredits,
                            ); // Large smooth decrease
                          });
                        }
                        : null,
                child: Text(
                  'Big Spend -50',
                  style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _totalCredits >= 50
                          ? const Color(0xFFE91E63)
                          : Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
