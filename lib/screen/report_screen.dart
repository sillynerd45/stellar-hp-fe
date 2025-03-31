import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late TextEditingController reportController;

  @override
  void initState() {
    super.initState();
    reportController = TextEditingController();
    reportController.text = getIt<ConsultationProvider>().tempDiagnosis;
  }

  @override
  void dispose() {
    reportController.dispose();
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
                              'This diagnosis is based on your health log data',
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
                                textController: reportController,
                                textInputAction: TextInputAction.newline,
                                maxLines: 15,
                                readOnly: true,
                                alignLabelWithHint: true,
                                keyboardType: TextInputType.multiline,
                              ),
                              LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                double maxWidth = constraints.maxWidth;
                                double adjustedLogoWidth = maxWidth >= appMaxScreenWidth ? appMaxScreenWidth : maxWidth;
                                return SizedBox(
                                  width: adjustedLogoWidth,
                                  child: CreateProfileBottomButton(
                                    text: 'Back',
                                    padding: const EdgeInsets.only(top: 16),
                                    onTap: () async {
                                      context.pushReplacement(NavRoute.consultation);
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
