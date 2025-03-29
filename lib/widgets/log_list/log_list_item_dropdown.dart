import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class LogListItemDropdown extends StatelessWidget {
  const LogListItemDropdown({
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
    this.offset,
  });

  final double width;
  final double? height;
  final List<LogDropdownMenuItem> dropdownMenuEntries;
  final Function(Object?)? onSelected;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? selectedColor;
  final Color? textAndIconColor;
  final double? borderRadius;
  final int? elevation;
  final Offset? offset;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isDense: true,
        isExpanded: true,
        onChanged: onSelected,
        customButton: Container(
          decoration: BoxDecoration(
            color: stellarHpLightGreen,
            borderRadius: const BorderRadius.all(
              Radius.circular(64),
            ),
            border: Border.all(width: 0, color: transparentColor),
          ),
          child: Builder(
            builder: (context) {
              double imageSize = 26;
              double borderRadius = 80;
              return ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                child: Image.asset(
                  menuOpen,
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
        ),
        items: dropdownMenuEntries
            .map(
              (LogDropdownMenuItem item) => DropdownMenuItem<LogDropdownMenuItem>(
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
          offset: offset ?? const Offset(-98, 0),
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
          height: height ?? 50.0,
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

class LogDropdownMenuItem {
  final String text;
  final String asset;

  const LogDropdownMenuItem({
    required this.text,
    required this.asset,
  });
}
