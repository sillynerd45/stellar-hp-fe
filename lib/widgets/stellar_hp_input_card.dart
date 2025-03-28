import 'package:flutter/material.dart';

class StellarHpInputCard extends StatelessWidget {
  const StellarHpInputCard({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(251, 253, 251, 1),
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(187, 187, 187, 0.7),
            offset: Offset(1, 2),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
