import 'package:flutter/material.dart';
import 'play_button.dart';
import 'next_button.dart';
import 'continue_button.dart';
import 'custom_icons.dart';

class AllComponentsPreview extends StatelessWidget {
  const AllComponentsPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              // Row of Play, Next, Continue buttons in different colors
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  PlayButton(text: 'Play', color: Color(0xFF68DCFC)),
                  SizedBox(width: 12),
                  NextButton(text: 'Next', color: Color(0xFF68DCFC)),
                  SizedBox(width: 12),
                  ContinueButton(text: 'Continue', color: Color(0xFF68DCFC)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  PlayButton(text: 'Play', color: Color(0xFFF88CFC)),
                  SizedBox(width: 12),
                  NextButton(text: 'Next', color: Color(0xFFF88CFC)),
                  SizedBox(width: 12),
                  ContinueButton(text: 'Continue', color: Color(0xFFF88CFC)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  PlayButton(text: 'Play', color: Color(0xFFF88CFC)),
                  SizedBox(width: 12),
                  NextButton(text: 'Next', color: Color(0xFFF88CFC)),
                  SizedBox(width: 12),
                  ContinueButton(text: 'Continue', color: Color(0xFFF88CFC)),
                ],
              ),
              const SizedBox(height: 32),
              // Custom icons row
              const CustomIconsRow(),
            ],
          ),
        ),
      ),
    );
  }
} 