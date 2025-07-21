// lib/all_components.dart
import 'package:flutter/material.dart';
import 'play_button.dart';
import 'next_button.dart';
import 'continue_button.dart';
import 'custom_icons.dart';

class AllComponentsPreview extends StatefulWidget {
  const AllComponentsPreview({super.key});

  @override
  State<AllComponentsPreview> createState() => _AllComponentsPreviewState();
}

class _AllComponentsPreviewState extends State<AllComponentsPreview> {
  int _playClicks = 0;
  int _nextClicks = 0;
  int _continueClicks = 0;
  String _lastButtonPressed = '';

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
      _playClicks++;
      _lastButtonPressed = 'Play';
    });
    _showSnackBar('🎮 Play button clicked! (${_playClicks}x)');
  }

  void _onNextPressed() {
    setState(() {
      _nextClicks++;
      _lastButtonPressed = 'Next';
    });
    _showSnackBar('⏭️ Next button clicked! (${_nextClicks}x)');
  }

  void _onContinuePressed() {
    setState(() {
      _continueClicks++;
      _lastButtonPressed = 'Continue';
    });
    _showSnackBar('▶️ Continue button clicked! (${_continueClicks}x)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB16DFF), // purple
              Color(0xFF5B6BFF), // blue
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Title with stats
                Card(
                  color: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          '🎮 Amazing Button Effects Demo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 3,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Last Pressed: $_lastButtonPressed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Play',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '$_playClicks',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Next',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '$_nextClicks',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '$_continueClicks',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Row of Play, Next, Continue buttons in different colors
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlayButton(
                        text: 'Play',
                        color: const Color(0xFF68DCFC),
                        onPressed: _onPlayPressed,
                      ),
                      const SizedBox(width: 12),
                      NextButton(
                        text: 'Next',
                        color: const Color(0xFF68DCFC),
                        onPressed: _onNextPressed,
                      ),
                      const SizedBox(width: 12),
                      ContinueButton(
                        text: 'Continue',
                        color: const Color(0xFF68DCFC),
                        onPressed: _onContinuePressed,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlayButton(
                        text: 'Play',
                        color: const Color(0xFFF88CFC),
                        onPressed: _onPlayPressed,
                      ),
                      const SizedBox(width: 12),
                      NextButton(
                        text: 'Next',
                        color: const Color(0xFFF88CFC),
                        onPressed: _onNextPressed,
                      ),
                      const SizedBox(width: 12),
                      ContinueButton(
                        text: 'Continue',
                        color: const Color(0xFFF88CFC),
                        onPressed: _onContinuePressed,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PlayButton(
                        text: 'Play',
                        color: const Color(0xFF9C27B0),
                        onPressed: _onPlayPressed,
                      ),
                      const SizedBox(width: 12),
                      NextButton(
                        text: 'Next',
                        color: const Color(0xFF9C27B0),
                        onPressed: _onNextPressed,
                      ),
                      const SizedBox(width: 12),
                      ContinueButton(
                        text: 'Continue',
                        color: const Color(0xFF9C27B0),
                        onPressed: _onContinuePressed,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Instructions card
                Card(
                  color: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: const [
                        Text(
                          '✨ Button Features:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• Haptic feedback on touch\n'
                          '• Sound effects when clicked\n'
                          '• Smooth scaling animations\n'
                          '• Pulse effects on press\n'
                          '• Unique visual animations\n'
                          '• Professional 3D styling',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Custom icons row
                const CustomIconsRow(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
