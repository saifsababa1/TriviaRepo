import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_state_service.dart';
import '../widgets/star_coin.dart';

class GiftCard {
  final String title;
  final String subtitle;
  final int coinPrice;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String imageAsset;
  final List<int> denominations;

  GiftCard({
    required this.title,
    required this.subtitle,
    required this.coinPrice,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.imageAsset,
    this.denominations = const [10, 25, 50, 100],
  });
}

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentCoins = 2500;
  int _selectedCategory = 0;

  final List<String> _categories = [
    'All Cards',
    'Gaming',
    'Shopping',
    'Entertainment',
  ];

  late List<GiftCard> _giftCards;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGiftCards();
    _loadUserCoins();

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
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
        icon: Icons.play_arrow,
        imageAsset: 'assets/images/google_play.png',
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
        denominations: [10, 25, 50, 100],
      ),
      GiftCard(
        title: 'PUBG Mobile',
        subtitle: 'UC & Battle Pass',
        coinPrice: 800,
        primaryColor: const Color(0xFFFF6B35),
        secondaryColor: const Color(0xFFFF8F00),
        icon: Icons.sports_esports,
        imageAsset: 'assets/images/pubg.png',
        denominations: [5, 10, 20, 50],
      ),

      // Shopping Cards
      GiftCard(
        title: 'PayPal',
        subtitle: 'Digital Payments',
        coinPrice: 1200,
        primaryColor: const Color(0xFF0070BA),
        secondaryColor: const Color(0xFF003087),
        icon: Icons.payment,
        imageAsset: 'assets/images/paypal.png',
        denominations: [10, 25, 50, 100, 200],
      ),

      // Entertainment Cards
      GiftCard(
        title: 'Netflix',
        subtitle: 'Movies & TV Shows',
        coinPrice: 1500,
        primaryColor: const Color(0xFFE50914),
        secondaryColor: const Color(0xFF831010),
        icon: Icons.movie,
        imageAsset: 'assets/images/netflix.png',
        denominations: [15, 30, 60],
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 2.0,
          colors: [Color(0xFFFF6B35), Color(0xFFFF8F00), Color(0xFFE65100)],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildHeader(),
              _buildCategoryTabs(),
              Expanded(child: _buildGiftCardsGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF8F00)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gift Card Store',
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 24,
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
                    Text(
                      'Redeem your coins for rewards',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const StarCoin(size: 24),
                const SizedBox(width: 12),
                Text(
                  '$_currentCoins',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'coins available',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children:
            _categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          _selectedCategory == index
                              ? Colors.white
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        color:
                            _selectedCategory == index
                                ? const Color(0xFFE65100)
                                : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildGiftCardsGrid() {
    final filteredCards = _getFilteredCards();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: filteredCards.length,
      itemBuilder: (context, index) {
        return _buildGiftCardItem(filteredCards[index]);
      },
    );
  }

  List<GiftCard> _getFilteredCards() {
    if (_selectedCategory == 0) return _giftCards;

    switch (_selectedCategory) {
      case 1:
        return _giftCards
            .where(
              (card) =>
                  card.title.contains('Play') ||
                  card.title.contains('App Store') ||
                  card.title.contains('PUBG'),
            )
            .toList();
      case 2:
        return _giftCards
            .where((card) => card.title.contains('PayPal'))
            .toList();
      case 3:
        return _giftCards
            .where((card) => card.title.contains('Netflix'))
            .toList();
      default:
        return _giftCards;
    }
  }

  Widget _buildGiftCardItem(GiftCard card) {
    final canAfford = _currentCoins >= card.coinPrice;

    return GestureDetector(
      onTap: () => _showPurchaseDialog(card),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card.primaryColor.withOpacity(0.9),
              card.secondaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: card.primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color:
                canAfford
                    ? Colors.white.withOpacity(0.3)
                    : Colors.red.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(card.icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    card.title,
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const StarCoin(size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${card.coinPrice}',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          canAfford ? () => _showPurchaseDialog(card) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canAfford ? Colors.white : Colors.grey[400],
                        foregroundColor:
                            canAfford ? card.primaryColor : Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        canAfford ? 'Buy Now' : 'Not Enough',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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

  void _showPurchaseDialog(GiftCard card) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [card.primaryColor, card.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(card.icon, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Purchase ${card.title}',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.subtitle,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Amount:',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children:
                      card.denominations.map((amount) {
                        final totalCost =
                            (card.coinPrice * amount / 10).round();
                        final canAfford = _currentCoins >= totalCost;

                        return GestureDetector(
                          onTap:
                              canAfford
                                  ? () => _purchaseCard(card, amount, totalCost)
                                  : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  canAfford
                                      ? card.primaryColor
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '\$${amount}',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        canAfford
                                            ? Colors.white
                                            : Colors.grey[600],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const StarCoin(size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      '$totalCost',
                                      style: GoogleFonts.roboto(
                                        fontSize: 10,
                                        color:
                                            canAfford
                                                ? Colors.white
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
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.roboto(color: Colors.grey[600]),
                  ),
                ),
              ],
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

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Purchase Successful!',
                    style: GoogleFonts.luckiestGuy(
                      fontSize: 20,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You bought a \$${amount} ${card.title} gift card!',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Check your email for redemption code.',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Awesome!'),
                  ),
                ],
              ),
            ),
      );
    }
  }
}
