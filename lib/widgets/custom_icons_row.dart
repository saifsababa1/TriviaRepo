import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_icons.dart';

class CustomIconsRow extends StatefulWidget {
  const CustomIconsRow({super.key});

  @override
  State<CustomIconsRow> createState() => _CustomIconsRowState();
}

class _CustomIconsRowState extends State<CustomIconsRow> {
  int _iconClicks = 0;
  String _lastIconPressed = '';

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.luckiestGuy(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _onIconPressed(String iconName, Color color) {
    setState(() {
      _iconClicks++;
      _lastIconPressed = iconName;
    });

    String emoji = '';
    switch (iconName) {
      case 'Close':
        emoji = '❌';
        break;
      case 'Check':
        emoji = '✅';
        break;
      case 'Settings':
        emoji = '⚙️';
        break;
      case 'Home':
        emoji = '🏠';
        break;
      case 'Up':
        emoji = '⬆️';
        break;
      case 'Menu':
        emoji = '📋';
        break;
    }

    _showSnackBar('$emoji $iconName clicked! ( _iconClicks total)', color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats card for icons
        Card(
          color: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '🎯 Interactive Icons',
                  style: GoogleFonts.luckiestGuy(
                    color: Colors.white,
                    fontSize: 18,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 3,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last: $_lastIconPressed | Total: $_iconClicks',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Responsive icon row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconButton(
                icon: Icons.close,
                color: Colors.red,
                onPressed: () => _onIconPressed('Close', Colors.red),
                tooltip: 'Close',
              ),
              const SizedBox(width: 16),
              CustomIconButton(
                icon: Icons.check,
                color: Colors.green,
                onPressed: () => _onIconPressed('Check', Colors.green),
                tooltip: 'Check',
              ),
              const SizedBox(width: 16),
              CustomIconButton(
                icon: Icons.settings,
                color: Colors.purple,
                onPressed: () => _onIconPressed('Settings', Colors.purple),
                tooltip: 'Settings',
              ),
              const SizedBox(width: 16),
              CustomIconButton(
                icon: Icons.home,
                color: Colors.orange,
                onPressed: () => _onIconPressed('Home', Colors.orange),
                tooltip: 'Home',
              ),
              const SizedBox(width: 16),
              CustomIconButton(
                icon: Icons.arrow_upward,
                color: Colors.cyan,
                onPressed: () => _onIconPressed('Up', Colors.cyan),
                tooltip: 'Up',
              ),
              const SizedBox(width: 16),
              CustomIconButton(
                icon: Icons.menu,
                color: Colors.pink,
                onPressed: () => _onIconPressed('Menu', Colors.pink),
                tooltip: 'Menu',
              ),
            ],
          ),
        ),
      ],
    );
  }
} 