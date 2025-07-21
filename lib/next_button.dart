// lib/next_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class NextButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback? onPressed;

  const NextButton({
    super.key,
    required this.text,
    required this.color,
    this.onPressed,
  });

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Press animation controller
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 140),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Sparkle animation controller
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    // Start continuous sparkle effect
    _sparkleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    _pulseController.forward().then((_) => _pulseController.reverse());
    HapticFeedback.heavyImpact();

    // Play system sound
    SystemSound.play(SystemSoundType.click);

    // Call the callback
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _pulseAnimation,
        _sparkleAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            // Outer glow effect
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(
                    (_isPressed ? 0.8 : 0.6) *
                        (0.5 + 0.3 * _sparkleAnimation.value),
                  ),
                  blurRadius:
                      _isPressed ? 25 : 15 + (5 * _sparkleAnimation.value),
                  spreadRadius:
                      _isPressed ? 8 : 4 + (2 * _sparkleAnimation.value),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              // Middle container for beveled edge
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(_isPressed ? 0.4 : 0.8),
                    Colors.white.withOpacity(_isPressed ? 0.02 : 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                // Inner button container
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.45, 0.55, 1.0],
                    colors:
                        _isPressed
                            ? [
                              Color.lerp(widget.color, Colors.black, 0.2)!,
                              Color.lerp(widget.color, Colors.black, 0.1)!,
                              Color.lerp(widget.color, Colors.black, 0.2)!,
                              Color.lerp(widget.color, Colors.black, 0.4)!,
                            ]
                            : [
                              Color.lerp(widget.color, Colors.white, 0.4)!,
                              Color.lerp(widget.color, Colors.white, 0.3)!,
                              widget.color,
                              Color.lerp(widget.color, Colors.black, 0.2)!,
                            ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(_isPressed ? 0.1 : 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    // Inner glow
                    BoxShadow(
                      color: Colors.white.withOpacity(_isPressed ? 0.15 : 0.5),
                      blurRadius: 4,
                      offset: const Offset(-1, -1),
                    ),
                    // Inner shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(_isPressed ? 0.6 : 0.2),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      // Sparkle highlight effect
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(
                                  0.2 * _sparkleAnimation.value,
                                ),
                                Colors.transparent,
                                Colors.white.withOpacity(
                                  0.15 * (1 - _sparkleAnimation.value),
                                ),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.3, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Main button content
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTapDown: _handleTapDown,
                          onTapUp: _handleTapUp,
                          onTapCancel: _handleTapCancel,
                          borderRadius: BorderRadius.circular(18),
                          splashColor: Colors.white.withOpacity(0.5),
                          highlightColor: Colors.white.withOpacity(0.2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.text.toUpperCase(),
                                  style: GoogleFonts.luckiestGuy(
                                    color:
                                        _isPressed
                                            ? Colors.white.withOpacity(0.6)
                                            : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: _isPressed ? 1 : 3,
                                        offset: const Offset(1, 1),
                                      ),
                                      Shadow(
                                        color: Colors.white24,
                                        blurRadius: 2,
                                        offset: const Offset(-1, -1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Transform.scale(
                                  scale: 1.0 + (0.2 * _sparkleAnimation.value),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color:
                                        _isPressed
                                            ? Colors.white.withOpacity(0.6)
                                            : Colors.white,
                                    size: 18,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: _isPressed ? 1 : 3,
                                        offset: const Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
