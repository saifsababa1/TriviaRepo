// lib/screens/awards_screen_enhanced.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class GiftCard {
  final String title;
  final String subtitle;
  final int coinPrice;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String imageAsset;
  final List<int> denominations;
  final String category;
  final bool isPopular;
  final double discountPercent;

  GiftCard({
    required this.title,
    required this.subtitle,
    required this.coinPrice,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.imageAsset,
    required this.category,
    this.denominations = const [10, 25, 50, 100],
    this.isPopular = false,
    this.discountPercent = 0,
  });
}

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen>
    with TickerProviderStateMixin {
  // Enhanced animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shineController;
  late AnimationController _floatingController;
  late AnimationController _bounceController;
  late AnimationController _indicatorController;
  late AnimationController _tabContentController;
  late AnimationController _sparkleController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  // Enhanced animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shineAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _indicatorAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _contentScaleAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  int _currentCoins = 2500;
  int _selectedCategory = 0;

  final List<String> _categories = [
    'All Cards',
    'Gaming',
    'Shopping',
    'Entertainment',
    'Tech',
  ];

  // Responsive category names for smaller screens
  List<String> _getResponsiveCategories(double screenWidth) {
    if (screenWidth < 320) {
      return ['All', 'Game', 'Shop', 'Enter', 'Tech'];
    } else if (screenWidth < 400) {
      return ['All Cards', 'Gaming', 'Shopping', 'Enter', 'Tech'];
    } else if (screenWidth < 480) {
      return ['All Cards', 'Gaming', 'Shopping', 'Entertainment', 'Tech'];
    } else {
      return _categories;
    }
  }

  // Responsive font size based on screen width
  double _getResponsiveFontSize(double screenWidth) {
    if (screenWidth < 320) {
      return 10.0;
    } else if (screenWidth < 400) {
      return 11.0;
    } else if (screenWidth < 480) {
      return 12.0;
    } else {
      return 13.0;
    }
  }

  late List<GiftCard> _giftCards;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGiftCards();
    _loadUserCoins();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Enhanced animation controllers with different durations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _shineController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _tabContentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Enhanced animations with sophisticated curves
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _shineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shineController, curve: Curves.linear));

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _indicatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _indicatorController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _updateTabContentAnimations();
  }

  void _updateTabContentAnimations() {
    _contentSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _tabContentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tabContentController, curve: Curves.easeInOut),
    );

    _contentScaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _tabContentController, curve: Curves.easeOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _shineController.repeat();
    _floatingController.repeat(reverse: true);
    _sparkleController.repeat();
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
    _indicatorController.forward();
    _tabContentController.forward();
  }

  void _initializeGiftCards() {
    _giftCards = [
      // Gaming Cards
      GiftCard(
        title: 'Google Play',
        subtitle: 'Games, Apps & More',
        coinPrice: 1000,
        primaryColor: const Color(0xFF4285F4),
        secondaryColor: const Color(0xFF34A853),
        icon: Icons.play_arrow_rounded,
        imageAsset: 'assets/images/google_play.png',
        category: 'Gaming',
        isPopular: true,
        denominations: [10, 25, 50, 100],
      ),
      GiftCard(
        title: 'App Store',
        subtitle: 'iOS Apps & Games',
        coinPrice: 1000,
        primaryColor: const Color(0xFF007AFF),
        secondaryColor: const Color(0xFF5856D6),
        icon: Icons.apple,
        imageAsset: 'assets/images/app_store.png',
        category: 'Gaming',
        denominations: [10, 25, 50, 100],
      ),
      GiftCard(
        title: 'PUBG Mobile',
        subtitle: 'UC & Battle Pass',
        coinPrice: 800,
        primaryColor: const Color(0xFFFF6B35),
        secondaryColor: const Color(0xFFFF8F00),
        icon: Icons.sports_esports_rounded,
        imageAsset: 'assets/images/pubg.png',
        category: 'Gaming',
        discountPercent: 20,
        denominations: [5, 10, 20, 50],
      ),
      GiftCard(
        title: 'Steam',
        subtitle: 'PC Gaming Platform',
        coinPrice: 1200,
        primaryColor: const Color(0xFF1b2838),
        secondaryColor: const Color(0xFF2a475e),
        icon: Icons.computer_rounded,
        imageAsset: 'assets/images/steam.png',
        category: 'Gaming',
        denominations: [20, 50, 100],
      ),

      // Shopping Cards
      GiftCard(
        title: 'PayPal',
        subtitle: 'Digital Payments',
        coinPrice: 1200,
        primaryColor: const Color(0xFF0070BA),
        secondaryColor: const Color(0xFF003087),
        icon: Icons.payment_rounded,
        imageAsset: 'assets/images/paypal.png',
        category: 'Shopping',
        isPopular: true,
        denominations: [10, 25, 50, 100, 200],
      ),
      GiftCard(
        title: 'Amazon',
        subtitle: 'Everything Store',
        coinPrice: 1100,
        primaryColor: const Color(0xFFFF9900),
        secondaryColor: const Color(0xFFE47911),
        icon: Icons.shopping_cart_rounded,
        imageAsset: 'assets/images/amazon.png',
        category: 'Shopping',
        denominations: [25, 50, 100, 200],
      ),

      // Entertainment Cards
      GiftCard(
        title: 'Netflix',
        subtitle: 'Movies & TV Shows',
        coinPrice: 1500,
        primaryColor: const Color(0xFFE50914),
        secondaryColor: const Color(0xFF831010),
        icon: Icons.movie_rounded,
        imageAsset: 'assets/images/netflix.png',
        category: 'Entertainment',
        denominations: [15, 30, 60],
      ),
      GiftCard(
        title: 'Spotify',
        subtitle: 'Music Streaming',
        coinPrice: 900,
        primaryColor: const Color(0xFF1DB954),
        secondaryColor: const Color(0xFF1AA34A),
        icon: Icons.music_note_rounded,
        imageAsset: 'assets/images/spotify.png',
        category: 'Entertainment',
        discountPercent: 15,
        denominations: [10, 30, 60],
      ),

      // Tech Cards
      GiftCard(
        title: 'Microsoft',
        subtitle: 'Office & Xbox',
        coinPrice: 1300,
        primaryColor: const Color(0xFF0078D4),
        secondaryColor: const Color(0xFF106EBE),
        icon: Icons.computer,
        imageAsset: 'assets/images/microsoft.png',
        category: 'Tech',
        denominations: [25, 50, 100],
      ),
    ];
  }

  void _loadUserCoins() {
    setState(() {
      _currentCoins = 2500;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _shineController.dispose();
    _floatingController.dispose();
    _bounceController.dispose();
    _indicatorController.dispose();
    _tabContentController.dispose();
    _sparkleController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(int index) {
    if (_selectedCategory != index) {
      setState(() {
        _selectedCategory = index;
      });

      _tabContentController.reset();
      _tabContentController.forward();

      _bounceController.reset();
      _bounceController.forward();

      _indicatorController.reset();
      _indicatorController.forward();

      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildEnhancedHeader(),
                  const SizedBox(height: 8),
                  _buildEnhancedCategoryTabs(),
                  const SizedBox(height: 8),
                  // Enhanced content transition with fade effect
                  AnimatedBuilder(
                    animation: _tabContentController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _contentFadeAnimation,
                        child: _buildEnhancedGiftCardsGrid(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.10),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([
                  _floatingController,
                  _pulseController,
                ]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      math.sin(_floatingAnimation.value * 2 * math.pi) * 4,
                    ),
                    child: Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFFD700),
                              const Color(0xFFFFA500),
                              const Color(0xFFFF8C00),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.6),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFA500).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: AnimatedBuilder(
                          animation: _sparkleController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Sparkle effect
                                Transform.rotate(
                                  angle: _sparkleAnimation.value * 2 * math.pi,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white.withOpacity(0.3),
                                    size: 36,
                                  ),
                                ),
                                const Icon(
                                  Icons.card_giftcard_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gift Card Store',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 32,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                          Shadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Redeem your coins for amazing rewards',
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildEnhancedCoinBalance(),
        ],
      ),
    );
  }

  Widget _buildEnhancedCoinBalance() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_shineController, _rotateController]),
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value * 2 * math.pi * 0.1,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      colors: [
                        const Color(0xFFFFD700),
                        const Color(0xFFFFA500),
                        const Color(0xFFFFD700),
                        const Color(0xFFFFA500),
                      ],
                      stops: const [0.0, 0.25, 0.5, 1.0],
                      transform: GradientRotation(
                        _shineAnimation.value * 2 * math.pi,
                      ),
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.6),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFA500).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.98 + (_pulseAnimation.value * 0.02),
                    child: Text(
                      '$_currentCoins',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 36,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(1, 1),
                          ),
                          Shadow(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Text(
                'coins available',
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children:
              _categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final isSelected = _selectedCategory == index;

                return Container(
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 8,
                    right: index == _categories.length - 1 ? 16 : 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onCategoryChanged(index),
                      borderRadius: BorderRadius.circular(28),
                      splashColor: const Color(0xFF6366F1).withOpacity(0.2),
                      highlightColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected
                                  ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                      Color(0xFFA855F7),
                                    ],
                                  )
                                  : null,
                          color:
                              isSelected
                                  ? null
                                  : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF6366F1,
                                      ).withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: const Color(
                                        0xFF8B5CF6,
                                      ).withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 0),
                                    ),
                                  ]
                                  : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                        ),
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _bounceController,
                            _indicatorController,
                          ]),
                          builder: (context, child) {
                            final scale =
                                isSelected
                                    ? 1.0 + (_bounceAnimation.value * 0.05)
                                    : 1.0;

                            return Transform.scale(
                              scale: scale,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Category icon
                                  Icon(
                                    _getCategoryIcon(category),
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  // Category text
                                  Text(
                                    category,
                                    style: GoogleFonts.poppins(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.white,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                      fontSize: 14,
                                      letterSpacing: isSelected ? 0.2 : 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all cards':
        return Icons.all_inclusive;
      case 'gaming':
        return Icons.sports_esports;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'tech':
        return Icons.computer;
      default:
        return Icons.category;
    }
  }

  Widget _buildEnhancedGiftCardsGrid() {
    final filteredCards = _getFilteredCards();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (int i = 0; i < filteredCards.length; i += 2)
            _buildStaggeredRow(filteredCards, i),
        ],
      ),
    );
  }

  Widget _buildStaggeredRow(List<GiftCard> cards, int startIndex) {
    return AnimatedBuilder(
      animation: _tabContentController,
      builder: (context, _) {
        final delay = (startIndex * 0.15).clamp(0.0, 0.8);
        final progress = (_tabContentController.value - delay).clamp(0.0, 1.0);
        final adjustedProgress = (progress / (1.0 - delay)).clamp(0.0, 1.0);

        return Opacity(
          opacity: adjustedProgress,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildEnhancedGiftCardItem(
                    cards[startIndex],
                    startIndex,
                  ),
                ),
                if (startIndex + 1 < cards.length) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEnhancedGiftCardItem(
                      cards[startIndex + 1],
                      startIndex + 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<GiftCard> _getFilteredCards() {
    if (_selectedCategory == 0) return _giftCards;

    final categoryName = _categories[_selectedCategory];
    return _giftCards.where((card) => card.category == categoryName).toList();
  }

  Widget _buildEnhancedGiftCardItem(GiftCard card, int index) {
    final canAfford = _currentCoins >= card.coinPrice;

    return AnimatedBuilder(
      animation: Listenable.merge([_floatingController, _pulseController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            math.sin((_floatingAnimation.value * 2 * math.pi) + (index * 0.5)) *
                3,
          ),
          child: GestureDetector(
            onTap: () => _showPurchaseDialog(card),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    card.primaryColor.withOpacity(0.95),
                    card.secondaryColor.withOpacity(0.85),
                    card.primaryColor.withOpacity(0.7),
                  ],
                ),
                border: Border.all(
                  color:
                      canAfford
                          ? Colors.white.withOpacity(0.5)
                          : Colors.red.withOpacity(0.7),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: card.primaryColor.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: card.secondaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated gradient overlay
                  AnimatedBuilder(
                    animation: _shineController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(
                                0.1 * _shineAnimation.value,
                              ),
                              Colors.transparent,
                              Colors.white.withOpacity(
                                0.05 * _shineAnimation.value,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Popular badge with enhanced animation
                  if (card.isPopular)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value * 0.1 + 0.9,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFFA500),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFD700,
                                    ).withOpacity(0.6),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                'POPULAR',
                                style: GoogleFonts.roboto(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Enhanced discount badge
                  if (card.discountPercent > 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: AnimatedBuilder(
                        animation: _sparkleController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle:
                                math.sin(
                                  _sparkleAnimation.value * 2 * math.pi,
                                ) *
                                0.1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE53E3E),
                                    Color(0xFFDD6B20),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFE53E3E,
                                    ).withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${card.discountPercent.toInt()}% OFF',
                                style: GoogleFonts.roboto(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Enhanced main content
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            AnimatedBuilder(
                              animation: _rotateController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle:
                                      _rotateAnimation.value *
                                      2 *
                                      math.pi *
                                      0.05,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.3),
                                          Colors.white.withOpacity(0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      card.icon,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            Text(
                              card.title,
                              style: GoogleFonts.luckiestGuy(
                                fontSize: 18,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 3,
                                    offset: const Offset(1, 1),
                                  ),
                                  Shadow(
                                    color: card.primaryColor.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              card.subtitle,
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.98 + (_pulseAnimation.value * 0.02),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.25),
                                          Colors.white.withOpacity(0.15),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.monetization_on,
                                          color: Color(0xFFFFD700),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${card.coinPrice}',
                                          style: GoogleFonts.luckiestGuy(
                                            fontSize: 16,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 2,
                                                offset: const Offset(1, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    canAfford
                                        ? () => _showPurchaseDialog(card)
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      canAfford
                                          ? Colors.white
                                          : Colors.grey[400],
                                  foregroundColor:
                                      canAfford
                                          ? card.primaryColor
                                          : Colors.grey[600],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: canAfford ? 6 : 0,
                                  shadowColor:
                                      canAfford
                                          ? card.primaryColor.withOpacity(0.3)
                                          : null,
                                ),
                                child: Text(
                                  canAfford ? 'Buy Now' : 'Not Enough',
                                  style: GoogleFonts.roboto(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPurchaseDialog(GiftCard card) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 20,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    card.primaryColor.withOpacity(0.95),
                    card.secondaryColor.withOpacity(0.9),
                    card.primaryColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: card.primaryColor.withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(card.icon, color: Colors.white, size: 52),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Purchase ${card.title}',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 26,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Amount:',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children:
                        card.denominations.map((amount) {
                          final totalCost =
                              (card.coinPrice * amount / 10).round();
                          final canAfford = _currentCoins >= totalCost;

                          return GestureDetector(
                            onTap:
                                canAfford
                                    ? () =>
                                        _purchaseCard(card, amount, totalCost)
                                    : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient:
                                    canAfford
                                        ? const LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Color(0xFFF8F9FA),
                                          ],
                                        )
                                        : null,
                                color: !canAfford ? Colors.grey[500] : null,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color:
                                      canAfford
                                          ? Colors.white
                                          : Colors.grey[500]!,
                                  width: 2.5,
                                ),
                                boxShadow:
                                    canAfford
                                        ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.15,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                          BoxShadow(
                                            color: card.primaryColor
                                                .withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 0),
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '\$$amount',
                                    style: GoogleFonts.luckiestGuy(
                                      fontSize: 18,
                                      color:
                                          canAfford
                                              ? card.primaryColor
                                              : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.monetization_on,
                                        size: 16,
                                        color:
                                            canAfford
                                                ? const Color(0xFFFFD700)
                                                : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$totalCost',
                                        style: GoogleFonts.roboto(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              canAfford
                                                  ? card.primaryColor
                                                  : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.25),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _purchaseCard(GiftCard card, int amount, int cost) {
    if (_currentCoins >= cost) {
      setState(() {
        _currentCoins -= cost;
      });

      Navigator.pop(context);
      HapticFeedback.heavyImpact();

      _showSuccessDialog(card, amount);
    }
  }

  void _showSuccessDialog(GiftCard card, int amount) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF2E7D32),
                    Color(0xFF1B5E20),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Purchase Successful!',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 26,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You bought a \$$amount ${card.title} gift card!',
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Check your email for the redemption code within 24 hours.',
                      style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      'Awesome!',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
