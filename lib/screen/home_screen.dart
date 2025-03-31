import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageScrollViewKey = const PageStorageKey<String>('TodayPageScrollView');
  final _datePageViewKey = const PageStorageKey<String>('TodayDatePageView');
  final _columnViewKey = const PageStorageKey<String>('TodayPageColumn');

  late PageController pageController;
  late String userPhotoUrl;
  late String userName;

  bool isChecking = false;

  List<StellarHpDate> dateList = [];
  String todayDate = '';
  String todayDateTitle = '';
  int todayDateIndex = 0;
  late ValueNotifier<StellarHpDate> chosenDate;
  late ValueNotifier<DailyHealthLogs> chosenDailyHealthLogs;

  void dateCheck() {
    final DateTime now = DateTime.now();
    final DateFormat titleFormatter = DateFormat('EEE, dd MMM');
    todayDate = titleFormatter.format(now);
    todayDateTitle = todayDate.replaceRange(0, 3, 'Today');
  }

  @override
  void initState() {
    userPhotoUrl = imgStellar;
    userName = getIt<MainProvider>().userProfile?.name ?? 'user';
    dateList = context.read<MainProvider>().stellarHpDateList;
    pageController = PageController(viewportFraction: 0.15);

    int i = context.read<MainProvider>().todayDateIndex;
    StellarHpDate? d = context.read<MainProvider>().chosenDate;
    chosenDate = ValueNotifier<StellarHpDate>(d ?? dateList.first);
    todayDateIndex = i != 0 ? i : 0;

    chosenDailyHealthLogs = ValueNotifier<DailyHealthLogs>(
        context.read<MainProvider>().chosenDailyHealthLogs ?? DailyHealthLogs.fromJson({}));

    context.read<MainProvider>().getHealthWorker(getIt<UserIdService>().getPublicKey());
    getIt<SorobanSmartContract>().listenToEvent();

    dateCheck();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    chosenDate.dispose();
    chosenDailyHealthLogs.dispose();
    super.dispose();
  }

  void previousDate() {
    if (todayDateIndex == dateList.length - 1) return;
    todayDateIndex = todayDateIndex + 1;
    chosenDate.value = dateList[todayDateIndex];
    context.read<MainProvider>().setTodayAndChosenDate(todayDateIndex, dateList[todayDateIndex]);
    chosenDailyHealthLogs.value =
        context.read<MainProvider>().getSetDailyHealthLogs(dateList[todayDateIndex].dateTime!);

    if (todayDateIndex >= 4 && todayDateIndex <= 57) {
      pageController.animateToPage(
        todayDateIndex - 3,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
      );
    }
  }

  void nextDate() {
    if (todayDateIndex == 0) return;
    todayDateIndex = todayDateIndex - 1;
    chosenDate.value = dateList[todayDateIndex];
    context.read<MainProvider>().setTodayAndChosenDate(todayDateIndex, dateList[todayDateIndex]);
    chosenDailyHealthLogs.value =
        context.read<MainProvider>().getSetDailyHealthLogs(dateList[todayDateIndex].dateTime!);

    if (todayDateIndex >= 3 && todayDateIndex <= 56) {
      pageController.animateToPage(
        todayDateIndex - 3,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
      );
    }
  }

  void forceUpdateDailyHealthLogs() {
    DailyHealthLogs data = context.read<MainProvider>().getSetDailyHealthLogs(chosenDate.value.dateTime!);
    chosenDailyHealthLogs.value = DailyHealthLogs.fromJson(data.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: stellarHpLightGreen,
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
                child: HomeAppBar(
                  userPhotoUrl: userPhotoUrl,
                  dateTitle: ValueListenableBuilder(
                    valueListenable: chosenDate,
                    builder: (context, date, _) {
                      bool isToday = todayDate == date.title;
                      return Text(
                        isToday ? todayDateTitle : date.title!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: context.style.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  onTapDateBack: () => previousDate(),
                  onTapDateNext: () => nextDate(),
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
                          // ! Date Picker
                          // ! ------------------------------------------------------------------
                          Container(
                            height: 60,
                            margin: const EdgeInsets.only(bottom: 24),
                            child: PageView.builder(
                              key: _datePageViewKey,
                              itemCount: dateList.length,
                              controller: pageController,
                              reverse: true,
                              padEnds: false,
                              pageSnapping: false,
                              itemBuilder: (BuildContext context, int index) {
                                bool isToday = todayDate == dateList[index].title;
                                return ValueListenableBuilder(
                                    valueListenable: chosenDate,
                                    builder: (context, date, _) {
                                      bool isChosen = dateList[index].title == date.title;
                                      return GestureDetector(
                                        onTap: () {
                                          todayDateIndex = index;
                                          chosenDate.value = dateList[index];
                                          context.read<MainProvider>().setTodayAndChosenDate(index, dateList[index]);
                                          chosenDailyHealthLogs.value = context
                                              .read<MainProvider>()
                                              .getSetDailyHealthLogs(dateList[index].dateTime!);
                                        },
                                        child: HomeDateItem(
                                            dateItem: dateList[index], isToday: isToday, isChosen: isChosen),
                                      );
                                    });
                              },
                            ),
                          ),
                          // ! Log Button
                          // ! ------------------------------------------------------------------
                          Builder(builder: (context) {
                            AccountType accountType = getIt<MainProvider>().userProfile!.accountType!;
                            String name = '-';
                            if (accountType == AccountType.user) {
                              name = getIt<MainProvider>().userProfile?.name ?? '-';
                            } else {
                              name = getIt<ConsultationProvider>().tempUserName;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: StellarHpUsernameButton(
                                text: name,
                              ),
                            );
                          }),
                          Builder(builder: (context) {
                            AccountType accountType = getIt<MainProvider>().userProfile!.accountType!;
                            if (accountType == AccountType.healthWorker) return const SizedBox();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: StellarHpPublicKeyButton(
                                text: getIt<UserIdService>().userKeypair.accountId,
                              ),
                            );
                          }),
                          Builder(builder: (context) {
                            AccountType accountType = getIt<MainProvider>().userProfile!.accountType!;
                            if (accountType == AccountType.healthWorker) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: HomeLoggingMenu(
                                bodyTemp: () async {
                                  bool? success = await BodyTemperatureLogSheet.show(context,
                                      chosenDate: chosenDate.value.dateTime);
                                  if (success != null && success) forceUpdateDailyHealthLogs();
                                },
                                bloodPressure: () async {
                                  bool? success =
                                      await BloodPressureLogSheet.show(context, chosenDate: chosenDate.value.dateTime);
                                  if (success != null && success) forceUpdateDailyHealthLogs();
                                },
                                medication: () async {
                                  bool? success =
                                      await MedicationLogSheet.show(context, chosenDate: chosenDate.value.dateTime);
                                  if (success != null && success) forceUpdateDailyHealthLogs();
                                },
                                symptom: () async {
                                  bool? success =
                                      await SymptomLogSheet.show(context, chosenDate: chosenDate.value.dateTime);
                                  if (success != null && success) forceUpdateDailyHealthLogs();
                                },
                              ),
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Builder(builder: (context) {
                              AccountType accountType = getIt<MainProvider>().userProfile!.accountType!;

                              if (accountType == AccountType.user) {
                                return StellarHpDoctorConsultationButton(
                                  text: 'Consult with Doctor',
                                  onPressed: () {
                                    context.pushReplacement(NavRoute.consultation);
                                  },
                                );
                              }

                              return Row(
                                spacing: 8,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StellarHpDoctorConsultationButton(
                                    text: 'Back',
                                    onPressed: () {
                                      context.pushReplacement(NavRoute.clinic);
                                    },
                                  ),
                                  StellarHpDoctorConsultationButton(
                                    text: 'Create Diagnose',
                                    onPressed: () {
                                      context.push(NavRoute.diagnose);
                                    },
                                  ),
                                ],
                              );
                            }),
                          ),
                          // ! Log List
                          // ! ------------------------------------------------------------------
                          LogListMedicine(
                            padding: const EdgeInsets.only(top: 8),
                            chosenDailyHealthLogs: chosenDailyHealthLogs,
                            chosenDate: chosenDate,
                            onPressAll: () {
                              context.push(NavRoute.medicineLog, extra: {
                                'chosenDailyHealthLogs': chosenDailyHealthLogs,
                                'chosenDate': chosenDate,
                              });
                            },
                          ),
                          LogListSymptom(
                            chosenDailyHealthLogs: chosenDailyHealthLogs,
                            chosenDate: chosenDate,
                            padding: const EdgeInsets.only(top: 8),
                            onPressAll: () {
                              context.push(NavRoute.symptomLog, extra: {
                                'chosenDailyHealthLogs': chosenDailyHealthLogs,
                                'chosenDate': chosenDate,
                              });
                            },
                          ),
                          LogListBodyTemperature(
                            chosenDailyHealthLogs: chosenDailyHealthLogs,
                            chosenDate: chosenDate,
                            padding: const EdgeInsets.only(top: 8),
                            onPressAll: () {
                              context.push(NavRoute.bodyTemperatureLog, extra: {
                                'chosenDailyHealthLogs': chosenDailyHealthLogs,
                                'chosenDate': chosenDate,
                              });
                            },
                          ),
                          LogListBloodPressure(
                            chosenDailyHealthLogs: chosenDailyHealthLogs,
                            chosenDate: chosenDate,
                            padding: const EdgeInsets.only(top: 8),
                            onPressAll: () {
                              context.push(NavRoute.bloodPressureLog, extra: {
                                'chosenDailyHealthLogs': chosenDailyHealthLogs,
                                'chosenDate': chosenDate,
                              });
                            },
                          ),
                          Selector<MainProvider, int>(
                            selector: (context, update) => update.stellarUpdate,
                            builder: (context, count, child) {
                              if (count != 0) {
                                WidgetsBinding.instance.addPostFrameCallback((_) async {
                                  forceUpdateDailyHealthLogs();
                                });
                              }
                              return const SizedBox(height: 80);
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
}
