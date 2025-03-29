import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class HomeLoggingMenu extends StatelessWidget {
  const HomeLoggingMenu({
    super.key,
    required this.bodyTemp,
    required this.bloodPressure,
    required this.medication,
    required this.symptom,
  });

  final VoidCallback bodyTemp;
  final VoidCallback bloodPressure;
  final VoidCallback medication;
  final VoidCallback symptom;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StellarHpLoggingButton(
              title: 'Medication',
              asset: menuMedication,
              onPressed: medication,
            ),
            const SizedBox(width: 16),
            StellarHpLoggingButton(
              title: 'Symptom',
              asset: menuSymptom,
              onPressed: symptom,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StellarHpLoggingButton(
              title: 'Body Temp',
              asset: menuBodyTemp,
              onPressed: bodyTemp,
            ),
            const SizedBox(width: 16),
            StellarHpLoggingButton(
              title: 'Blood Pressure',
              asset: menuBloodPressure,
              onPressed: bloodPressure,
            ),
          ],
        ),
      ],
    );
  }
}
