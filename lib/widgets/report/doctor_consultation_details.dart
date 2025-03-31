import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stellar_hp_fe/core/core.dart';

class DoctorConsultationDetails extends StatelessWidget {
  const DoctorConsultationDetails({
    super.key,
    required this.consultData,
  });

  final Consult consultData;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      String name = '-';
      String status = '-';
      String buttonTitle = '-';
      bool allowButtonAction = false;

      if (consultData is ConsultRequest) {
        name = (consultData as ConsultRequest).name;
        status = 'Asking for Consultation';
        buttonTitle = 'Accept';
        allowButtonAction = true;
      } else if (consultData is ConsultAccepted) {
        name = (consultData as ConsultAccepted).name;
        status = 'Waiting for Log Data';
        buttonTitle = '⌛';
      } else if (consultData is ConsultData) {
        name = (consultData as ConsultData).name;
        status = 'Data Available';
        buttonTitle = 'Open Health Logs';
        allowButtonAction = true;
      } else if (consultData is ConsultResult) {
        name = (consultData as ConsultResult).name;
        status = 'Consultation Done';
        buttonTitle = '✔️';
      }

      return Container(
        width: constraints.maxWidth,
        margin: const EdgeInsets.only(bottom: 12),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Builder(builder: (context) {
                return Text(
                  status,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: context.style.titleMedium?.copyWith(
                    color: stellarHpBlue,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  if (!allowButtonAction) return;
                  doctorAction(context, name);
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
                    buttonTitle,
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

  void doctorAction(BuildContext context, String name) async {
    try {
      // show waiting dialog
      MediDialog.loading(context);

      if (consultData is ConsultRequest) {
        String doctorRSA =
            await getIt<ConsultationProvider>().acceptNewConsult(userHash: (consultData as ConsultRequest).fromUser);
        bool isSuccess = await getIt<HpConsultAccepted>().invoke(
          publicKey: getIt<UserIdService>().getPublicKey(),
          name: name,
          userHash: (consultData as ConsultRequest).fromUser,
          doctorHash: (consultData as ConsultRequest).toDoctor,
          doctorRSA: doctorRSA,
          dataPeriod: (consultData as ConsultRequest).dataPeriod,
          consultHash: (consultData as ConsultRequest).consultHash,
        );

        if (!context.mounted) return;
        Navigator.pop(context);

        if (!isSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            MediDialog.aiFailureDialog(context, message: "please try again");
          });
        }
        return;
      }

      if (consultData is ConsultData) {
        bool isSuccess = await getIt<ConsultationProvider>().prepareShowUserHealthLogs(
          name: name,
          userRSA: getIt<HashService>().addPemHeaders((consultData as ConsultData).userRsa),
          userHash: (consultData as ConsultData).fromUser,
          dataHash: (consultData as ConsultData).dataHash,
          consultHash: (consultData as ConsultData).consultHash,
          consult: consultData as ConsultData,
        );

        if (!context.mounted) return;
        Navigator.pop(context);

        if (isSuccess) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (!context.mounted) return;
          context.pushReplacement(NavRoute.home);
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            MediDialog.aiFailureDialog(context, message: "please try again");
          });
        }
      }
    } catch (e) {
      //
    }
  }
}
