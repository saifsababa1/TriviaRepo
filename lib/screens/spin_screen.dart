import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpinScreen extends StatelessWidget {
  const SpinScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
} 