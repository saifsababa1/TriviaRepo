// lib/play_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PlayButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 118, // Set width
          height: 48, // Set height
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF98EC04), // first color
                Color.fromARGB(255, 87, 163, 109), // new darker color
              ],
            ),
            borderRadius: BorderRadius.circular(40), // pill shape
            border: Border.all(
              color: Colors.white,
              width: 3.5, // Much smaller border, barely visible
            ),
            // No box shadow
          ),
          alignment: Alignment.center,
          child: Stack(
            children: [
              // Main button background
              Align(
                alignment: Alignment.center,
                child: Text(
                  text.toUpperCase(),
                  style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 17, // Smaller font size
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: const [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 2, // Smaller text shadow
                        offset: Offset(1, 1), // Smaller offset
                      ),
                    ],
                  ),
                ),
              ),
              // 3D bottom edge overlay (smaller, only at the bottom)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: 7, // much smaller height
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF5CA904).withOpacity(0.45), // dark green shadow
                      ],
                    ),
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
