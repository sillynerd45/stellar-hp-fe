import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class BodyTemperatureLogScreen extends StatefulWidget {
  final ValueNotifier<StellarHpDate> chosenDate;
  final ValueNotifier<DailyHealthLogs> chosenDailyHealthLogs;

  const BodyTemperatureLogScreen({
    super.key,
    required this.chosenDailyHealthLogs,
    required this.chosenDate,
  });

  @override
  State<BodyTemperatureLogScreen> createState() => _BodyTemperatureLogScreenState();
}

class _BodyTemperatureLogScreenState extends State<BodyTemperatureLogScreen> {
  String title = 'Body Temperature';
  String dateTitle = '';

  @override
  void initState() {
    super.initState();
    dateCheck();
  }

  void dateCheck() {
    DateFormat titleFormatter = DateFormat('EEEE, dd MMMM yyyy');
    dateTitle = titleFormatter.format(widget.chosenDate.value.dateTime!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: stellarHpLightGreen,
      appBar: LogPageAppbar(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    dateTitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: context.style.titleMedium?.copyWith(
                      color: Colors.black87,
                      // fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (BuildContext level1Ctx, BoxConstraints level1Constraints) {
                return Container(
                  width: level1Constraints.maxWidth,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    valueListenable: widget.chosenDailyHealthLogs,
                    builder: (context, dailyLog, _) {
                      int itemCount = dailyLog.bodyTemperature.length;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: itemCount,
                        itemBuilder: (BuildContext viewContext, int index) {
                          BodyTemperature e = dailyLog.bodyTemperature[index];

                          DateTime d = DateTime.fromMillisecondsSinceEpoch(e.epochTimestamp);
                          String hour = d.hour.toString();
                          if (hour.length == 1) hour = '0${d.hour}';
                          String minute = d.minute.toString();
                          if (minute.length == 1) minute = '0${d.minute}';

                          bool isLastIndex = index == itemCount - 1;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${e.temperature} ${e.unit}',
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
                                    margin: const EdgeInsets.only(top: 12, bottom: 16),
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
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Future<void> editLog(
    BuildContext context,
    BodyTemperature e,
    ValueNotifier<StellarHpDate> chosenDate,
    ValueNotifier<DailyHealthLogs> chosenDailyHealthLogs,
  ) async {
    bool? success = await BodyTemperatureLogSheet.show(
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
    BodyTemperature e,
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
