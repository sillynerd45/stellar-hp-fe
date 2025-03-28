import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class AppElevatedButton extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;

  const AppElevatedButton({
    super.key,
    required this.title,
    this.onPressed,
  });

  @override
  State<AppElevatedButton> createState() => _AppElevatedButtonState();
}

class _AppElevatedButtonState extends State<AppElevatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: buttonBlackShadow,
              spreadRadius: _isHovered ? 1 : 0,
              blurRadius: _isHovered ? 2 : 0,
              offset: Offset(0, _isHovered ? 2 : 0),
            ),
          ],
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          elevation: _isHovered ? 4 : 2,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              child: Text(
                widget.title,
                style: context.style.titleSmall?.copyWith(
                  fontSize: 14,
                  letterSpacing: 0.25,
                  fontWeight: FontWeight.w500,
                  color: stellarHpBlue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
