import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _pageScrollViewKey = const PageStorageKey<String>('ConsultationPageScrollView');
  final _columnViewKey = const PageStorageKey<String>('ConsultationPageColumn');

  late String userPhotoUrl;

  late ValueNotifier<String> consultationPeriodNotifier;
  late ValueNotifier<List<HealthWorker>> healthWorkerContent;
  late ValueNotifier<List<Consult>> consultContent;

  @override
  void initState() {
    super.initState();
    userPhotoUrl = imgStellar;
    consultationPeriodNotifier = ValueNotifier<String>(getIt<MainProvider>().reportPeriod);
    healthWorkerContent = ValueNotifier<List<HealthWorker>>(getIt<MainProvider>().healthWorkerList);
    consultContent = ValueNotifier<List<Consult>>(getIt<ConsultationProvider>().consultList);
  }

  @override
  void dispose() {
    consultationPeriodNotifier.dispose();
    healthWorkerContent.dispose();
    consultContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: stellarHpLightGreen,
        surfaceTintColor: stellarHpLightGreen,
        scrolledUnderElevation: 4,
        shadowColor: stellarHpMediumBlueSplash,
        title: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = constraints.maxWidth;
          double adjustedLogoWidth = maxWidth >= appMaxScreenWidth ? appMaxScreenWidth : maxWidth;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: adjustedLogoWidth,
                child: ConsultationAppBar(
                  userPhotoUrl: userPhotoUrl,
                  menuEntries: const [
                    StellarHpProfileDropdownMenuItem(text: 'Log Out', asset: menuLogout),
                  ],
                  onMenuSelected: (value) async {
                    if (value == null) return;
                    String menu = (value as StellarHpProfileDropdownMenuItem).text;
                    switch (menu) {
                      case 'Log Out':
                        bool success = await context.read<MainProvider>().signingOut();
                        if (!context.mounted) return;
                        if (!success) {
                          bool inProgress = context.read<MainProvider>().isHealthLogDecryptionInProgress;
                          if (inProgress) {
                            MediDialog.aiFailureDialog(context,
                                message: "Decryption is in progress, please wait a minute");
                          } else {
                            MediDialog.aiFailureDialog(context, message: "Unable to log out at the moment");
                          }
                          return;
                        }

                        // go to signin page
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          GoRouter.of(context).popAllAndPushReplaced(NavRoute.signIn);
                        });
                    }
                  },
                ),
              ),
            ],
          );
        }),
      ),
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
            alignment: Alignment.topCenter,
            child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              double maxWidth = constraints.maxWidth;
              double adjustedLogoWidth = maxWidth >= appMaxScreenWidth ? appMaxScreenWidth : maxWidth;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: adjustedLogoWidth,
                    child: SingleChildScrollView(
                      key: _pageScrollViewKey,
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        key: _columnViewKey,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 16),
                            child: StellarHpUsernameButton(
                              text: getIt<MainProvider>().userProfile?.name ?? '-',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: StellarHpPublicKeyButton(
                              text: getIt<UserIdService>().userKeypair.accountId,
                            ),
                          ),
                          HealthWorkerList(reportContent: healthWorkerContent),
                          ConsultList(consultContent: consultContent),
                          Selector<MainProvider, int>(
                            selector: (context, update) => update.stellarUpdate,
                            builder: (context, count, child) {
                              if (count != 0) {
                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  forceUpdateHealthWorkerList();
                                });
                              }
                              return const SizedBox();
                            },
                          ),
                          Selector<ConsultationProvider, int>(
                            selector: (context, update) => update.stellarUpdate,
                            builder: (context, count, child) {
                              if (count != 0) {
                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  forceUpdateConsultContentList();
                                });
                              }
                              return const SizedBox();
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 36),
                            child: StellarHpDoctorConsultationButton(
                              text: 'Back',
                              color: stellarHpBlue,
                              onPressed: () {
                                context.pushReplacement(NavRoute.home);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  void forceUpdateHealthWorkerList() {
    healthWorkerContent.value = context.read<MainProvider>().healthWorkerList;
  }

  void forceUpdateConsultContentList() {
    consultContent.value = context.read<ConsultationProvider>().consultList;
  }
}
