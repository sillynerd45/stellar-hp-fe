import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class StellarHpDoctorConsultationButton extends StatelessWidget {
  final String text;
  final bool underline;
  final VoidCallback onPressed;
  final Color color;

  const StellarHpDoctorConsultationButton({
    super.key,
    required this.text,
    this.underline = false,
    required this.onPressed,
    this.color = orangeWarningColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        textStyle: context.style.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          decoration: underline ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
