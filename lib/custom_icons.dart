import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 28),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class CustomIconsRow extends StatelessWidget {
  const CustomIconsRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CustomIconButton(icon: Icons.close, color: Colors.red),
        SizedBox(width: 16),
        CustomIconButton(icon: Icons.check, color: Colors.green),
        SizedBox(width: 16),
        CustomIconButton(icon: Icons.settings, color: Colors.purple),
        SizedBox(width: 16),
        CustomIconButton(icon: Icons.home, color: Colors.yellow),
        SizedBox(width: 16),
        CustomIconButton(icon: Icons.arrow_upward, color: Colors.cyan),
        SizedBox(width: 16),
        CustomIconButton(icon: Icons.menu, color: Colors.pink),
      ],
    );
  }
} 