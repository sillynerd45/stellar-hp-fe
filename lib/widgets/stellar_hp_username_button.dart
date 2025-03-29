import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class StellarHpUsernameButton extends StatelessWidget {
  final String text;
  final bool underline;

  const StellarHpUsernameButton({
    super.key,
    required this.text,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: stellarHpBlue,
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
      onPressed: () {},
      child: Text(text),
    );
  }
}
