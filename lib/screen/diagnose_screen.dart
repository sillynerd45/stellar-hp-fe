import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class DiagnoseScreen extends StatefulWidget {
  const DiagnoseScreen({super.key});

  @override
  State<DiagnoseScreen> createState() => _DiagnoseScreenState();
}

class _DiagnoseScreenState extends State<DiagnoseScreen> {
  late TextEditingController diagnosisController;

  @override
  void initState() {
    super.initState();
    diagnosisController = TextEditingController();
  }

  @override
  void dispose() {
    diagnosisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.1, 0.25, 0.5, 0.75, 0.9],
                  colors: [
                    Color.fromRGBO(0, 166, 166, 0.1),
                    Color.fromRGBO(255, 255, 255, 0.15),
                    Color.fromRGBO(255, 255, 255, 1),
                    Color.fromRGBO(255, 255, 255, 0.15),
                    Color.fromRGBO(11, 143, 172, 0.1),
                  ],
                ),
              ),
            ),
            Align(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 128, top: 8),
                  child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    double maxWidth = constraints.maxWidth;
                    double adjustedLogoWidth = maxWidth >= appMaxScreenWidth ? appMaxScreenWidth : maxWidth;
                    return SizedBox(
                      width: adjustedLogoWidth,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Diagnosis Summary',
                              textAlign: TextAlign.center,
                              style: context.style.headlineSmall?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Provide a concise and comprehensible summary of the diagnosis for the patient',
                              textAlign: TextAlign.center,
                              style: context.style.titleMedium?.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          StellarHpInputCard(
                            children: [
                              StellarHpTextField(
                                label: 'health log data-based diagnosis',
                                color: stellarHpBlue,
                                textController: diagnosisController,
                                textInputAction: TextInputAction.newline,
                                maxLines: 15,
                                alignLabelWithHint: true,
                                keyboardType: TextInputType.multiline,
                              ),
                              LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                double maxWidth = constraints.maxWidth;
                                double adjustedLogoWidth = maxWidth >= appMaxScreenWidth ? appMaxScreenWidth : maxWidth;
                                return SizedBox(
                                  width: adjustedLogoWidth,
                                  child: CreateProfileBottomButton(
                                    text: 'Send Diagnosis',
                                    padding: const EdgeInsets.only(top: 16),
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus?.unfocus();

                                      // check profile value
                                      String diagnosis = diagnosisController.text;

                                      if (diagnosis.isEmpty) {
                                        MediDialog.aiFailureDialog(context, message: 'please check your diagnosis');
                                        return;
                                      }

                                      // show waiting dialog
                                      MediDialog.loading(context);

                                      bool isSuccess = await getIt<HpConsultResult>().invoke(
                                        publicKey: getIt<UserIdService>().getPublicKey(),
                                        name: getIt<ConsultationProvider>().tempUserName,
                                        userHash: getIt<ConsultationProvider>().tempConsultData!.fromUser,
                                        doctorHash: getIt<MainProvider>().userProfile!.logHash!,
                                        userRSA: getIt<ConsultationProvider>().tempUserRSA,
                                        resultData: diagnosis,
                                        consultHash: getIt<ConsultationProvider>().tempConsultHash,
                                      );

                                      if (!context.mounted) return;
                                      if (!isSuccess) {
                                        Navigator.pop(context);
                                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                                          MediDialog.aiFailureDialog(context, message: 'please try again');
                                        });
                                        return;
                                      }

                                      GoRouter.of(context).popAllAndPushReplaced(NavRoute.clinic);
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
