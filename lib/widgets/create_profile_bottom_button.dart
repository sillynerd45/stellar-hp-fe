import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class CreateProfileBottomButton extends StatelessWidget {
  const CreateProfileBottomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.padding,
  });

  final String text;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        double buttonPadding = 32;
        double maxWidth = constraints.maxWidth;
        double maxWidthAfterPadding = maxWidth - buttonPadding;

        return Container(
          color: transparentColor,
          padding: padding ?? const EdgeInsets.only(bottom: 16, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all<double>(4),
                  shadowColor: WidgetStateProperty.all<Color>(stellarHpBlue),
                  backgroundColor: WidgetStateProperty.all<Color>(stellarHpBlue),
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  overlayColor: WidgetStateProperty.all<Color>(
                    const Color.fromRGBO(255, 255, 255, 0.05),
                  ),
                  fixedSize: WidgetStateProperty.all<Size>(
                    Size.fromWidth(maxWidthAfterPadding),
                  ),
                ),
                onPressed: onTap,
                child: Text(
                  text,
                  textAlign: TextAlign.start,
                  style: context.style.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
