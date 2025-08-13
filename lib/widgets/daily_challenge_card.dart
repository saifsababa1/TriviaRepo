import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class DailyChallengeCard extends StatelessWidget {
  final String category;
  final String animationPath;
  final String description;

  const DailyChallengeCard({
    super.key,
    required this.category,
    required this.animationPath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.purple[300]!,
                width: 1,
              ),
            ),
            child: Text(
              category.toUpperCase(),
              style: GoogleFonts.luckiestGuy(
                color: Colors.purple[700],
                fontSize: 11,
                shadows: const [
                  Shadow(color: Colors.black12, blurRadius: 1, offset: Offset(1, 1)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Daily Challenge text
          Text(
            'Daily Challenge',
            style: GoogleFonts.luckiestGuy(
              color: Colors.purple[800],
              fontSize: 18,
              shadows: const [
                Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(1, 1)),
              ],
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Animation
          Lottie.asset(
            animationPath,
            width: 100,
            height: 100,
            fit: BoxFit.contain,
            repeat: true,
          ),
          
          const SizedBox(height: 6),
          
          // Challenge description
          Text(
            description,
            style: GoogleFonts.luckiestGuy(
              color: Colors.grey[700],
              fontSize: 13,
              shadows: const [
                Shadow(color: Colors.black12, blurRadius: 1, offset: Offset(1, 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
