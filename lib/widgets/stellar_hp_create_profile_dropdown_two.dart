import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class StellarHpCreateProfileDropdownTwo extends StatelessWidget {
  const StellarHpCreateProfileDropdownTwo({
    super.key,
    required this.width,
    this.buttonHeight,
    this.height,
    required this.initialSelection,
    required this.dropdownMenuEntries,
    this.onSelected,
    this.backgroundColor,
    this.selectedColor,
    this.textAndIconColor,
    this.borderRadius,
    this.elevation,
    this.buttonStylePadding,
    this.maxDropDownMenu,
    this.alignment = AlignmentDirectional.centerStart,
    this.iconSize,
  });

  final double width;
  final double? buttonHeight;
  final double? height;
  final String initialSelection;
  final List<String> dropdownMenuEntries;
  final Function(String?)? onSelected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textAndIconColor;
  final double? borderRadius;
  final int? elevation;
  final EdgeInsetsGeometry? buttonStylePadding;
  final int? maxDropDownMenu;
  final AlignmentGeometry alignment;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isDense: true,
        isExpanded: true,
        onChanged: onSelected,
        value: initialSelection,
        items: dropdownMenuEntries
            .map(
              (String item) => DropdownMenuItem<String>(
                alignment: alignment,
                value: item,
                child: Text(
                  item,
                  style: context.style.labelLarge?.copyWith(
                    color: textAndIconColor ?? Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        buttonStyleData: ButtonStyleData(
          height: buttonHeight ?? 50,
          width: width,
          padding: buttonStylePadding ?? const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            border: Border.all(
              color: backgroundColor ?? stellarHpBlue,
            ),
            color: backgroundColor ?? stellarHpBlue,
          ),
          elevation: elevation ?? 2,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: (height ?? 50.0) * (maxDropDownMenu ?? dropdownMenuEntries.length),
          width: width,
          padding: EdgeInsets.zero,
          offset: const Offset(0, -2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            color: backgroundColor ?? stellarHpBlue,
          ),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(20),
            thickness: WidgetStateProperty.all(2.5),
            thumbVisibility: WidgetStateProperty.all(true),
            thumbColor: WidgetStateProperty.all(Colors.white),
          ),
        ),
        iconStyleData: IconStyleData(
          icon: Transform.translate(
            offset: const Offset(0, -1),
            child: Icon(
              Icons.arrow_drop_down,
              size: iconSize ?? 28,
              color: textAndIconColor ?? Colors.white,
            ),
          ),
          openMenuIcon: Transform.translate(
            offset: const Offset(0, -1),
            child: Icon(
              Icons.arrow_drop_up,
              size: iconSize ?? 28,
              color: textAndIconColor ?? Colors.white,
            ),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          selectedMenuItemBuilder: (menuItemContext, child) {
            return Container(
              alignment: Alignment.centerRight,
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
