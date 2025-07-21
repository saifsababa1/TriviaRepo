// lib/star_coin.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class StarCoinCredit extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final int creditAmount;
  final VoidCallback? onTap;

  const StarCoinCredit({
    super.key,
    this.size = 80.0, // Smaller, more efficient size
    this.primaryColor = const Color(0xFFFFD700),
    required this.creditAmount,
    this.onTap,
  });

  @override
  State<StarCoinCredit> createState() => _StarCoinCreditState();
}

class _StarCoinCreditState extends State<StarCoinCredit>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _incrementController;
  late AnimationController _bounceController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _incrementAnimation;
  late Animation<double> _bounceAnimation;

  int _displayedAmount = 0;
  int _previousAmount = 0;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _displayedAmount = widget.creditAmount;
    _previousAmount = widget.creditAmount;

    // Gentle wobble animation (subtle left-right movement)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Floating pulse animation (breathing effect)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Shimmer animation (light reflection)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Increment animation (when value changes)
    _incrementController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Bounce animation (for interaction)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Gentle wobble (small rotation back and forth)
    _rotationAnimation = Tween<double>(
      begin: -0.1, // -5.7 degrees
      end: 0.1, // +5.7 degrees
    ).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Floating pulse (gentle scale change)
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _incrementAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _incrementController, curve: Curves.elasticOut),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Start gentle continuous animations
    _rotationController.repeat(reverse: true); // Wobble back and forth
    _pulseController.repeat(reverse: true); // Gentle breathing

    // Shimmer every few seconds instead of continuous
    _startPeriodicShimmer();
  }

  void _startPeriodicShimmer() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _shimmerController.forward().then((_) {
          _shimmerController.reset();
          _startPeriodicShimmer(); // Repeat every few seconds
        });
      }
    });
  }

  @override
  void didUpdateWidget(StarCoinCredit oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.creditAmount != widget.creditAmount) {
      _previousAmount = oldWidget.creditAmount;

      // Trigger increment animation
      _incrementController.reset();
      _incrementController.forward();

      // Animate the number change
      _animateNumberChange(oldWidget.creditAmount, widget.creditAmount);

      // Haptic feedback for earning coins
      HapticFeedback.mediumImpact();
    }
  }

  void _animateNumberChange(int oldValue, int newValue) {
    if (oldValue == newValue) return;

    // Determine if we're increasing or decreasing
    final isIncreasing = newValue > oldValue;
    final difference = (newValue - oldValue).abs();

    // Calculate optimal duration based on difference
    // Faster for small changes, slower for large changes
    int baseDuration = 800; // Base duration in milliseconds
    if (difference <= 10) {
      baseDuration = 600;
    } else if (difference <= 50) {
      baseDuration = 1000;
    } else if (difference <= 100) {
      baseDuration = 1200;
    } else {
      baseDuration = 1500;
    }

    _incrementController.duration = Duration(milliseconds: baseDuration);

    // Create smooth tween animation for both directions
    final tween = Tween<double>(
      begin: oldValue.toDouble(),
      end: newValue.toDouble(),
    );

    final animation = tween.animate(
      CurvedAnimation(
        parent: _incrementController,
        curve: isIncreasing ? Curves.easeOutCubic : Curves.easeInOutCubic,
      ),
    );

    // Listen to animation updates for smooth counting
    animation.addListener(() {
      setState(() {
        _displayedAmount = animation.value.round();
      });
    });

    // Trigger bounce effect for visual feedback
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    // Start the smooth counting animation
    _incrementController.forward().then((_) {
      _incrementController.reset();
      // Ensure final value is exactly correct
      setState(() {
        _displayedAmount = newValue;
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _incrementController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _bounceController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _bounceController.reverse();

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _bounceController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _pulseAnimation,
        _shimmerAnimation,
        _incrementAnimation,
        _bounceAnimation,
      ]),
      builder: (context, child) {
        final scale = _pulseAnimation.value * _bounceAnimation.value;
        final incrementScale = 1.0 + (_incrementAnimation.value * 0.2);

        return Transform.scale(
          scale: scale * incrementScale,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Very subtle, eye-friendly glow
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(
                        0.15 + (_incrementAnimation.value * 0.1),
                      ),
                      blurRadius: 6 + (_incrementAnimation.value * 2),
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compact coin image with perfect sizing
                    ClipOval(
                      child: Container(
                        width: widget.size * 0.75, // Smaller, more refined
                        height: widget.size * 0.75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
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
                                size: widget.size * 0.35,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Compact, eye-friendly number display
                    Positioned(
                      bottom: widget.size * 0.05,
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: widget.size * 0.3,
                          maxWidth: widget.size * 0.65,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: widget.primaryColor.withOpacity(0.25),
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
                          _displayedAmount.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.luckiestGuy(
                            fontSize: widget.size * 0.12,
                            color: const Color(
                              0xFF2D5016,
                            ), // Dark green, easy on eyes
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

                    // Enhanced periodic shimmer effect over the image
                    // Subtle, eye-friendly shimmer effect
                    Positioned.fill(
                      child: ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment(
                                -1.0 + (_shimmerAnimation.value * 2.0),
                                -1.0,
                              ),
                              end: Alignment(
                                1.0 + (_shimmerAnimation.value * 2.0),
                                1.0,
                              ),
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(
                                  0.12,
                                ), // Very subtle for eye comfort
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
