// lib/screens/app_shell.dart - Updated imports and navigation
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/star_coin.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/unified_audio_service.dart';
import 'home_screen.dart';
import 'leaderboard_screen.dart';
import 'enhanced_spin_screen.dart';
import 'settings_screen.dart';
import 'awards_screen_new.dart';

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
  int _currentNavIndex = 2; // Start with Home (center index 2)

  // Enhanced animation controllers for smooth mobile-like transitions
  late AnimationController _pageTransitionController;
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
        backgroundColor: Colors.deepPurple.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _onPlayPressed() async {
    setState(() {
      _playCount++;
    });
    await UnifiedAudioService().playButtonClick();
    _showSnackBar('🎮 Play button clicked! (${_playCount}x)');
  }

  void _onNextPressed() async {
    setState(() {
      _nextCount++;
    });
    await UnifiedAudioService().playButtonClick();
    _showSnackBar('⏭️ Next button clicked! (${_nextCount}x)');
  }

  void _onContinuePressed() async {
    setState(() {
      _continueCount++;
    });
    await UnifiedAudioService().playButtonClick();
    _showSnackBar('▶️ Continue button clicked! (${_continueCount}x)');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen purple gradient background
        Positioned.fill(
          child: DecoratedBox(
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
          ),
        ),
        // Main scaffold rendered transparently over the gradient
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
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
                    if (newIndex <= 4) {
                      _handlePageTransition(newIndex);
                    }
                  }
                }
              },
              child:
                  _currentNavIndex == 0
                      ? _buildPageContent() // Full screen for spin
                      : Column(
                        children: [
                          // Header content
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildHeaderContent(),
                          ),
                          // Page content that takes remaining space
                          Expanded(child: _buildPageContent()),
                        ],
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
        ),
      ],
    );
  }

  // Helper methods for page-specific styling
  String _getPageTitle() {
    switch (_currentNavIndex) {
      case 0:
        return 'Lucky Wheel';
      case 1:
        return 'Leaderboard';
      case 2:
        return 'Home';
      case 3:
        return 'Awards';
      case 4:
        return 'Settings';
      default:
        return 'Home';
    }
  }

  Color _getPageColor() {
    switch (_currentNavIndex) {
      case 0:
        return const Color(0xFF00BCD4); // Spin
      case 1:
        return const Color(0xFFFFD700); // Leaderboard
      case 2:
        return const Color(0xFF4CAF50); // Home
      case 3:
        return const Color(0xFFFFA500); // Awards
      case 4:
        return const Color(0xFF9C27B0); // Settings
      default:
        return const Color(0xFF4CAF50);
    }
  }

  IconData _getPageIcon() {
    switch (_currentNavIndex) {
      case 0:
        return Icons.casino; // Spin
      case 1:
        return Icons.leaderboard; // Leaderboard
      case 2:
        return Icons.home_rounded; // Home
      case 3:
        return Icons.emoji_events; // Awards
      case 4:
        return Icons.settings; // Settings
      default:
        return Icons.home_rounded;
    }
  }

  String _getPageContent() {
    switch (_currentNavIndex) {
      case 0:
        return 'Spin the Lucky Wheel! 🎰';
      case 1:
        return 'Global Rankings & Scores! 📊';
      case 2:
        return 'Welcome to Your Game Hub! 🎮';
      case 3:
        return 'Your Achievements & Trophies! 🏆';
      case 4:
        return 'Game Settings & Preferences ⚙️';
      default:
        return 'Welcome to Your Game Hub! 🎮';
    }
  }

  // UPDATED: This is the key method that was causing the empty page
  Widget _buildPageContent() {
    switch (_currentNavIndex) {
      case 0:
        return const EnhancedSpinScreen(); // Changed from SpinScreen to EnhancedSpinScreen
      case 1:
        return const LeaderboardScreen();
      case 2:
        return HomeScreen(
          onPlayPressed: _onPlayPressed,
          onNextPressed: _onNextPressed,
          onContinuePressed: _onContinuePressed,
        );
      case 3:
        return const AwardsScreen();
      case 4:
        return const SettingsScreen();
      default:
        return HomeScreen(
          onPlayPressed: _onPlayPressed,
          onNextPressed: _onNextPressed,
          onContinuePressed: _onContinuePressed,
        );
    }
  }

  // Helper method to build header content (page indicator and title)
  Widget _buildHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Animated page indicator with smooth transitions
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getPageColor().withValues(alpha: 0.3),
                _getPageColor().withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: _getPageColor().withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _getPageColor().withValues(alpha: 0.2),
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
                        color: Colors.black.withValues(alpha: 0.3),
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

        const SizedBox(height: 16),

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
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 3,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        // Star Credits System (always visible for Home only)
        if (_currentNavIndex == 2) const GameCreditSystem(),
        if (_currentNavIndex == 2) const SizedBox(height: 16),
      ],
    );
  }

  // Helper method to build non-spin content with proper layout
  Widget _buildNonSpinContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header content
        _buildHeaderContent(),

        // Mobile-like sliding page content
        Expanded(
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
      ],
    );
  }

  void _handlePageTransition(int newIndex) async {
    // Prevent multiple transitions
    if (_pageSlideController.isAnimating) return;

    // Determine slide direction based on index change
    bool slidingRight = newIndex > _currentNavIndex;

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

    // Play navigation sound effect
    await UnifiedAudioService().playButtonClick();

    // Start the smooth transition
    _pageSlideController.forward().then((_) {
      setState(() {
        _currentNavIndex = newIndex;
      });
      _pageSlideController.reset();
    });
  }
}
