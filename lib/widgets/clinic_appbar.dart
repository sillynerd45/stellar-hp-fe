import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class ClinicAppBar extends StatelessWidget {
  const ClinicAppBar({
    super.key,
    required this.userPhotoUrl,
    required this.onMenuSelected,
    required this.menuEntries,
  });

  final String userPhotoUrl;

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
        SizedBox(
          width: 132,
          child: Text(
            'Clinic',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: context.style.titleMedium?.copyWith(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
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
