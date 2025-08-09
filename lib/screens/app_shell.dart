// lib/all_components.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'play_button.dart';
import 'continue_button.dart';
import 'next_button.dart';
import 'custom_icons.dart';
import 'star_coin.dart';
import 'bottom_nav_bar.dart'; // Add the new import

// 2. Add the SplashScreen widget at the top (after imports)
class TriviaSplashScreen extends StatelessWidget {
  const TriviaSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(
          child: Image.asset(
            'assets/images/image.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}

class AllComponentsPreview extends StatefulWidget {
  const AllComponentsPreview({super.key});

  @override
  State<AllComponentsPreview> createState() => _AllComponentsPreviewState();
}

class _AllComponentsPreviewState extends State<AllComponentsPreview>
    with TickerProviderStateMixin {
  int _playCount = 0;
  int _nextCount = 0;
  int _continueCount = 0;
  int _currentNavIndex = 0; // Start with Home (index 0)

  // Enhanced animation controllers for smooth mobile-like transitions
  late AnimationController _pageTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _pageSlideController;
  late Animation<Offset> _currentPageSlide;
  late Animation<Offset> _nextPageSlide;

  @override
  void initState() {
    super.initState();

    // Smooth page transition animations
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300), // Faster, mobile-like
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageTransitionController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.15, 0), // Subtle slide effect
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageTransitionController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Mobile-like horizontal page sliding
    _pageSlideController = AnimationController(
      duration: const Duration(milliseconds: 350), // Mobile-optimized timing
      vsync: this,
    );

    _currentPageSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0), // Slide out left
    ).animate(
      CurvedAnimation(
        parent: _pageSlideController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _nextPageSlide = Tween<Offset>(
      begin: const Offset(1.0, 0), // Start from right
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageSlideController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Start with initial animation
    _pageTransitionController.forward();
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    _pageSlideController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.deepPurple.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _onPlayPressed() {
    setState(() {
      _playCount++;
    });
    _showSnackBar('🎮 Play button clicked! (${_playCount}x)');
  }

  void _onNextPressed() {
    setState(() {
      _nextCount++;
    });
    _showSnackBar('⏭️ Next button clicked! (${_nextCount}x)');
  }

  void _onContinuePressed() {
    setState(() {
      _continueCount++;
    });
    _showSnackBar('▶️ Continue button clicked! (${_continueCount}x)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB16DFF), // Light purple at top
              Color(0xFF9854FF), // Medium purple
              Color(0xFF7B3EFF), // Deeper purple
              Color(0xFF5B2CFF), // Deep purple-blue at bottom
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onPanEnd: (details) {
              // Detect horizontal swipe velocity
              double velocity = details.velocity.pixelsPerSecond.dx;

              if (velocity.abs() > 500) {
                // Minimum velocity for swipe
                if (velocity > 0) {
                  // Swipe right - go to previous page
                  int newIndex = _currentNavIndex - 1;
                  if (newIndex >= 0) {
                    _handlePageTransition(newIndex);
                  }
                } else {
                  // Swipe left - go to next page
                  int newIndex = _currentNavIndex + 1;
                  if (newIndex <= 3) {
                    _handlePageTransition(newIndex);
                  }
                }
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated page indicator with smooth transitions
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getPageColor().withOpacity(0.3),
                          _getPageColor().withOpacity(0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _getPageColor().withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getPageColor().withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            _getPageIcon(),
                            key: ValueKey(_currentNavIndex),
                            color: _getPageColor(),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _getPageTitle(),
                            key: ValueKey(_getPageTitle()),
                            style: GoogleFonts.luckiestGuy(
                              fontSize: 20,
                              color: _getPageColor(),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Animated title with page-specific content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      _getPageContent(),
                      key: ValueKey(_getPageTitle()),
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 24,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 3,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Star Credits System (always visible)
                  const GameCreditSystem(),

                  const SizedBox(height: 32),

                  // Mobile-like sliding page content
                  SizedBox(
                    height: 400, // Fixed height for smooth sliding
                    child: Stack(
                      children: [
                        // Current page content
                        AnimatedBuilder(
                          animation: _pageSlideController,
                          builder: (context, child) {
                            return SlideTransition(
                              position: _currentPageSlide,
                              child: _buildPageContent(),
                            );
                          },
                        ),

                        // Next page content (visible during transition)
                        if (_pageSlideController.isAnimating)
                          AnimatedBuilder(
                            animation: _pageSlideController,
                            builder: (context, child) {
                              return SlideTransition(
                                position: _nextPageSlide,
                                child: _buildPageContent(),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),

      // Beautiful 3D Bottom Navigation Bar
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index != _currentNavIndex) {
            _handlePageTransition(index);
          }
        },
      ),
    );
  }

  // Helper methods for page-specific styling
  String _getPageTitle() {
    switch (_currentNavIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Awards';
      case 2:
        return 'Lucky Wheel';
      case 3:
        return 'Settings';
      default:
        return 'Home';
    }
  }

  Color _getPageColor() {
    switch (_currentNavIndex) {
      case 0:
        return const Color(0xFF4CAF50); // Green for Home
      case 1:
        return const Color(0xFFFFD700); // Gold for Awards
      case 2:
        return const Color(0xFF00BCD4); // Cyan for Lucky Wheel
      case 3:
        return const Color(0xFF9C27B0); // Purple for Settings
      default:
        return const Color(0xFF4CAF50);
    }
  }

  IconData _getPageIcon() {
    switch (_currentNavIndex) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.casino;
      case 3:
        return Icons.settings;
      default:
        return Icons.home_rounded;
    }
  }

  String _getPageContent() {
    switch (_currentNavIndex) {
      case 0:
        return 'Welcome to Your Game Hub! 🎮';
      case 1:
        return 'Your Achievements & Trophies! 🏆';
      case 2:
        return 'Spin the Lucky Wheel! 🎰';
      case 3:
        return 'Game Settings & Preferences ⚙️';
      default:
        return 'Welcome to Your Game Hub! 🎮';
    }
  }

  Widget _buildPageContent() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildAwardsContent();
      case 2:
        return _buildLuckyWheelContent();
      case 3:
        return _buildSettingsContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Column(
      key: const ValueKey('home'),
      children: [
        // Splash Button
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              backgroundColor: const Color(0xFF7B3EFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 8,
              shadowColor: Colors.deepPurple.withOpacity(0.3),
              textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TriviaSplashScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
            child: const Text('Show Trivia Master Splash'),
          ),
        ),
        // Buttons Row 1
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlayButton(
                text: 'PLAY',
                color: const Color(0xFF4CAF50),
                onPressed: _onPlayPressed,
              ),
              const SizedBox(width: 16),
              NextButton(
                text: 'NEXT',
                color: const Color(0xFF2196F3),
                onPressed: _onNextPressed,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Continue Button
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ContinueButton(
                text: 'CONTINUE',
                color: const Color(0xFF9C27B0),
                onPressed: _onContinuePressed,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Custom Icons
        const CustomIconsRow(),
      ],
    );
  }

  Widget _buildAwardsContent() {
    return Column(
      key: const ValueKey('awards'),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFD700).withOpacity(0.2),
                const Color(0xFFFFA500).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events,
                size: 60,
                color: const Color(0xFFFFD700),
              ),
              const SizedBox(height: 16),
              Text(
                'Coming Soon!',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 18,
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your achievements and trophies will appear here',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyWheelContent() {
    return Column(
      key: const ValueKey('wheel'),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00BCD4).withOpacity(0.2),
                const Color(0xFF0097A7).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF00BCD4).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.casino, size: 60, color: const Color(0xFF00BCD4)),
              const SizedBox(height: 16),
              Text(
                'Lucky Wheel!',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 18,
                  color: const Color(0xFF00BCD4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Spin to win amazing prizes and credits!',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsContent() {
    return Column(
      key: const ValueKey('settings'),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9C27B0).withOpacity(0.2),
                const Color(0xFF7B1FA2).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF9C27B0).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.settings, size: 60, color: const Color(0xFF9C27B0)),
              const SizedBox(height: 16),
              Text(
                'Settings',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 18,
                  color: const Color(0xFF9C27B0),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your game experience',
                style: GoogleFonts.luckiestGuy(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods for navigation feedback
  String _getPageTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Awards';
      case 2:
        return 'Lucky Wheel';
      case 3:
        return 'Settings';
      default:
        return 'Home';
    }
  }

  Color _getPageColorForIndex(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF4CAF50);
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFF00BCD4);
      case 3:
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  void _handlePageTransition(int newIndex) {
    // Prevent multiple transitions
    if (_pageSlideController.isAnimating) return;

    // Determine slide direction based on index change
    bool slidingRight = newIndex > _currentNavIndex;

    // Store the new index for the transition
    int previousIndex = _currentNavIndex;

    // Update slide animations based on direction
    if (slidingRight) {
      // Sliding right: current page slides left, new page comes from right
      _currentPageSlide = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-1.0, 0),
      ).animate(
        CurvedAnimation(
          parent: _pageSlideController,
          curve: Curves.easeInOutCubic,
        ),
      );

      _nextPageSlide = Tween<Offset>(
        begin: const Offset(1.0, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _pageSlideController,
          curve: Curves.easeInOutCubic,
        ),
      );
    } else {
      // Sliding left: current page slides right, new page comes from left
      _currentPageSlide = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(1.0, 0),
      ).animate(
        CurvedAnimation(
          parent: _pageSlideController,
          curve: Curves.easeInOutCubic,
        ),
      );

      _nextPageSlide = Tween<Offset>(
        begin: const Offset(-1.0, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _pageSlideController,
          curve: Curves.easeInOutCubic,
        ),
      );
    }

    // Add haptic feedback
    HapticFeedback.lightImpact();

    // Start the smooth transition
    _pageSlideController.forward().then((_) {
      setState(() {
        _currentNavIndex = newIndex;
      });
      _pageSlideController.reset();

      // Show smooth feedback with direction indicator
      String pageName = _getPageTitleForIndex(newIndex);
      String direction = slidingRight ? '→' : '←';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$direction $pageName',
            style: GoogleFonts.luckiestGuy(color: Colors.white, fontSize: 14),
          ),
          backgroundColor: _getPageColorForIndex(newIndex),
          duration: const Duration(milliseconds: 500), // Shorter duration
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
        ),
      );
    });
  }
}
