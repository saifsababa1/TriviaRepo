import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TriviaScreen extends StatelessWidget {
  const TriviaScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
} 