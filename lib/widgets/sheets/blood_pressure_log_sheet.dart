import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class BloodPressureLogSheet extends StatefulWidget {
  const BloodPressureLogSheet({
    super.key,
    required this.childSize,
    required this.maxWidth,
    required this.sizedBoxHeight,
    required this.containerHeight1,
    required this.containerHeight2,
    required this.buttonTopPadding,
    required this.buttonHeight,
    required this.viewInsetsBottom,
    this.previousLog,
    this.chosenDate,
    this.fromDashboard,
  });

  final double childSize;
  final double maxWidth;
  final double sizedBoxHeight;
  final double containerHeight1;
  final double containerHeight2;
  final double buttonTopPadding;
  final double buttonHeight;
  final double viewInsetsBottom;
  final BloodPressure? previousLog;
  final DateTime? chosenDate;
  final bool? fromDashboard;

  static const double _sizedBoxHeight = 16;

  static Future<bool?> show(
    BuildContext context, {
    BloodPressure? currentLog,
    DateTime? chosenDate,
    bool? fromDashboard,
  }) async {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    double paddingTop = MediaQuery.of(context).viewPadding.top;
    if (paddingTop == 0) paddingTop = 40;
    double heightWithoutSafeArea = displayHeight - paddingTop;

    double sizedBoxNumberInSheet = 4;
    double containerHeight1 = 110;
    double containerHeight2 = 112;
    double buttonTopPadding = 32;
    double buttonHeight = 42;
    double totalSizedBoxHeight = _sizedBoxHeight * sizedBoxNumberInSheet;
    double totalSheetHeight =
        kToolbarHeight + containerHeight1 + containerHeight2 + buttonTopPadding + buttonHeight + totalSizedBoxHeight;

    double recommendedChildSize = totalSheetHeight > heightWithoutSafeArea
        ? (heightWithoutSafeArea / displayHeight)
        : (totalSheetHeight / displayHeight);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black45,
      backgroundColor: stellarHpLightGreen,
      builder: (BuildContext innerContext) {
        double viewInsetsBottom = MediaQuery.of(innerContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: viewInsetsBottom),
          child: BloodPressureLogSheet(
            childSize: recommendedChildSize,
            maxWidth: displayWidth,
            sizedBoxHeight: _sizedBoxHeight,
            containerHeight1: containerHeight1,
            containerHeight2: containerHeight2,
            buttonTopPadding: buttonTopPadding,
            buttonHeight: buttonHeight,
            viewInsetsBottom: viewInsetsBottom,
            previousLog: currentLog,
            chosenDate: chosenDate,
            fromDashboard: fromDashboard,
          ),
        );
      },
    );
  }

  @override
  State<BloodPressureLogSheet> createState() => _BloodPressureLogSheetState();
}

class _BloodPressureLogSheetState extends State<BloodPressureLogSheet> {
  // for Date and Time
  late ValueNotifier<Time> timeNotifier;
  late ValueNotifier<String> dateNotifier;
  late DateTime datePickerInitialDate;

  // for Blood Pressure
  late TextEditingController systolicController;
  late TextEditingController diastolicController;
  late FocusNode diastolicFocus;

  // for Add Log button
  bool isForUpdateLog = false;
  ValueNotifier<bool> isButtonEnabled = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    diastolicFocus = FocusNode();

    if (widget.previousLog != null) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(widget.previousLog!.epochTimestamp);
      systolicController = TextEditingController(text: '${widget.previousLog!.systolic}');
      diastolicController = TextEditingController(text: '${widget.previousLog!.diastolic}');
      isButtonEnabled = ValueNotifier<bool>(true);
      dateNotifier = ValueNotifier<String>(formatDate(dt));
      datePickerInitialDate = dt;
      timeNotifier = ValueNotifier<Time>(Time.fromTimeOfDay(TimeOfDay.fromDateTime(dt), 0));
      if (widget.fromDashboard == null) isForUpdateLog = true;
      return;
    }

    systolicController = TextEditingController();
    diastolicController = TextEditingController();
    isButtonEnabled = ValueNotifier<bool>(false);
    timeNotifier = ValueNotifier<Time>(Time.fromTimeOfDay(TimeOfDay.now(), 0));

    if (widget.chosenDate != null) {
      DateTime dt = widget.chosenDate!;
      dateNotifier = ValueNotifier<String>(formatDate(dt));
      datePickerInitialDate = dt;
    } else {
      dateNotifier = ValueNotifier<String>(formatDate(DateTime.now()));
      datePickerInitialDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    systolicController.dispose();
    diastolicController.dispose();
    timeNotifier.dispose();
    dateNotifier.dispose();
    isButtonEnabled.dispose();
    diastolicFocus.dispose();
    super.dispose();
  }

  String formatDate(DateTime dateTime) {
    DateFormat dateFormatter = DateFormat('EEE, dd MMM');
    String formattedDate = dateFormatter.format(dateTime);
    String todayFormattedDate = dateFormatter.format(DateTime.now());
    if (formattedDate == todayFormattedDate) {
      return formattedDate.replaceRange(0, 3, 'Today');
    }
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DraggableScrollableSheet(
        expand: false,
        maxChildSize: widget.childSize,
        minChildSize: widget.childSize,
        initialChildSize: widget.childSize,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: stellarHpLightGreen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: CustomScrollView(
              controller: scrollController,
              physics: widget.viewInsetsBottom == 0 ? const NeverScrollableScrollPhysics() : null,
              slivers: [
                const LoggingAppbar(title: 'Log Blood Pressure'),
                SliverToBoxAdapter(
                  child: Container(
                    width: widget.maxWidth,
                    color: stellarHpLightGreen,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: widget.sizedBoxHeight),
                        LoggingDateTime(
                          height: widget.containerHeight1,
                          width: widget.maxWidth,
                          dateNotifier: dateNotifier,
                          timeNotifier: timeNotifier,
                          onPressCalendar: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: datePickerInitialDate,
                              initialEntryMode: DatePickerEntryMode.calendarOnly,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate == null) return;
                            datePickerInitialDate = pickedDate;
                            dateNotifier.value = formatDate(pickedDate);
                          },
                        ),
                        SizedBox(height: widget.sizedBoxHeight),
                        Container(
                          height: widget.containerHeight2,
                          width: widget.maxWidth,
                          color: Colors.white,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Blood Pressure',
                                  textAlign: TextAlign.start,
                                  style: context.style.titleMedium?.copyWith(
                                    color: stellarHpGreen,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 96,
                                    child: StellarHpTextField(
                                      label: 'Systolic',
                                      color: stellarHpBlue,
                                      textController: systolicController,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (value) {
                                        if (value.isNotEmpty) diastolicFocus.requestFocus();
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          isButtonEnabled.value = false;
                                          return;
                                        }

                                        if (diastolicController.text.isNotEmpty) {
                                          isButtonEnabled.value = true;
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      '/',
                                      textAlign: TextAlign.start,
                                      style: context.style.headlineLarge?.copyWith(
                                        fontWeight: FontWeight.w300,
                                        color: stellarHpGreen,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: StellarHpTextField(
                                      label: 'Diastolic',
                                      color: stellarHpBlue,
                                      textController: diastolicController,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.done,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          isButtonEnabled.value = false;
                                          return;
                                        }

                                        if (systolicController.text.isNotEmpty) {
                                          isButtonEnabled.value = true;
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      'mm Hg',
                                      textAlign: TextAlign.start,
                                      style: context.style.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: stellarHpBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: widget.sizedBoxHeight),
                        Container(
                          height: widget.buttonHeight,
                          margin: EdgeInsets.only(top: widget.buttonTopPadding),
                          child: ValueListenableBuilder(
                              valueListenable: isButtonEnabled,
                              builder: (context, isEnabled, _) {
                                return Opacity(
                                  opacity: isEnabled ? 1 : 0.55,
                                  child: LoggingBottomButton(
                                    text: isForUpdateLog ? 'Update Log' : 'Add Log',
                                    padding: EdgeInsets.zero,
                                    onTap: isEnabled
                                        ? () async {
                                            if (isForUpdateLog) {
                                              await updateLogs(context);
                                            } else {
                                              await saveLogs(context);
                                            }
                                          }
                                        : null,
                                  ),
                                );
                              }),
                        ),
                        SizedBox(height: widget.sizedBoxHeight),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> saveLogs(BuildContext context) async {
    DateTime logDate = DateTime(
      datePickerInitialDate.year,
      datePickerInitialDate.month,
      datePickerInitialDate.day,
      timeNotifier.value.hour,
      timeNotifier.value.minute,
    );

    BloodPressure log = BloodPressure(
      systolic: int.tryParse(systolicController.text) ?? 120,
      diastolic: int.tryParse(diastolicController.text) ?? 80,
      epochTimestamp: logDate.millisecondsSinceEpoch,
    );

    // show waiting dialog
    MediDialog.loading(context);

    bool success = await context.read<MainProvider>().saveDailyLog(log, logDate);
    if (!context.mounted) return;
    if (!success) {
      Navigator.pop(context);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        bool inProgress = context.read<MainProvider>().isHealthLogDecryptionInProgress;
        if (inProgress) {
          MediDialog.aiFailureDialog(context, message: "Decryption is in progress, please wait a minute");
        } else {
          MediDialog.aiFailureDialog(context, message: "please try again");
        }
      });
      return;
    }

    Navigator.pop(context);
    Navigator.pop(context, success);
  }

  Future<void> updateLogs(BuildContext context) async {
    DateTime newLogDate = DateTime(
      datePickerInitialDate.year,
      datePickerInitialDate.month,
      datePickerInitialDate.day,
      timeNotifier.value.hour,
      timeNotifier.value.minute,
    );

    BloodPressure newLog = BloodPressure(
      systolic: int.tryParse(systolicController.text) ?? 120,
      diastolic: int.tryParse(diastolicController.text) ?? 80,
      epochTimestamp: newLogDate.millisecondsSinceEpoch,
    );

    // return if value does not change
    if (newLog.systolic == widget.previousLog!.systolic &&
        newLog.diastolic == widget.previousLog!.diastolic &&
        newLog.epochTimestamp == widget.previousLog!.epochTimestamp) {
      return;
    }

    // show waiting dialog
    MediDialog.loading(context);

    bool success = await context.read<MainProvider>().updateHealthLog(
          newLog,
          newLogDate,
          widget.previousLog!,
          DateTime.fromMillisecondsSinceEpoch(widget.previousLog!.epochTimestamp),
        );
    if (!context.mounted) return;
    if (!success) {
      Navigator.pop(context);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        bool inProgress = context.read<MainProvider>().isHealthLogDecryptionInProgress;
        if (inProgress) {
          MediDialog.aiFailureDialog(context, message: "Decryption is in progress, please wait a minute");
        } else {
          MediDialog.aiFailureDialog(context, message: "please try again");
        }
      });
      return;
    }

    Navigator.pop(context);
    Navigator.pop(context, success);
  }
}
