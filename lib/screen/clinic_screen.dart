import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class ClinicScreen extends StatefulWidget {
  const ClinicScreen({super.key});

  @override
  State<ClinicScreen> createState() => _ClinicScreenState();
}

class _ClinicScreenState extends State<ClinicScreen> {
  final _pageScrollViewKey = const PageStorageKey<String>('ConsultationPageScrollView');
  final _columnViewKey = const PageStorageKey<String>('ConsultationPageColumn');

  late String userPhotoUrl;

  late ValueNotifier<List<Consult>> consultationContent;

  @override
  void initState() {
    super.initState();
    userPhotoUrl = imgStellar;
    consultationContent = ValueNotifier<List<Consult>>(context.read<ConsultationProvider>().consultList);
    getIt<SorobanSmartContract>().listenToEvent();
  }

  @override
  void dispose() {
    consultationContent.dispose();
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
                child: ClinicAppBar(
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
                          ConsultationRequestList(consultList: consultationContent),
                          Selector<ConsultationProvider, int>(
                            selector: (context, update) => update.stellarUpdate,
                            builder: (context, count, child) {
                              if (count != 0) {
                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  forceUpdateHealthReportList();
                                });
                              }
                              return const SizedBox();
                            },
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

  void forceUpdateHealthReportList() {
    consultationContent.value = context.read<ConsultationProvider>().consultList;
  }
}
