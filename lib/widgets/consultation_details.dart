import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stellar_hp_fe/core/core.dart';

class ConsultationDetails extends StatefulWidget {
  const ConsultationDetails({
    super.key,
    required this.consultData,
  });

  final Consult consultData;

  @override
  State<ConsultationDetails> createState() => _ConsultationDetailsState();
}

class _ConsultationDetailsState extends State<ConsultationDetails> {
  late ValueNotifier<String> consultationPeriodNotifier;
  bool getDiagnosisReport = false;

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
      String name = '-';
      String status = '-';
      bool resultReceived = false;

      if (widget.consultData is ConsultRequest) {
        name = getIt<ConsultationProvider>().getHashID((widget.consultData as ConsultRequest).toDoctor);
        status = 'Consultation Requested to Doctor';
      } else if (widget.consultData is ConsultAccepted) {
        name = getIt<ConsultationProvider>().getHashID((widget.consultData as ConsultAccepted).fromDoctor);
        status = 'Doctor Accept Consultation';
      } else if (widget.consultData is ConsultData) {
        name = getIt<ConsultationProvider>().getHashID((widget.consultData as ConsultData).toDoctor);
        status = 'Data Shared with Doctor';
      } else if (widget.consultData is ConsultResult) {
        name = getIt<ConsultationProvider>().getHashID((widget.consultData as ConsultResult).fromDoctor);
        resultReceived = true;
      }

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
                  name,
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
            Builder(builder: (context) {
              if (!resultReceived) {
                return Container(
                  width: constraints.maxWidth,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: const BoxDecoration(
                    color: stellarHpBlue,
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
                  child: Builder(builder: (context) {
                    return Text(
                      status,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: context.style.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        if (getDiagnosisReport) return;
                        getDiagnosisReport = true;

                        // show waiting dialog
                        MediDialog.loading(context);

                        bool isSuccess = await getIt<ConsultationProvider>().prepareShowDoctorDiagnosis(
                          doctorHash: (widget.consultData as ConsultResult).fromDoctor,
                          diagnosisHash: (widget.consultData as ConsultResult).resultHash,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);

                        if (!isSuccess) {
                          getDiagnosisReport = false;
                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            MediDialog.aiFailureDialog(context, message: "please try again");
                          });
                          return;
                        }

                        if (isSuccess) {
                          await Future.delayed(const Duration(milliseconds: 100));
                          if (!context.mounted) return;
                          context.pushReplacement(NavRoute.report);
                        }

                        getDiagnosisReport = false;
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
                          'Open Doctor Diagnosis',
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
              );
            })
          ],
        ),
      );
    });
  }
}
