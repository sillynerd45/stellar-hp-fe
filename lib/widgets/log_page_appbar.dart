import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class LogPageAppbar extends StatelessWidget implements PreferredSizeWidget {
  const LogPageAppbar({
    super.key,
    required this.title,
    this.customTitle,
  });

  final String title;
  final String? customTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: stellarHpLightGreen,
      surfaceTintColor: stellarHpLightGreen,
      titleSpacing: 4,
      scrolledUnderElevation: 4,
      shadowColor: stellarHpMediumBlueSplash,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(stopRecordRed),
          overlayColor: WidgetStateProperty.all<Color>(geminiSplashColor),
          side: WidgetStateProperty.all(const BorderSide(color: transparentColor)),
          iconSize: WidgetStateProperty.all<double?>(28),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        customTitle ?? '$title Log',
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
