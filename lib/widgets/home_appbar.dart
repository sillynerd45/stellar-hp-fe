import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.userPhotoUrl,
    required this.dateTitle,
    required this.onTapDateBack,
    required this.onTapDateNext,
    required this.onMenuSelected,
    required this.menuEntries,
  });

  final String userPhotoUrl;

  final Widget dateTitle;
  final VoidCallback onTapDateBack;
  final VoidCallback onTapDateNext;
  final Function(Object?)? onMenuSelected;
  final List<StellarHpProfileDropdownMenuItem> menuEntries;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(builder: (context) {
          double imageSize = 30;
          return Image.asset(
            imgStellarHpLogoShort,
            height: imageSize,
            width: imageSize,
            fit: BoxFit.fitWidth,
            isAntiAlias: true,
            gaplessPlayback: true,
            filterQuality: FilterQuality.high,
          );
        }),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(stellarHpMediumBlue),
                overlayColor: WidgetStateProperty.all<Color>(stellarHpMediumBlueSplash),
                side: WidgetStateProperty.all(const BorderSide(color: transparentColor)),
              ),
              onPressed: onTapDateBack,
            ),
            SizedBox(
              width: 132,
              child: Center(
                child: dateTitle,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(stellarHpMediumBlue),
                overlayColor: WidgetStateProperty.all<Color>(stellarHpMediumBlueSplash),
                side: WidgetStateProperty.all(const BorderSide(color: transparentColor)),
              ),
              onPressed: onTapDateNext,
            ),
          ],
        ),
        StellarHpProfileDropdown(
          width: 146,
          imageUrl: userPhotoUrl,
          backgroundColor: Colors.white,
          textAndIconColor: stellarHpBlue,
          borderColor: stellarHpMediumBlueSplash,
          dropdownMenuEntries: menuEntries,
          onSelected: onMenuSelected,
        ),
      ],
    );
  }
}
