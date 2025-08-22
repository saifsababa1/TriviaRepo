// lib/widgets/enhanced_lucky_wheel_win_animation.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:math';

class EnhancedLuckyWheelWinAnimation extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final int coinAmount;
  final String prizeTitle;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData prizeIcon;
  final bool autoPlay;

  const EnhancedLuckyWheelWinAnimation({
    super.key,
    this.onAnimationComplete,
    required this.coinAmount,
    required this.prizeTitle,
    this.primaryColor = const Color(0xFFFFD700),
    this.secondaryColor = const Color(0xFFFFA500),
    this.prizeIcon = Icons.card_giftcard,
    this.autoPlay = true,
  });

  @override
  State<EnhancedLuckyWheelWinAnimation> createState() =>
      _EnhancedLuckyWheelWinAnimationState();
}

class _EnhancedLuckyWheelWinAnimationState
    extends State<EnhancedLuckyWheelWinAnimation>
    with TickerProviderStateMixin {
  // Master Animation Controllers
  late AnimationController _masterController;
  late AnimationController _coinController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _glowController;
  late AnimationController _shakeController;
  late AnimationController _bounceController;
  late AnimationController _sparkleController;
  late AnimationController _waveController;

  // Stage Animations
  late Animation<double> _stageOpacity;
  late Animation<double> _stageFadeOut;

  // Coin Animations
  late Animation<double> _coinScale;
  late Animation<double> _coinRotation;
  late Animation<double> _coinFloat;
  late Animation<double> _coinGlow;
  late Animation<Offset> _coinPosition;

  // Particle Animations
  late Animation<double> _particleAnimation;
  late Animation<double> _particleOpacity;
  late Animation<double> _particleScale;

  // Text Animations
  late Animation<double> _titleScale;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _amountScale;
  late Animation<double> _amountOpacity;
  late Animation<double> _amountBounce;

  // Background Effects
  late Animation<double> _backgroundPulse;
  late Animation<double> _backgroundRotation;
  late Animation<Color?> _backgroundColorShift;

  // Special Effects
  late Animation<double> _glowIntensity;
  late Animation<double> _shakeOffset;
  late Animation<double> _sparkleRotation;
  late Animation<double> _waveExpansion;
  late Animation<double> _continuousFloat;

  final List<Particle> _particles = [];
  final List<Sparkle> _sparkles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initializeParticles();
    if (widget.autoPlay) {
      _startAnimation();
    }
  }

  // UPDATED: Smoother controller initialization
  void _initializeControllers() {
    // Master controller for overall timing (6 seconds total)
    _masterController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );

    // Smoother coin controller with longer duration
    _coinController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // Gentler background controller
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Disabled shake for smoother movement
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 1),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Animation completion listener
    _masterController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onAnimationComplete?.call();
        });
      }
    });
  }

  // UPDATED: Smoother animation initialization
  void _initializeAnimations() {
    // Stage animations
    _stageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );

    _stageFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
      ),
    );

    // IMPROVED: Much smoother coin animations
    _coinScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _coinController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _coinRotation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _coinController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
      ),
    );

    // Smoother float with gentler easing
    _coinFloat = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _coinController, curve: Curves.easeInOutSine),
    );

    _coinGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _coinController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOutQuad),
      ),
    );

    // Smoother entry position with natural curve
    _coinPosition = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _coinController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuart),
      ),
    );

    // Particle effects
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    _particleOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _particleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Text animations - smoother transitions
    _titleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 0.6, curve: Curves.elasticOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.25, 0.5, curve: Curves.easeIn),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _amountScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.5, 0.8, curve: Curves.elasticOut),
      ),
    );

    _amountOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.45, 0.7, curve: Curves.easeIn),
      ),
    );

    _amountBounce = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // Background effects - gentler pulsing
    _backgroundPulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOutSine,
      ),
    );

    _backgroundRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    _backgroundColorShift = ColorTween(
      begin: widget.primaryColor,
      end: widget.secondaryColor,
    ).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Special effects - smoother
    _glowIntensity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    // REMOVED: Shake animation for smoother movement
    _shakeOffset = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.linear));

    _sparkleRotation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.linear),
    );

    _waveExpansion = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.easeOut));

    // Gentle continuous floating animation
    _continuousFloat = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  void _initializeParticles() {
    // Create confetti particles
    for (int i = 0; i < 50; i++) {
      _particles.add(
        Particle(
          position: Offset(
            _random.nextDouble() * 400 - 200,
            _random.nextDouble() * 600 - 300,
          ),
          velocity: Offset(
            (_random.nextDouble() - 0.5) * 8,
            _random.nextDouble() * -10 - 5,
          ),
          color: _getRandomParticleColor(),
          size: _random.nextDouble() * 15 + 5,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.3,
        ),
      );
    }

    // Create sparkle effects
    for (int i = 0; i < 30; i++) {
      _sparkles.add(
        Sparkle(
          position: Offset(
            _random.nextDouble() * 600 - 300,
            _random.nextDouble() * 800 - 400,
          ),
          scale: _random.nextDouble() * 0.8 + 0.2,
          opacity: _random.nextDouble() * 0.8 + 0.2,
          delay: _random.nextDouble() * 2000,
        ),
      );
    }
  }

  Color _getRandomParticleColor() {
    final colors = [
      widget.primaryColor,
      widget.secondaryColor,
      const Color(0xFFFF6B35),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFD79A8),
      const Color(0xFFFFDD59),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  // UPDATED: Smoother animation start timing
  void _startAnimation() {
    // Trigger haptic feedback
    HapticFeedback.heavyImpact();

    // Start master animation
    _masterController.forward();

    // Gentler background effects
    Future.delayed(const Duration(milliseconds: 150), () {
      _backgroundController.repeat(reverse: true);
    });

    // Smoother coin entrance
    Future.delayed(const Duration(milliseconds: 300), () {
      _coinController.forward();
    });

    // Particle effects with better timing
    Future.delayed(const Duration(milliseconds: 500), () {
      _particleController.forward();
      _glowController.repeat(reverse: true);
    });

    // Text animations
    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
      _sparkleController.repeat();
    });

    // Removed shake animation start for smoother experience

    Future.delayed(const Duration(milliseconds: 1400), () {
      _bounceController.forward();
      _waveController.forward();
    });

    // Gentler haptic feedback
    Future.delayed(const Duration(milliseconds: 1000), () {
      HapticFeedback.lightImpact();
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      HapticFeedback.selectionClick();
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    _coinController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _glowController.dispose();
    _shakeController.dispose();
    _bounceController.dispose();
    _sparkleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _masterController,
        _coinController,
        _particleController,
        _textController,
        _backgroundController,
        _glowController,
        _shakeController,
        _bounceController,
        _sparkleController,
        _waveController,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _stageOpacity.value * _stageFadeOut.value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5 * _backgroundPulse.value,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.95),
                  Colors.black,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Rotating background glow
                _buildRotatingGlow(),

                // Wave expansion effect
                _buildWaveEffect(),

                // Particle system
                _buildParticleSystem(),

                // Sparkle effects
                _buildSparkleSystem(),

                // Main coin animation with integrated prize info
                _buildMainCoinAnimation(),

                // Prize title (separate from coin)
                _buildPrizeTitle(),

                // Coin amount positioned below the title
                _buildCoinAmount(),

                // Celebrate text
                _buildCelebrationText(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRotatingGlow() {
    return Positioned.fill(
      child: Transform.rotate(
        angle: _backgroundRotation.value * math.pi,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.8,
              colors: [
                (_backgroundColorShift.value ?? widget.primaryColor)
                    .withOpacity(0.3 * _glowIntensity.value),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaveEffect() {
    return Positioned.fill(
      child: CustomPaint(
        painter: WaveEffectPainter(
          progress: _waveExpansion.value,
          color: widget.primaryColor,
        ),
      ),
    );
  }

  Widget _buildParticleSystem() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticleSystemPainter(
          particles: _particles,
          progress: _particleAnimation.value,
          opacity: _particleOpacity.value,
          scale: _particleScale.value,
        ),
      ),
    );
  }

  Widget _buildSparkleSystem() {
    return Positioned.fill(
      child: Stack(
        children:
            _sparkles.map((sparkle) {
              return Positioned(
                left:
                    MediaQuery.of(context).size.width / 2 + sparkle.position.dx,
                top:
                    MediaQuery.of(context).size.height / 2 +
                    sparkle.position.dy,
                child: Transform.rotate(
                  angle: _sparkleRotation.value * math.pi + sparkle.delay,
                  child: Transform.scale(
                    scale: sparkle.scale * _particleScale.value,
                    child: Opacity(
                      opacity: sparkle.opacity * _particleOpacity.value,
                      child: Icon(
                        Icons.auto_awesome,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // 🔧 FIXED: Combined coin animation with integrated prize display
  Widget _buildMainCoinAnimation() {
    return Center(
      child: Transform.translate(
        offset: Offset(
          // Smoother horizontal movement - gentle sway
          math.sin(_continuousFloat.value * 2 * math.pi) * 4 +
              math.sin(_coinFloat.value * 1.5 * math.pi) * 2,
          // Smoother vertical movement - natural float
          _coinPosition.value.dy * 100 +
              math.sin(_continuousFloat.value * 1.2 * math.pi) * 8 +
              math.sin(_coinFloat.value * 2.5 * math.pi) * 3,
        ),
        child: Transform.scale(
          scale:
              _coinScale.value *
              (1.0 +
                  math.sin(_continuousFloat.value * 3 * math.pi) *
                      0.02), // Subtle breathing effect
          child: Transform.rotate(
            angle: _coinRotation.value * math.pi,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Coin animation with glow
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(
                          0.8 * _coinGlow.value,
                        ),
                        blurRadius: 40 * _coinGlow.value,
                        spreadRadius: 15 * _coinGlow.value,
                      ),
                      BoxShadow(
                        color: widget.secondaryColor.withOpacity(
                          0.6 * _coinGlow.value,
                        ),
                        blurRadius: 60 * _coinGlow.value,
                        spreadRadius: 25 * _coinGlow.value,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4 * _coinGlow.value),
                        blurRadius: 80 * _coinGlow.value,
                        spreadRadius: 35 * _coinGlow.value,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/animations/XAFuRC7k8g.gif',
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
                ),

                // Coin animation only (no text inside)
                Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔧 FIXED: Prize title positioned with better spacing
  Widget _buildPrizeTitle() {
    return Positioned(
      bottom:
          MediaQuery.of(context).size.height *
          0.15, // Moved higher to make room for coin amount below
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _titleSlide,
        child: Transform.scale(
          scale: _titleScale.value,
          child: Opacity(
            opacity: _titleOpacity.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 60),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.prizeTitle,
                style: GoogleFonts.poppins(
                  fontSize: 20, // Made smaller
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔧 FIXED: Coin amount positioned UNDER the prize title
  Widget _buildCoinAmount() {
    return Positioned(
      bottom:
          MediaQuery.of(context).size.height *
          0.08, // Positioned above "tap anywhere"
      left: 0,
      right: 0,
      child: Transform.scale(
        scale: _amountScale.value * (1.0 + _amountBounce.value * 0.1),
        child: Opacity(
          opacity: _amountOpacity.value,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 60,
            ), // Reduced margin for better fit
            padding: const EdgeInsets.symmetric(
              vertical: 8, // Reduced height
              horizontal: 24,
            ), // Smaller padding for compact design
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.primaryColor.withOpacity(0.9),
                  widget.secondaryColor.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.prizeIcon,
                  color: Colors.white,
                  size: 20,
                ), // Smaller icon
                const SizedBox(width: 6), // Reduced spacing
                Text(
                  '+${widget.coinAmount}',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 24, // Smaller font size for compact design
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationText() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.15,
      left: 0,
      right: 0,
      child: Transform.scale(
        scale: _titleScale.value,
        child: Opacity(
          opacity: _titleOpacity.value,
          child: Column(
            children: [
              Text(
                'CONGRATULATIONS!',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 42,
                  color: widget.primaryColor,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.6),
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    Shadow(
                      color: Colors.white.withOpacity(0.4),
                      offset: const Offset(0, 0),
                      blurRadius: 15,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'You Won Big!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Particle class for confetti effect
class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update(double progress) {
    position += velocity * progress * 2;
    rotation += rotationSpeed * progress * 10;
    velocity = Offset(velocity.dx * 0.98, velocity.dy + 0.2);
  }
}

// Sparkle class for magical effects
class Sparkle {
  final Offset position;
  final double scale;
  final double opacity;
  final double delay;

  Sparkle({
    required this.position,
    required this.scale,
    required this.opacity,
    required this.delay,
  });
}

// Custom painter for particle system
class ParticleSystemPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final double opacity;
  final double scale;

  ParticleSystemPainter({
    required this.particles,
    required this.progress,
    required this.opacity,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      particle.update(progress);

      final paint =
          Paint()
            ..color = particle.color.withOpacity(opacity)
            ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(
        center.dx + particle.position.dx,
        center.dy + particle.position.dy,
      );
      canvas.rotate(particle.rotation);
      canvas.scale(scale);

      // Draw particle as rounded rectangle
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        Radius.circular(particle.size * 0.3),
      );

      canvas.drawRRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for wave effect
class WaveEffectPainter extends CustomPainter {
  final double progress;
  final Color color;

  WaveEffectPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress - i * 0.1).clamp(0.0, 1.0);
      if (waveProgress <= 0) continue;

      final radius = maxRadius * waveProgress;
      final opacity = (1.0 - waveProgress) * 0.3;

      final paint =
          Paint()
            ..color = color.withOpacity(opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Overlay widget to show the full-screen animation
class LuckyWheelWinOverlay extends StatelessWidget {
  final VoidCallback? onComplete;
  final int coinAmount;
  final String prizeTitle;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData prizeIcon;

  const LuckyWheelWinOverlay({
    super.key,
    this.onComplete,
    required this.coinAmount,
    required this.prizeTitle,
    this.primaryColor = const Color(0xFFFFD700),
    this.secondaryColor = const Color(0xFFFFA500),
    this.prizeIcon = Icons.card_giftcard,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: EnhancedLuckyWheelWinAnimation(
        onAnimationComplete: onComplete,
        coinAmount: coinAmount,
        prizeTitle: prizeTitle,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        prizeIcon: prizeIcon,
        autoPlay: true,
      ),
    );
  }
}
