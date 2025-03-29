import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stellar_hp_fe/core/core.dart';

class StellarHpPublicKeyButton extends StatelessWidget {
  final String text;
  final bool underline;

  const StellarHpPublicKeyButton({
    super.key,
    required this.text,
    this.underline = true,
  });

  String truncateText(String text, {int maxLength = 11}) {
    if (text.length <= maxLength) return text;

    final partLength = (maxLength - 3) ~/ 2;
    return '${text.substring(0, partLength)}...'
        '${text.substring(text.length - partLength)}';
  }

  Future<void> _copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text copied to clipboard'),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: stellarHpBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: stellarHpBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        textStyle: context.style.titleSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          decoration: underline ? TextDecoration.underline : TextDecoration.none,
          decorationColor: stellarHpBlue,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12)
      ),
      onPressed: (){
        _copyToClipboard(text, context);
      },
      child: Text(truncateText(text)),
    );
  }
}
