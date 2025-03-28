import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StellarHpTextField extends StatelessWidget {
  const StellarHpTextField({
    super.key,
    required this.label,
    required this.color,
    required this.textController,
    this.inputFormatters,
    this.keyboardType,
    this.maxLines,
    this.alignLabelWithHint,
    this.scrollPadding,
    this.suffixText,
    this.borderRadius = 8,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
  });

  final String label;
  final Color color;
  final TextEditingController textController;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool? alignLabelWithHint;
  final EdgeInsets? scrollPadding;
  final String? suffixText;
  final double borderRadius;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      cursorHeight: 22.0,
      cursorColor: color,
      maxLines: maxLines,
      focusNode: focusNode,
      scrollPadding: scrollPadding ?? const EdgeInsets.only(bottom: 160),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.6,
          ),
      keyboardType: keyboardType ?? TextInputType.text,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        isDense: false,
        alignLabelWithHint: alignLabelWithHint,
        contentPadding: const EdgeInsets.only(
          top: 10.0,
          bottom: 10.0,
          left: 14.0,
          right: 14.0,
        ),
        suffixText: suffixText,
        suffixStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.normal,
              letterSpacing: 1.0,
            ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: label,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.normal,
              letterSpacing: 1.0,
            ),
        errorStyle: const TextStyle(
          height: 0.0,
          fontSize: 0.0,
          letterSpacing: 0.0,
        ),
        border: OutlineInputBorder(
          gapPadding: 6.0,
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: color),
        ),
        enabledBorder: OutlineInputBorder(
          gapPadding: 6.0,
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: color),
        ),
        focusedBorder: OutlineInputBorder(
          gapPadding: 6.0,
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: color),
        ),
      ),
      inputFormatters: inputFormatters,
    );
  }
}
