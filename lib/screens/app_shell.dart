// lib/all_components.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
                      _setIndex(newIndex);
                    }
                  } else {
                    // Swipe left - go to next page
                    int newIndex = _currentNavIndex + 1;
                    if (newIndex <= 4) {
                      _setIndex(newIndex);
                    }
                  }
                }
              },
              child: _currentNavIndex == 2
                  ? HomeScreen(
                      onPlayPressed: _onPlayPressed,
                      onNextPressed: _onNextPressed,
                      onContinuePressed: _onContinuePressed,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // Beautiful 3D Bottom Navigation Bar
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentNavIndex,
            onTap: (index) {
              if (index != _currentNavIndex) {
                _setIndex(index);
              }
            },
          ),
        ),
      ],
    );
  }

  void _setIndex(int newIndex) {
    HapticFeedback.lightImpact();
    setState(() => _currentNavIndex = newIndex);
  }
}
