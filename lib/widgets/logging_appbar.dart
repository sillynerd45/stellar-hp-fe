import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class LoggingAppbar extends StatelessWidget {
  const LoggingAppbar({
    super.key,
    required this.title,
    this.forceElevated,
    this.automaticallyImplyLeading,
    this.useLeadingIcon = true,
  });

  final String title;
  final bool? forceElevated;
  final bool? automaticallyImplyLeading;
  final bool useLeadingIcon;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: stellarHpLightGreen,
      surfaceTintColor: stellarHpLightGreen,
      forceElevated: forceElevated ?? true,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      elevation: 4,
      titleSpacing: useLeadingIcon ? 4 : 24,
      scrolledUnderElevation: 4,
      shadowColor: stellarHpMediumBlueSplash,
      leading: useLeadingIcon
          ? IconButton(
              icon: const Icon(Icons.close_rounded),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(stopRecordRed),
                overlayColor: WidgetStateProperty.all<Color>(geminiSplashColor),
                side: WidgetStateProperty.all(const BorderSide(color: transparentColor)),
                iconSize: WidgetStateProperty.all<double?>(28),
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: context.style.titleMedium?.copyWith(
          color: stellarHpMediumBlue,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
