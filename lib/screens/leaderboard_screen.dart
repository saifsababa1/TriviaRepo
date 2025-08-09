import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
} 