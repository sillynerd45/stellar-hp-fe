import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class StellarHpLoggingButton extends StatelessWidget {
  const StellarHpLoggingButton({
    super.key,
    required this.title,
    required this.asset,
    required this.onPressed,
  });

  final String title;
  final String asset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 142,
      child: ElevatedButton.icon(
        icon: Image.asset(
          asset,
          height: 36,
          width: 36,
          fit: BoxFit.fitWidth,
          isAntiAlias: true,
          gaplessPlayback: true,
          filterQuality: FilterQuality.high,
        ),
        label: Text(
          title,
          maxLines: 2,
          softWrap: true,
        ),
        style: ButtonStyle(
          alignment: Alignment.centerLeft,
          backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
          foregroundColor: WidgetStateProperty.all<Color>(stellarHpBlue),
          side: WidgetStateProperty.all(
            const BorderSide(
              color: stellarHpBlue,
              width: 0.5,
            ),
          ),
          elevation: WidgetStateProperty.all<double>(4),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry?>(
            const EdgeInsets.fromLTRB(8, 4, 8, 4),
          ),
          textStyle: WidgetStateProperty.all<TextStyle?>(
            context.style.titleSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          shape: WidgetStateProperty.all<OutlinedBorder?>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
