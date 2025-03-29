import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class LogListTitle extends StatelessWidget {
  const LogListTitle({
    super.key,
    required this.title,
    required this.showAllButton,
    required this.onPressAll,
  });

  final String title;
  final bool showAllButton;
  final VoidCallback onPressAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: context.style.titleMedium?.copyWith(
            color: Colors.black87,
            // fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 40,
          width: 40,
          child: Builder(
            builder: (context) {
              if (!showAllButton) {
                return const SizedBox();
              }

              return IconButton(
                padding: EdgeInsets.zero,
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'All ',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: context.style.titleMedium?.copyWith(
                        color: stellarHpMediumBlue,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      weight: 30,
                      color: stellarHpMediumBlue,
                    ),
                  ],
                ),
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(stellarHpMediumBlue),
                  overlayColor: WidgetStateProperty.all<Color>(stellarHpMediumBlueSplash),
                  side: WidgetStateProperty.all(const BorderSide(color: transparentColor)),
                ),
                onPressed: onPressAll,
              );
            },
          ),
        ),
      ],
    );
  }
}
