import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class HealthWorkerItem extends StatefulWidget {
  const HealthWorkerItem({
    super.key,
    required this.worker,
  });

  final HealthWorker worker;

  @override
  State<HealthWorkerItem> createState() => _HealthWorkerItemState();
}

class _HealthWorkerItemState extends State<HealthWorkerItem> {
  late ValueNotifier<String> consultationPeriodNotifier;
  bool creatingConsultation = false;

  @override
  void initState() {
    super.initState();
    consultationPeriodNotifier = ValueNotifier<String>(getIt<MainProvider>().reportPeriod);
  }

  @override
  void dispose() {
    consultationPeriodNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        width: constraints.maxWidth,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(187, 187, 187, 0.3),
              offset: Offset(1, 1),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Builder(builder: (context) {
                return Text(
                  widget.worker.name ?? '---',
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  style: context.style.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: stellarHpGreen,
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Health Log Period to share',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: context.style.titleMedium?.copyWith(
                      color: stellarHpBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ValueListenableBuilder(
                      valueListenable: consultationPeriodNotifier,
                      builder: (context, period, _) {
                        return StellarHpCreateProfileDropdownTwo(
                          width: 112,
                          elevation: 0,
                          buttonHeight: 44,
                          buttonStylePadding: const EdgeInsets.only(left: 12, right: 4),
                          initialSelection: period,
                          dropdownMenuEntries: const [
                            '3 Days',
                            '5 Days',
                            '7 Days',
                          ],
                          onSelected: (period) {
                            if (period != null) {
                              consultationPeriodNotifier.value = period;
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  if (creatingConsultation) return;
                  creatingConsultation = true;

                  await getIt<ConsultationProvider>().createNewConsult(
                    doctorHash: widget.worker.hashId!,
                    dataPeriod: consultationPeriodNotifier.value,
                  );

                  creatingConsultation = false;
                },
                child: Container(
                  width: constraints.maxWidth,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    color: orangeWarningColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(187, 187, 187, 0.3),
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    'Make Consultation',
                    textAlign: TextAlign.start,
                    style: context.style.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
