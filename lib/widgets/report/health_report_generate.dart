import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class HealthReportGenerate extends StatelessWidget {
  const HealthReportGenerate({
    super.key,
    required this.reportPeriodNotifier,
    required this.reportLangNotifier,
    required this.onSelectedPeriod,
    required this.onSelectedLanguage,
    required this.onTapGenerate,
  });

  final ValueNotifier<String> reportPeriodNotifier;
  final ValueNotifier<String> reportLangNotifier;
  final Function(String?)? onSelectedPeriod;
  final Function(String?)? onSelectedLanguage;
  final VoidCallback onTapGenerate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: constraints.maxWidth,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      'Generate',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: context.style.titleMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: constraints.maxWidth,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Period',
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
                            valueListenable: reportPeriodNotifier,
                            builder: (context, period, _) {
                              return StellarHpCreateProfileDropdownTwo(
                                width: 112,
                                elevation: 0,
                                buttonHeight: 44,
                                buttonStylePadding: const EdgeInsets.only(left: 12, right: 4),
                                initialSelection: period,
                                dropdownMenuEntries: const [
                                  '3 Days',
                                  '7 Days',
                                  '2 Weeks',
                                  '1 Month',
                                ],
                                onSelected: onSelectedPeriod,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 36,
                      margin: const EdgeInsets.only(bottom: 4),
                      child: LoggingBottomButton(
                        text: 'Generate Report',
                        useHorizontalPadding: false,
                        padding: EdgeInsets.zero,
                        color: orangeWarningColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        onTap: onTapGenerate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
