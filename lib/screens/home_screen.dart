import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/play_button.dart';
import '../widgets/continue_button.dart';
import '../widgets/next_button.dart';
import '../widgets/custom_icons_row.dart';
import 'app_shell.dart';


class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
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
        child: Stack(
          children: [
            // Main content: Play button centered
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlayButton(
                      text: 'PLAY',
                      onPressed: onPlayPressed,
                    ),
                  ],
                ),
              ),
            ),
            // Top-right button to switch to AllComponentsPreview
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.grid_view_rounded, size: 28, color: Colors.white),
                tooltip: 'Show All Components',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AllComponentsPreview(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 