import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class LogListBloodPressure extends StatelessWidget {
  const LogListBloodPressure({
    super.key,
    this.title = 'Blood Pressure',
    required this.chosenDailyHealthLogs,
    required this.chosenDate,
    required this.onPressAll,
    this.padding,
  });

  final String title;
  final ValueNotifier<StellarHpDate> chosenDate;
  final ValueNotifier<DailyHealthLogs> chosenDailyHealthLogs;
  final VoidCallback onPressAll;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (BuildContext topContext, BoxConstraints topConstraints) {
          return Container(
            width: topConstraints.maxWidth,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder(
                  valueListenable: chosenDailyHealthLogs,
                  builder: (context, dailyLog, _) {
                    bool showAllButton = true;
                    if (dailyLog.bloodPressure.length <= 3) {
                      showAllButton = false;
                    }
                    return LogListTitle(
                      title: title,
                      showAllButton: showAllButton,
                      onPressAll: onPressAll,
                    );
                  },
                ),
                LayoutBuilder(
                  builder: (BuildContext level1Ctx, BoxConstraints level1Constraints) {
                    return Container(
                      width: level1Constraints.maxWidth,
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
                      child: ValueListenableBuilder(
                        valueListenable: chosenDailyHealthLogs,
                        builder: (context, dailyLog, _) {
                          if (dailyLog.encryptedData != null) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: Text(
                                'Data decryption is in progress.',
                                maxLines: 2,
                                style: context.style.titleMedium?.copyWith(
                                  color: stellarHpBlue,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          }

                          if (dailyLog.bloodPressure.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: Text(
                                'No ${title.toLowerCase()} logs yet.',
                                maxLines: 2,
                                style: context.style.titleMedium?.copyWith(
                                  color: stellarHpBlue,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          }

                          int totalItem = dailyLog.bloodPressure.length;
                          int itemCount = totalItem >= 3 ? 3 : totalItem;
                          return ListView.builder(
                            key: ValueKey('BloodPressure-LV-${chosenDate.value.unixTime}'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: itemCount,
                            itemBuilder: (BuildContext viewContext, int index) {
                              BloodPressure e = dailyLog.bloodPressure[index];

                              DateTime d = DateTime.fromMillisecondsSinceEpoch(e.epochTimestamp);
                              String hour = d.hour.toString();
                              if (hour.length == 1) hour = '0${d.hour}';
                              String minute = d.minute.toString();
                              if (minute.length == 1) minute = '0${d.minute}';

                              bool isLastIndex = index == itemCount - 1;

                              return Column(
                                key: ValueKey('BloodPressure-${e.epochTimestamp}'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${e.systolic}/${e.diastolic} mmHg',
                                          maxLines: 10,
                                          style: context.style.titleMedium?.copyWith(
                                            color: stellarHpBlue,
                                            fontWeight: logFontWeightMainText,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child:  Text(
                                          '$hour:$minute',
                                          maxLines: 1,
                                          style: context.style.titleMedium?.copyWith(
                                            color: stellarHpBlue,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Builder(
                                    builder: (context) {
                                      if (isLastIndex) return const SizedBox();
                                      return Container(
                                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.black12, width: 0.95),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> editLog(
    BuildContext context,
    BloodPressure e,
    ValueNotifier<StellarHpDate> chosenDate,
    ValueNotifier<DailyHealthLogs> chosenDailyHealthLogs,
  ) async {
    bool? success = await BloodPressureLogSheet.show(
      context,
      currentLog: e,
    );
    if (!context.mounted) return;
    // update data
    if (success != null && success) {
      DailyHealthLogs data =
          context.read<MainProvider>().getSetDailyHealthLogs(chosenDate.value.dateTime!);
      chosenDailyHealthLogs.value = DailyHealthLogs.fromJson(data.toJson());
    }
  }

  Future<void> deleteLog(
    BuildContext context,
    BloodPressure e,
    ValueNotifier<StellarHpDate> chosenDate,
    ValueNotifier<DailyHealthLogs> chosenDailyHealthLogs,
  ) async {
    bool success =
        await context.read<MainProvider>().deleteHealthLog(e, chosenDate.value.dateTime!);
    if (!success) {
      if (!context.mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        bool inProgress = context.read<MainProvider>().isHealthLogDecryptionInProgress;
        if (inProgress) {
          MediDialog.aiFailureDialog(context,
              message: "Decryption is in progress, please wait a minute");
        } else {
          MediDialog.aiFailureDialog(context, message: "Unable to delete at the moment");
        }
      });
      return;
    }
    if (!context.mounted) return;
    // update data
    DailyHealthLogs data =
        context.read<MainProvider>().getSetDailyHealthLogs(chosenDate.value.dateTime!);
    chosenDailyHealthLogs.value = DailyHealthLogs.fromJson(data.toJson());
  }
}
