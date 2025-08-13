import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import '../widgets/play_button.dart';
import '../widgets/star_coin.dart';
import '../widgets/daily_challenge_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback onNextPressed;
  final VoidCallback onContinuePressed;

  const HomeScreen({
    super.key,
    required this.onPlayPressed,
    required this.onNextPressed,
    required this.onContinuePressed,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _coins = 275;
  int _gems = 12;
  late AnimationController _coinCounterController;
  late AnimationController _gemCounterController;
  late AnimationController _shakeController;
  int _pendingCoins = 0;
  int _pendingGems = 0;
  bool _isAnimatingRewards = false;
  
  // Daily Challenge categories
  String _selectedCategory = 'SPORTS'; // Default to Sports

  @override
  void initState() {
    super.initState();
    _coinCounterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _gemCounterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _coinCounterController.dispose();
    _gemCounterController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _addCoins(int amount) {
    setState(() {
      _coins += amount;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+$amount coins!', style: GoogleFonts.luckiestGuy(color: Colors.white)),
        backgroundColor: const Color(0xFFFFD700).withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  // Get the current daily challenge card based on selected category
  Widget _getCurrentChallengeCard() {
    switch (_selectedCategory) {
      case 'SPORTS':
        return DailyChallengeCard(
          category: 'SPORTS',
          animationPath: 'assets/images/ball.json',
          description: 'Answer 10 sports questions!',
        );
      case 'SCIENCE':
        return DailyChallengeCard(
          category: 'SCIENCE',
          animationPath: 'assets/images/science.json',
          description: 'Answer 10 science questions!',
        );
      case 'HISTORY':
        return DailyChallengeCard(
          category: 'HISTORY',
          animationPath: 'assets/images/history.json',
          description: 'Answer 10 history questions!',
        );
      default:
        return DailyChallengeCard(
          category: 'SPORTS',
          animationPath: 'assets/images/ball.json',
          description: 'Answer 10 sports questions!',
        );
    }
  }

  void _addChestRewards(int coins, int gems) async {
    if (_isAnimatingRewards) return; // Prevent multiple animations
    
    setState(() {
      _pendingCoins = coins;
      _pendingGems = gems;
      _isAnimatingRewards = true;
    });

    // Start shake animation
    _shakeController.repeat(reverse: true);
    
    // Start counter animations
    _coinCounterController.animateTo(1.0, duration: const Duration(milliseconds: 2000));
    _gemCounterController.animateTo(1.0, duration: const Duration(milliseconds: 2000));
    
    // Wait for counter animation to complete
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Add the rewards to actual totals
    setState(() {
      _coins += coins;
      _gems += gems;
      _pendingCoins = 0;
      _pendingGems = 0;
      _isAnimatingRewards = false;
    });
    
    // Stop shake animation
    _shakeController.stop();
    _shakeController.reset();
    
    // Reset counter controllers
    _coinCounterController.reset();
    _gemCounterController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_coinCounterController, _gemCounterController, _shakeController]),
      builder: (context, child) {
        return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bkgrd4.jpg'),
          fit: BoxFit.contain,
          repeat: ImageRepeat.repeat,
          alignment: Alignment.topLeft,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              // Main vertical content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Player banner (left) and small coin tracker (right) on the same row/height
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const _PlayerBanner(),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _CoinBar(
                            amount: _coins, 
                            coinSize: 40, 
                            height: 44,
                            pendingAmount: _pendingCoins,
                            counterController: _coinCounterController,
                            shakeController: _shakeController,
                          ),
                          const SizedBox(height: 8),
                          _GemBar(
                            amount: _gems, 
                            gemSize: 28, 
                            height: 38,
                            pendingAmount: _pendingGems,
                            counterController: _gemCounterController,
                            shakeController: _shakeController,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Simple separation line
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    width: double.infinity,
                    height: 1,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(0.5),
                    ),
                  ),

                  // Daily Challenge section - positioned higher
                  const SizedBox(height: 80),
                  
                  // Center the content horizontally
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Daily Challenge card
                        _getCurrentChallengeCard(),
                      ],
                    ),
                  ),
                  
                  const Spacer(), // Push content to bottom
                ],
              ),

              // PLAY button positioned with proper spacing
              Positioned(
                bottom: 180, // Position with distance from card
                left: 0,
                right: 0,
                child: Center(
                  child: Transform.scale(
                    scale: 1.2,
                    child: PlayButton(
                      text: 'PLAY',
                      onPressed: widget.onPlayPressed,
                    ),
                  ),
                ),
              ),
              
              // Bottom-centered chest row above navbar
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: const _ChestSlotsRow(),
                  ),
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
}

class _PlayerBanner extends StatelessWidget {
  const _PlayerBanner();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-8, 0), // emerge slightly from the left
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB16DFF), // Lighter purple
              Color(0xFF9854FF), // Medium purple
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFF7C4DFF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced player logo/avatar with crown
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                // Crown icon for player status
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Enhanced username and subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Player Name',
                  style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 20,
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 3, offset: Offset(1, 1)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Lv. 1',
                        style: GoogleFonts.luckiestGuy(
                          color: Colors.white,
                          fontSize: 11,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 1, offset: Offset(1, 1)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rookie',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 1, offset: Offset(1, 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinBar extends StatelessWidget {
  final int amount;
  final double coinSize;
  final double height;
  final int pendingAmount;
  final AnimationController? counterController;
  final AnimationController? shakeController;
  
  const _CoinBar({
    required this.amount, 
    this.coinSize = 32, 
    this.height = 42,
    this.pendingAmount = 0,
    this.counterController,
    this.shakeController,
  });

  @override
  Widget build(BuildContext context) {
    Widget coinDisplay = Text(
      amount.toString(),
      style: GoogleFonts.luckiestGuy(
        color: Colors.white,
        fontSize: 13.5,
        shadows: const [
          Shadow(color: Colors.black45, blurRadius: 1, offset: Offset(1, 1)),
        ],
      ),
    );

    // If we have a counter animation, show the animated value
    if (counterController != null && pendingAmount > 0) {
      coinDisplay = AnimatedBuilder(
        animation: counterController!,
        builder: (context, child) {
          final animatedAmount = amount + (pendingAmount * counterController!.value).round();
          return Text(
            animatedAmount.toString(),
            style: GoogleFonts.luckiestGuy(
              color: Colors.white,
              fontSize: 13.5,
              shadows: const [
                Shadow(color: Colors.black45, blurRadius: 1, offset: Offset(1, 1)),
              ],
            ),
          );
        },
      );
    }

    Widget container = Container(
      height: height,
      width: 100, // Fixed width to match gem bar
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          coinDisplay,
          const SizedBox(width: 10),
          StarCoinCredit(
            creditAmount: amount,
            size: coinSize,
            showNumberOverlay: false,
          ),
        ],
      ),
    );

    // Add shake animation if available
    if (shakeController != null) {
      return AnimatedBuilder(
        animation: shakeController!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              (shakeController!.value - 0.5) * 4, // Horizontal shake
              (shakeController!.value - 0.5) * 2, // Vertical shake
            ),
            child: container,
          );
        },
      );
    }

    return container;
  }
}

class _PlusButton extends StatelessWidget {
  const _PlusButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.add, size: 18, color: Colors.white),
    );
  }
}

class _GemBar extends StatelessWidget {
  final int amount;
  final double gemSize;
  final double height;
  final int pendingAmount;
  final AnimationController? counterController;
  final AnimationController? shakeController;
  
  const _GemBar({
    required this.amount, 
    this.gemSize = 28, 
    this.height = 38,
    this.pendingAmount = 0,
    this.counterController,
    this.shakeController,
  });

  @override
  Widget build(BuildContext context) {
    Widget gemDisplay = Text(
      amount.toString(),
      style: GoogleFonts.luckiestGuy(
        color: Colors.white,
        fontSize: 13,
        shadows: const [
          Shadow(color: Colors.black45, blurRadius: 1, offset: Offset(1, 1)),
        ],
      ),
    );

    // If we have a counter animation, show the animated value
    if (counterController != null && pendingAmount > 0) {
      gemDisplay = AnimatedBuilder(
        animation: counterController!,
        builder: (context, child) {
          final animatedAmount = amount + (pendingAmount * counterController!.value).round();
          return Text(
            animatedAmount.toString(),
            style: GoogleFonts.luckiestGuy(
              color: Colors.white,
              fontSize: 13,
              shadows: const [
                Shadow(color: Colors.black45, blurRadius: 1, offset: Offset(1, 1)),
              ],
            ),
          );
        },
      );
    }

    Widget container = Container(
      height: height,
      width: 100, // Fixed width to match coin bar
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          gemDisplay,
          const SizedBox(width: 10),
          Icon(
            Icons.diamond_rounded,
            size: gemSize,
            color: const Color(0xFF6FE8FF),
          ),
        ],
      ),
    );

    // Add shake animation if available
    if (shakeController != null) {
      return AnimatedBuilder(
        animation: shakeController!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              (shakeController!.value - 0.5) * 4, // Horizontal shake
              (shakeController!.value - 0.5) * 2, // Vertical shake
            ),
            child: container,
          );
        },
      );
    }

    return container;
  }
}

// ------------------- Chest System (Visual Progress) -------------------

class _ChestData {
  int progress; // 0..5
  _ChestData({this.progress = 0});
}

class _ChestSlotsRow extends StatefulWidget {
  const _ChestSlotsRow();

  @override
  State<_ChestSlotsRow> createState() => _ChestSlotsRowState();
}

class _ChestSlotsRowState extends State<_ChestSlotsRow> {
  late List<_ChestData> _chests;

  @override
  void initState() {
    super.initState();
    _chests = [
      _ChestData(progress: 5),
      _ChestData(progress: 2),
      _ChestData(progress: 0),
      _ChestData(progress: 0),
    ];
  }

  void _incrementProgress(int index) {
    setState(() {
      _chests[index].progress = (_chests[index].progress + 1).clamp(0, 5);
    });
  }

  void _openChest(int index) {
    // Reset chest progress after opening
    setState(() {
      _chests[index].progress = 0;
    });
    
    // Navigate to chest opening animation screen
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _ChestOpeningScreen(
          onRewardsCollected: (coins, gems) {
            // This will be called when the chest opening animation completes
            // We need to access the parent widget's method
            final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
            if (homeScreenState != null) {
              homeScreenState._addChestRewards(coins, gems);
            }
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_chests.length, (i) {
        final c = _chests[i];
        return SizedBox(
          width: 80, // Fixed width for all chest cards
          child: _ChestCard(
            progress: c.progress,
            onTap: () => _incrementProgress(i),
            onChestOpen: () => _openChest(i),
          ),
        );
      }),
    );
  }
}

class _ChestCard extends StatefulWidget {
  final int progress; // 0..5
  final VoidCallback onTap;
  final VoidCallback? onChestOpen; // Callback when completed chest is opened
  const _ChestCard({required this.progress, required this.onTap, this.onChestOpen});

  @override
  State<_ChestCard> createState() => _ChestCardState();
}

class _ChestCardState extends State<_ChestCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shakeController;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Initialize animation state
    _updateAnimationState();
  }

  void _updateAnimationState() {
    final bool wasCompleted = _isCompleted;
    _isCompleted = widget.progress >= 5;
    
    // Always show closed chest frame (first frame)
    _animationController.value = 0.0;
    
    // Start shaking animation if completed
    if (_isCompleted && !wasCompleted) {
      _startShakeAnimation();
    } else if (!_isCompleted) {
      _shakeController.stop();
    }
  }

  void _startShakeAnimation() {
    _shakeController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_ChestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnimationState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double ratio = widget.progress / 5.0;

    return InkWell(
      onTap: () {
        if (widget.progress >= 5 && widget.onChestOpen != null) {
          // Chest is completed - open it
          widget.onChestOpen!();
        } else {
          // Chest is not completed - increment progress
          widget.onTap();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _isCompleted 
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFD700), // Bright gold
                  Color(0xFFFFA000), // Orange gold
                  Color(0xFFFF8C00), // Darker orange gold
                ],
                stops: [0.0, 0.5, 1.0],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFB39DDB), Color(0xFF9FA8DA)],
              ),
          border: Border.all(
            color: _isCompleted 
              ? const Color(0xFFFFD700).withOpacity(0.6)
              : Colors.white.withOpacity(0.25), 
            width: _isCompleted ? 2 : 1
          ),
          boxShadow: _isCompleted 
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: const Color(0xFFFFA000).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
              ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Lottie animation for all chests with different behaviors
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: _isCompleted 
                    ? Offset(
                        (1 - _shakeController.value) * 0.8 - 0.4, // Subtle horizontal shake
                        (1 - _shakeController.value) * 0.4 - 0.2, // Very subtle vertical shake
                      )
                    : Offset.zero,
                  child: Lottie.asset(
                    'assets/images/chest.json',
                    controller: _animationController,
                    width: 65,
                    height: 65,
                    fit: BoxFit.contain,
                    repeat: _isCompleted, // Only repeat for completed chests
                  ),
                );
              },
            ),
            
            // "OPEN!" text overlay for completed chests
            if (_isCompleted)
              Positioned(
                top: 2,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'OPEN !',
                    style: GoogleFonts.luckiestGuy(
                      color: const Color.fromARGB(255, 249, 249, 249),
                      fontSize: 14,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                ),
              ),

            // Continuous progress bar
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ratio.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),

            // Achievements number overlay
            Positioned(
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.progress} / 5',
                  style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 12,
                    shadows: const [Shadow(color: Colors.black45, blurRadius: 1, offset: Offset(1, 1))],
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

class _TreasureIcon extends StatelessWidget {
  final double size;
  const _TreasureIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.inbox_rounded,
      size: size,
      color: Colors.white.withOpacity(0.95),
    );
  }
}



class _ChestOpeningScreen extends StatefulWidget {
  final Function(int coins, int gems) onRewardsCollected;
  
  const _ChestOpeningScreen({required this.onRewardsCollected});

  @override
  State<_ChestOpeningScreen> createState() => _ChestOpeningScreenState();
}

class _ChestOpeningScreenState extends State<_ChestOpeningScreen> with TickerProviderStateMixin {
  late AnimationController _chestAnimationController;
  late AnimationController _coinsController;
  late AnimationController _gemsController;
  late AnimationController _continueController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    
    _chestAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _coinsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _gemsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _continueController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Start the animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start chest opening animation
    _chestAnimationController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 2800),
      curve: Curves.easeInOutCubic,
    );
    
    // Wait for chest to start opening, then show coins first
    await Future.delayed(const Duration(milliseconds: 1500)); 
    _coinsController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
    );
    
    // Show gems after coins
    await Future.delayed(const Duration(milliseconds: 800));
    _gemsController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
    );
    
    // Show continue button after gems
    await Future.delayed(const Duration(milliseconds: 800));
    _continueController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
    );
    
    // Wait for chest animation to complete
    await Future.delayed(const Duration(milliseconds: 340)); // Remaining time
    
    // Comfortable pause to read rewards
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Smooth fade out with easing
    await _fadeController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutCubic,
    );
    
    if (mounted) {
      // Call the callback with the rewards before popping
      widget.onRewardsCollected(50, 5); // 50 coins, 5 gems
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _chestAnimationController.dispose();
    _coinsController.dispose();
    _gemsController.dispose();
    _continueController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB16DFF),
              Color(0xFF9854FF),
              Color(0xFF7B3EFF),
              Color(0xFF5B2CFF),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_chestAnimationController, _coinsController, _gemsController, _continueController, _fadeController]),
              builder: (context, child) {
                return Opacity(
                  opacity: 1.0 - _fadeController.value,
                  child: Stack(
                    children: [
                      // Animated background particles
                      if (_coinsController.value > 0.5)
                        ...List.generate(20, (index) => Positioned(
                          left: (index * 37) % MediaQuery.of(context).size.width,
                          top: (index * 23) % MediaQuery.of(context).size.height,
                          child: Opacity(
                            opacity: _coinsController.value > 0.5 ? 0.6 * (_coinsController.value - 0.5) * 2 : 0.0,
                            child: Icon(
                              Icons.star,
                              color: const Color(0xFFFFD700),
                              size: 12 + (index % 3) * 4,
                            ),
                          ),
                        )),
                      
                      // Main content - positioned lower
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 130), // Push content down to middle
                      
                      // Enhanced chest animation with smooth scaling and glow
                      AnimatedBuilder(
                        animation: _chestAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_chestAnimationController.value * 0.5),
                            child: Transform.translate(
                              offset: Offset(0, -(_chestAnimationController.value * 20)),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withOpacity(0.4 * _chestAnimationController.value),
                                      blurRadius: 25 + (_chestAnimationController.value * 40),
                                      spreadRadius: 8 + (_chestAnimationController.value * 15),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFFFA000).withOpacity(0.2 * _chestAnimationController.value),
                                      blurRadius: 15 + (_chestAnimationController.value * 25),
                                      spreadRadius: 3 + (_chestAnimationController.value * 8),
                                    ),
                                  ],
                                ),
                                child: Lottie.asset(
                                  'assets/images/chest.json',
                                  controller: _chestAnimationController,
                                  width: 240,
                                  height: 240,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // Individual reward animations
                      Column(
                        children: [
                          const SizedBox(height: 40),
                          
                          // Coins reward with star coin - animated first
                          Transform.scale(
                            scale: 0.3 + (_coinsController.value * 0.7),
                            child: Transform.translate(
                              offset: Offset(0, (1.0 - _coinsController.value) * 100),
                              child: Opacity(
                                opacity: _coinsController.value,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    StarCoinCredit(
                                      creditAmount: 50,
                                      size: 55,
                                      showNumberOverlay: false,
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      '${(50 * _coinsController.value).round()}',
                                      style: GoogleFonts.luckiestGuy(
                                        color: Colors.white,
                                        fontSize: 32,
                                        shadows: const [
                                          Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Gems reward - animated second
                          Transform.scale(
                            scale: 0.3 + (_gemsController.value * 0.7),
                            child: Transform.translate(
                              offset: Offset(0, (1.0 - _gemsController.value) * 100),
                              child: Opacity(
                                opacity: _gemsController.value,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.diamond,
                                      color: const Color(0xFF6FE8FF),
                                      size: 40,
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      '${(5 * _gemsController.value).round()}',
                                      style: GoogleFonts.luckiestGuy(
                                        color: const Color(0xFF6FE8FF),
                                        fontSize: 28,
                                        shadows: const [
                                          Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Continue button - animated third
                          Transform.scale(
                            scale: 0.3 + (_continueController.value * 0.7),
                            child: Transform.translate(
                              offset: Offset(0, (1.0 - _continueController.value) * 100),
                              child: Opacity(
                                opacity: _continueController.value,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFD700).withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'Continue',
                                      style: GoogleFonts.luckiestGuy(
                                        color: Colors.white,
                                        fontSize: 22,
                                        shadows: const [
                                          Shadow(color: Colors.black45, blurRadius: 1, offset: Offset(1, 1)),
                                        ],
                                      ),
                                    ),
                                  ),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
} 