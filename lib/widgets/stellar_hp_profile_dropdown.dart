import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class StellarHpProfileDropdown extends StatelessWidget {
  const StellarHpProfileDropdown({
    super.key,
    required this.width,
    this.height,
    required this.dropdownMenuEntries,
    this.onSelected,
    this.backgroundColor,
    this.borderColor,
    this.selectedColor,
    this.textAndIconColor,
    this.borderRadius,
    this.elevation,
    required this.imageUrl,
  });

  final double width;
  final double? height;
  final List<StellarHpProfileDropdownMenuItem> dropdownMenuEntries;
  final Function(Object?)? onSelected;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? selectedColor;
  final Color? textAndIconColor;
  final double? borderRadius;
  final int? elevation;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isDense: true,
        isExpanded: true,
        onChanged: onSelected,
        customButton: Container(
          padding: const EdgeInsets.fromLTRB(1, 1, 1, 1),
          decoration: BoxDecoration(
              color: stellarHpLightGreen,
              borderRadius: const BorderRadius.all(Radius.circular(64)),
              border: Border.all(color: stellarHpBlue)),
          child: Builder(
            builder: (context) {
              double imageSize = 34;
              double borderRadius = 80;
              return ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                child: Image.asset(
                  imageUrl,
                  height: imageSize,
                  width: imageSize,
                  fit: BoxFit.fitWidth,
                  isAntiAlias: true,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (frame != null) return child;
                    return Container(
                      height: imageSize,
                      width: imageSize,
                      decoration: BoxDecoration(
                        color: stellarHpMediumBlue,
                        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                      ),
                    );
                  },
                  // loadingBuilder: (context, child, loadingProgress) {
                  //   if (loadingProgress == null) {
                  //     return child;
                  //   }
                  //   return Container(
                  //     height: imageSize,
                  //     width: imageSize,
                  //     decoration: BoxDecoration(
                  //       color: stellarHpMediumBlue,
                  //       borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                  //     ),
                  //   );
                  // },
                  errorBuilder: (context, exception, stacktrace) {
                    return Container(
                      height: imageSize,
                      width: imageSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                      ),
                      child: Image.asset(
                        imgStellarHpLogoShort,
                        height: imageSize,
                        width: imageSize,
                        fit: BoxFit.fitWidth,
                        isAntiAlias: true,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.high,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        items: dropdownMenuEntries
            .map(
              (StellarHpProfileDropdownMenuItem item) =>
                  DropdownMenuItem<StellarHpProfileDropdownMenuItem>(
                value: item,
                child: Row(
                  children: [
                    Image.asset(
                      item.asset,
                      height: 30,
                      width: 30,
                      fit: BoxFit.fitWidth,
                      isAntiAlias: true,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.text,
                        style: context.style.titleMedium?.copyWith(
                          color: textAndIconColor ?? Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        buttonStyleData: ButtonStyleData(
          height: height ?? 50,
          width: width,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            border: Border.all(
              color: borderColor ?? stellarHpBlue,
            ),
            color: backgroundColor ?? stellarHpBlue,
          ),
          elevation: elevation ?? 2,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: (height ?? 50.0) * dropdownMenuEntries.length,
          width: width,
          elevation: elevation ?? 2,
          padding: EdgeInsets.zero,
          offset: const Offset(-96, -4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            border: Border.all(
              color: borderColor ?? stellarHpBlue,
            ),
            color: backgroundColor ?? stellarHpBlue,
          ),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(20),
            thickness: WidgetStateProperty.all(2.5),
            thumbVisibility: WidgetStateProperty.all(true),
            thumbColor: WidgetStateProperty.all(Colors.white),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          selectedMenuItemBuilder: (menuItemContext, child) {
            return Container(
              height: height ?? 50,
              color: selectedColor ?? stellarHpGreen,
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class StellarHpProfileDropdownMenuItem {
  final String text;
  final String asset;

  const StellarHpProfileDropdownMenuItem({
    required this.text,
    required this.asset,
  });
}
