// lib/play_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback? onPressed;

  const PlayButton({
    super.key,
    required this.text,
    required this.color,
    this.onPressed,
  });

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Press animation controller
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Start continuous shimmer effect
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
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
    HapticFeedback.mediumImpact();

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
        _shimmerAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            // Outer glow effect
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(_isPressed ? 0.6 : 0.4),
                  blurRadius: _isPressed ? 20 : 15,
                  spreadRadius: _isPressed ? 8 : 4,
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
                    Colors.white.withOpacity(_isPressed ? 0.6 : 0.8),
                    Colors.white.withOpacity(_isPressed ? 0.05 : 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                // Inner button container with shimmer
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.45, 0.55, 1.0],
                    colors:
                        _isPressed
                            ? [
                              Color.lerp(widget.color, Colors.black, 0.1)!,
                              Color.lerp(widget.color, Colors.black, 0.05)!,
                              Color.lerp(widget.color, Colors.black, 0.1)!,
                              Color.lerp(widget.color, Colors.black, 0.3)!,
                            ]
                            : [
                              Color.lerp(widget.color, Colors.white, 0.4)!,
                              Color.lerp(widget.color, Colors.white, 0.3)!,
                              widget.color,
                              Color.lerp(widget.color, Colors.black, 0.2)!,
                            ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withOpacity(_isPressed ? 0.2 : 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    // Inner glow
                    BoxShadow(
                      color: Colors.white.withOpacity(_isPressed ? 0.3 : 0.5),
                      blurRadius: 4,
                      offset: const Offset(-1, -1),
                    ),
                    // Inner shadow
                    BoxShadow(
                      color: Colors.black.withOpacity(_isPressed ? 0.4 : 0.2),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    children: [
                      // Shimmer effect
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(_shimmerAnimation.value * 200, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
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
                          borderRadius: BorderRadius.circular(26),
                          splashColor: Colors.white.withOpacity(0.3),
                          highlightColor: Colors.white.withOpacity(0.1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            child: Text(
                              widget.text.toUpperCase(),
                              style: GoogleFonts.luckiestGuy(
                                color:
                                    _isPressed
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: _isPressed ? 2 : 3,
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
