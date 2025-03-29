import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class StellarHpDateTimeOptionButton extends StatelessWidget {
  const StellarHpDateTimeOptionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(
        icon,
        color: stellarHpBlue,
        size: 20,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(stellarHpDateTimeBlue),
        foregroundColor: WidgetStateProperty.all<Color>(stellarHpBlue),
        side: WidgetStateProperty.all(
          const BorderSide(
            color: stellarHpBlue,
            width: 0.5,
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry?>(
          const EdgeInsets.fromLTRB(12, 8, 12, 8),
        ),
        shape: WidgetStateProperty.all<OutlinedBorder?>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textStyle: WidgetStateProperty.all<TextStyle?>(
          context.style.titleSmall?.copyWith(
            // fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      label: Text(title),
      onPressed: onPressed,
    );
  }
}
