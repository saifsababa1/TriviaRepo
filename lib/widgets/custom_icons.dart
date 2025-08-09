// lib/custom_icons.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class CustomIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.color,
    this.onPressed,
    this.tooltip,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Rotation animation controller (for certain icons)
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start continuous animations based on icon type
    if (_isRotatingIcon()) {
      _rotationController.repeat();
    }
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  bool _isRotatingIcon() {
    return widget.icon == Icons.settings ||
        widget.icon == Icons.refresh ||
        widget.icon == Icons.cached;
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

    // Different haptic feedback based on icon type
    if (widget.icon == Icons.close) {
      HapticFeedback.heavyImpact();
    } else if (widget.icon == Icons.check) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

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
        _rotationAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _pulseAnimation.value,
          child: Container(
            width: 64,
            height: 64,
            // Outer glow effect that changes based on icon
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(
                    (_isPressed ? 0.8 : 0.6) *
                        (0.3 + 0.4 * _glowAnimation.value),
                  ),
                  blurRadius: _isPressed ? 20 : 12 + (6 * _glowAnimation.value),
                  spreadRadius: _isPressed ? 6 : 2 + (3 * _glowAnimation.value),
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
                shape: BoxShape.circle,
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
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(_isPressed ? 0.2 : 0.3),
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
                child: ClipOval(
                  child: Stack(
                    children: [
                      // Animated highlight effect
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(
                                  0.3 * _glowAnimation.value,
                                ),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Main icon content
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTapDown: _handleTapDown,
                          onTapUp: _handleTapUp,
                          onTapCancel: _handleTapCancel,
                          customBorder: const CircleBorder(),
                          splashColor: Colors.white.withOpacity(0.4),
                          highlightColor: Colors.white.withOpacity(0.1),
                          child: Center(
                            child: Transform.rotate(
                              angle:
                                  _isRotatingIcon()
                                      ? _rotationAnimation.value
                                      : 0,
                              child: Icon(
                                widget.icon,
                                color:
                                    _isPressed
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.white,
                                size: 28,
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

class CustomIconsRow extends StatefulWidget {
  const CustomIconsRow({super.key});

  @override
  State<CustomIconsRow> createState() => _CustomIconsRowState();
}

class _CustomIconsRowState extends State<CustomIconsRow> {
  int _iconClicks = 0;
  String _lastIconPressed = '';

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.luckiestGuy(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _onIconPressed(String iconName, Color color) {
    setState(() {
      _iconClicks++;
      _lastIconPressed = iconName;
    });

    String emoji = '';
    switch (iconName) {
      case 'Close':
        emoji = '❌';
        break;
      case 'Check':
        emoji = '✅';
        break;
      case 'Settings':
        emoji = '⚙️';
        break;
      case 'Home':
        emoji = '🏠';
        break;
      case 'Up':
        emoji = '⬆️';
        break;
      case 'Menu':
        emoji = '📋';
        break;
    }

    _showSnackBar('$emoji $iconName clicked! ($_iconClicks total)', color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats card for icons
        Card(
          color: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '🎯 Interactive Icons',
                  style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 18,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 3,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last: $_lastIconPressed | Total: $_iconClicks',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Responsive icon row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconButton(
                icon: Icons.close,
                color: Colors.red,
                onPressed: () => _onIconPressed('Close', Colors.red),
                tooltip: 'Close',
              ),
              const SizedBox(width: 16),
              CustomIconButton(
                icon: Icons.check,
                color: Colors.green,
                onPressed: () => _onIconPressed('Check', Colors.green),
                tooltip: 'Check',
              ),
              const SizedBox(width: 16),
              CustomIconButton(
                icon: Icons.settings,
                color: Colors.purple,
                onPressed: () => _onIconPressed('Settings', Colors.purple),
                tooltip: 'Settings',
              ),
              const SizedBox(width: 16),
              CustomIconButton(
                icon: Icons.home,
                color: Colors.orange,
                onPressed: () => _onIconPressed('Home', Colors.orange),
                tooltip: 'Home',
              ),
              const SizedBox(width: 16),
              CustomIconButton(
                icon: Icons.arrow_upward,
                color: Colors.cyan,
                onPressed: () => _onIconPressed('Up', Colors.cyan),
                tooltip: 'Up',
              ),
              const SizedBox(width: 16),
              CustomIconButton(
                icon: Icons.menu,
                color: Colors.pink,
                onPressed: () => _onIconPressed('Menu', Colors.pink),
                tooltip: 'Menu',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
