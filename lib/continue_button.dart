// lib/continue_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ContinueButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback? onPressed;

  const ContinueButton({
    super.key,
    required this.text,
    required this.color,
    this.onPressed,
  });

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Press animation controller
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Wave animation controller
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.bounceOut),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Start continuous wave effect
    _waveController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
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
    HapticFeedback.selectionClick();

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
        _waveAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            // Outer glow effect with wave animation
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(
                    (_isPressed ? 0.7 : 0.5) *
                        (0.3 + 0.2 * _waveAnimation.value),
                  ),
                  blurRadius: _isPressed ? 18 : 12 + (4 * _waveAnimation.value),
                  spreadRadius: _isPressed ? 6 : 3 + (2 * _waveAnimation.value),
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
                    Colors.white.withOpacity(_isPressed ? 0.5 : 0.8),
                    Colors.white.withOpacity(_isPressed ? 0.03 : 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
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
                              Color.lerp(widget.color, Colors.black, 0.15)!,
                              Color.lerp(widget.color, Colors.black, 0.08)!,
                              Color.lerp(widget.color, Colors.black, 0.15)!,
                              Color.lerp(widget.color, Colors.black, 0.35)!,
                            ]
                            : [
                              Color.lerp(widget.color, Colors.white, 0.4)!,
                              Color.lerp(widget.color, Colors.white, 0.3)!,
                              widget.color,
                              Color.lerp(widget.color, Colors.black, 0.2)!,
                            ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(_isPressed ? 0.15 : 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    // Inner glow
                    BoxShadow(
                      color: Colors.white.withOpacity(_isPressed ? 0.2 : 0.5),
                      blurRadius: 4,
                      offset: const Offset(-1, -1),
                    ),
                    // Inner shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(_isPressed ? 0.5 : 0.2),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      // Gradient wave effect
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(
                                  0.1 * _waveAnimation.value,
                                ),
                                Colors.transparent,
                                Colors.white.withOpacity(
                                  0.1 * (1 - _waveAnimation.value),
                                ),
                              ],
                              stops: const [0.0, 0.5, 1.0],
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
                          borderRadius: BorderRadius.circular(14),
                          splashColor: Colors.white.withOpacity(0.4),
                          highlightColor: Colors.white.withOpacity(0.15),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Text(
                              widget.text.toUpperCase(),
                              style: GoogleFonts.luckiestGuy(
                                color:
                                    _isPressed
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1.1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: _isPressed ? 1.5 : 3,
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
