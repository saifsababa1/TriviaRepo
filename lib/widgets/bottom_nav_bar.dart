import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;
  int _pressedIndex = -1;

  // Swipe detection variables
  double _swipeStartX = 0;
  bool _isSwipeInProgress = false;
  static const double _swipeThreshold = 50.0; // Minimum distance for swipe

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 120), // Faster for responsiveness
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98, // Subtle press effect
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Much faster indicator animation
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 350), // Faster navigation
      vsync: this,
    );
    _indicatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _indicatorController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _indicatorController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  void _onItemPressed(int index) {
    setState(() {
      _pressedIndex = index;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
      setState(() {
        _pressedIndex = -1;
      });
    });

    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _swipeStartX = details.globalPosition.dx;
        _isSwipeInProgress = true;
      },
      onPanUpdate: (details) {
        if (!_isSwipeInProgress) return;

        double currentX = details.globalPosition.dx;
        double deltaX = currentX - _swipeStartX;

        // Only process significant movements
        if (deltaX.abs() > 10) {
          // Visual feedback during swipe (optional - can add indicator movement)
        }
      },
      onPanEnd: (details) {
        if (!_isSwipeInProgress) return;

        double currentX = details.globalPosition.dx;
        double deltaX = currentX - _swipeStartX;
        double velocity = details.velocity.pixelsPerSecond.dx;

        // Reset swipe state
        _isSwipeInProgress = false;

        // Determine swipe direction and threshold
        bool shouldSwipe = false;
        int direction = 0;

        if (deltaX > _swipeThreshold || velocity > 500) {
          // Swipe right - go to previous item
          direction = -1;
          shouldSwipe = true;
        } else if (deltaX < -_swipeThreshold || velocity < -500) {
          // Swipe left - go to next item
          direction = 1;
          shouldSwipe = true;
        }

        if (shouldSwipe) {
          _handleSwipe(direction);
        }
      },
      onPanCancel: () {
        _isSwipeInProgress = false;
      },
      child: Container(
        height: 85,
        width: double.infinity,
        decoration: BoxDecoration(
          // Enhanced 2D elevated look with multiple shadow layers
          boxShadow: [
            // Primary shadow for main elevation
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 25,
              offset: const Offset(0, 12),
              spreadRadius: 0,
            ),
            // Secondary shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            // Tertiary shadow for subtle depth
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
            // Top highlight for 2D elevated effect
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 2,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
            // Inner highlight for glass effect
            BoxShadow(
              color: Colors.white.withOpacity(0.6),
              blurRadius: 1,
              offset: const Offset(0, -1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            // Transparent background similar to chest cards
            color: Colors.white.withOpacity(0.10),
            // Enhanced border for 2D elevated effect
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
              width: 1,
            ),
          ),
          child: ClipRect(
            child: Stack(
              children: [
                // Full coverage sliding indicator
                AnimatedBuilder(
                  animation: _indicatorAnimation,
                  builder: (context, child) {
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                      left: MediaQuery.of(context).size.width / 5 * widget.currentIndex,
                      top: 0,
                      bottom: 0,
                      width: MediaQuery.of(context).size.width / 5,
                      child: Container(
                        margin: EdgeInsets.zero,
                                                 decoration: BoxDecoration(
                           color: _getCurrentColor().withOpacity(0.15),
                           border: Border.all(
                             color: _getCurrentColor().withOpacity(0.3),
                             width: 1,
                           ),
                           boxShadow: [
                             BoxShadow(
                               color: _getCurrentColor().withOpacity(0.2),
                               blurRadius: 6,
                               offset: const Offset(0, 2),
                             ),
                           ],
                         ),
                      ),
                    );
                  },
                ),

                // Navigation items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      0,
                      Icons.casino,
                      'SPIN',
                      const Color(0xFF00BCD4),
                    ),
                    _buildNavItem(
                      1,
                      Icons.leaderboard,
                      'LEADERBOARD',
                      const Color(0xFFFFD700),
                    ),
                    _buildNavItem(
                      2,
                      Icons.home_rounded,
                      'HOME',
                      const Color(0xFF4CAF50),
                    ),
                    _buildNavItem(
                      3,
                      Icons.emoji_events,
                      'AWARDS',
                      const Color(0xFFFFA500),
                    ),
                    _buildNavItem(
                      4,
                      Icons.settings,
                      'SETTINGS',
                      const Color(0xFF9C27B0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSwipe(int direction) {
    int newIndex = widget.currentIndex + direction;

    // Check boundaries
    if (newIndex >= 0 && newIndex <= 4) {
      HapticFeedback.lightImpact(); // Haptic feedback for swipe
      widget.onTap(newIndex);
    } else {
      // Boundary reached - provide different haptic feedback
      HapticFeedback.mediumImpact();
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color color) {
    final isSelected = widget.currentIndex == index;
    final isPressed = _pressedIndex == index;

    return Expanded(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isPressed ? _scaleAnimation.value : 1.0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onItemPressed(index),
                onTapDown: (_) {
                  setState(() {
                    _pressedIndex = index;
                  });
                  _animationController.forward();
                },
                onTapUp: (_) {
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (mounted) _animationController.reverse();
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _pressedIndex = -1;
                  });
                  _animationController.reverse();
                },
                splashColor: color.withOpacity(0.1), // Subtle splash effect
                highlightColor: color.withOpacity(0.05), // Subtle highlight
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ), // Internal padding only
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon container with perfect sizing
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: isSelected ? 48 : 42,
                        height: isSelected ? 48 : 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                                                     color: isSelected
                               ? color.withOpacity(0.25)
                               : Colors.white.withOpacity(0.15),
                                                     boxShadow: [
                             BoxShadow(
                               color: isSelected
                                   ? color.withOpacity(0.3)
                                   : Colors.black.withOpacity(0.1),
                               blurRadius: isSelected ? 8.0 : 4.0,
                               offset: const Offset(0, 2),
                               spreadRadius: 0,
                             ),
                           ],
                        ),
                        child: AnimatedScale(
                          scale: isPressed ? 0.9 : 1.0,
                          duration: const Duration(milliseconds: 120),
                          curve: Curves.easeInOut,
                          child: Icon(
                            icon,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: isSelected ? 24 : 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Text with consistent styling
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: isSelected ? 10 : 9,
                          color: isSelected ? color : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                          shadows:
                              isSelected
                                  ? [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.8),
                                      blurRadius: 1,
                                      offset: const Offset(0, 0.5),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Text(label, textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCurrentColor() {
    switch (widget.currentIndex) {
      case 0:
        return const Color(0xFF00BCD4); // Spin
      case 1:
        return const Color(0xFFFFD700); // Leaderboard
      case 2:
        return const Color(0xFF4CAF50); // Home (center)
      case 3:
        return const Color(0xFFFFA500); // Awards
      case 4:
        return const Color(0xFF9C27B0); // Settings
      default:
        return const Color(0xFF4CAF50);
    }
  }
}
