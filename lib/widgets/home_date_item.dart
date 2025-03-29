import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';

class HomeDateItem extends StatelessWidget {
  const HomeDateItem({
    super.key,
    required this.dateItem,
    required this.isToday,
    required this.isChosen,
  });

  final StellarHpDate dateItem;
  final bool isToday;
  final bool isChosen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 4, 2, 4),
      decoration: BoxDecoration(
        color: isChosen ? stellarHpMediumBlue : Colors.white60,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          width: 0.75,
          color: stellarHpMediumBlue,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dateItem.date ?? '',
            maxLines: 1,
            style: context.style.titleMedium?.copyWith(
              color: isChosen ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            isToday ? 'Today' : dateItem.day ?? '',
            maxLines: 1,
            style: context.style.titleSmall?.copyWith(
              color: isChosen ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
