import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class SymptomLogSheet extends StatefulWidget {
  const SymptomLogSheet({
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
  final Symptom? previousLog;
  final DateTime? chosenDate;
  final bool? fromDashboard;

  static const double _sizedBoxHeight = 16;

  static Future<bool?> show(
    BuildContext context, {
    Symptom? currentLog,
    DateTime? chosenDate,
    bool? fromDashboard,
  }) async {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    double paddingTop = MediaQuery.of(context).viewPadding.top;
    if (paddingTop == 0) paddingTop = 40;
    double heightWithoutSafeArea = displayHeight - paddingTop;

    double containerHeight1 = 110;
    double containerHeight2 = 156;
    double buttonTopPadding = 32;
    double buttonHeight = 42;

    double recommendedChildSize = heightWithoutSafeArea / displayHeight;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black45,
      backgroundColor: stellarHpLightGreen,
      builder: (BuildContext innerContext) {
        double viewInsetsBottom = MediaQuery.of(innerContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: viewInsetsBottom),
          child: SymptomLogSheet(
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
  State<SymptomLogSheet> createState() => _SymptomLogSheetState();
}

class _SymptomLogSheetState extends State<SymptomLogSheet> {
  // for Date and Time
  late ValueNotifier<Time> timeNotifier;
  late ValueNotifier<String> dateNotifier;
  late DateTime datePickerInitialDate;

  // for Symptom Notes
  late TextEditingController notesController;

  List<ValueNotifier<bool>> symptomNotifier = [];
  List<String> commonSymptoms = [
    'Headache',
    'Dizziness',
    'Fatigue',
    'Sore throat',
    'Cough',
    'Fever',
    'Nasal congestion',
    'Muscle aches',
    'Back pain',
    'Nausea',
    'Diarrhea',
    'Constipation',
    'Abdominal pain',
    'Shortness of breath',
    'Chest pain',
    'Joint pain',
    'Skin rash',
    'Itchy skin',
    'Loss of appetite',
    'Frequent urination',
    'Runny nose',
    'Sneezing',
    'Bloating',
  ];

  // for Add Log button
  bool isForUpdateLog = false;
  late ValueNotifier<bool> isButtonEnabled;

  @override
  void initState() {
    super.initState();

    if (widget.previousLog != null) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(widget.previousLog!.epochTimestamp);
      notesController = TextEditingController(text: widget.previousLog!.note);
      isButtonEnabled = ValueNotifier<bool>(true);
      dateNotifier = ValueNotifier<String>(formatDate(dt));
      datePickerInitialDate = dt;
      timeNotifier = ValueNotifier<Time>(Time.fromTimeOfDay(TimeOfDay.fromDateTime(dt), 0));
      if (widget.fromDashboard == null) isForUpdateLog = true;
      for (var s in commonSymptoms) {
        if (notesController.text.contains(s)) {
          symptomNotifier.add(ValueNotifier<bool>(true));
        } else {
          symptomNotifier.add(ValueNotifier<bool>(false));
        }
      }
      return;
    }

    notesController = TextEditingController();
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

    for (var _ in commonSymptoms) {
      symptomNotifier.add(ValueNotifier<bool>(false));
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    timeNotifier.dispose();
    dateNotifier.dispose();
    isButtonEnabled.dispose();
    for (var n in symptomNotifier) {
      n.dispose();
    }

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
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                CustomScrollView(
                  primary: true,
                  slivers: [
                    const LoggingAppbar(title: 'Log Symptom'),
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
                                      'Symptom Notes',
                                      textAlign: TextAlign.start,
                                      style: context.style.titleMedium?.copyWith(
                                        color: stellarHpGreen,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: StellarHpTextField(
                                          label: 'i.e. Nausea, Sneezing, Fever, etc.',
                                          color: stellarHpBlue,
                                          textController: notesController,
                                          maxLines: 3,
                                          alignLabelWithHint: true,
                                          keyboardType: TextInputType.text,
                                          onChanged: (value) {
                                            if (value.isEmpty) {
                                              isButtonEnabled.value = false;
                                              return;
                                            }
                                            isButtonEnabled.value = true;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: widget.sizedBoxHeight),
                            Container(
                              width: widget.maxWidth,
                              color: Colors.white,
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Common Symptoms',
                                    textAlign: TextAlign.start,
                                    style: context.style.titleMedium?.copyWith(
                                      color: stellarHpGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 70),
                          itemCount: commonSymptoms.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _SymptomItem(
                                maxWidth: widget.maxWidth,
                                symptomName: commonSymptoms[index],
                                selectNotifier: symptomNotifier[index],
                                onPress: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  String currentText = notesController.text.trim();

                                  // remove symptom
                                  if (symptomNotifier[index].value) {
                                    if (currentText.isNotEmpty) {
                                      // remove dot or comma from last index
                                      String lastChar =
                                          currentText.substring(currentText.length - 1);
                                      if (lastChar == ',' || lastChar == '.') {
                                        currentText =
                                            currentText.substring(0, currentText.length - 1);
                                      }

                                      int comma = ','.allMatches(currentText).length;

                                      if (comma == 0) {
                                        notesController.clear();
                                        isButtonEnabled.value = false;
                                      } else {
                                        int symptomLength = commonSymptoms[index].length;
                                        String firstSymptom =
                                            currentText.substring(0, symptomLength);

                                        if (firstSymptom == commonSymptoms[index]) {
                                          currentText = currentText.replaceAll(
                                              '${commonSymptoms[index]}, ', '');
                                        } else {
                                          currentText = currentText.replaceAll(
                                              ', ${commonSymptoms[index]}', '');
                                        }
                                        notesController.text = currentText;
                                      }
                                    }
                                    symptomNotifier[index].value = false;
                                    return;
                                  }

                                  // add symptom
                                  if (currentText.isEmpty) {
                                    notesController.text = commonSymptoms[index];
                                  } else {
                                    // remove dot or comma from last index
                                    String lastChar = currentText.substring(currentText.length - 1);
                                    if (lastChar == ',' || lastChar == '.') {
                                      currentText =
                                          currentText.substring(0, currentText.length - 1);
                                    }

                                    notesController.text = '$currentText, ${commonSymptoms[index]}';
                                  }

                                  symptomNotifier[index].value = true;
                                  isButtonEnabled.value = true;
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedOpacity(
                  opacity: widget.viewInsetsBottom != 0 ? 0 : 1,
                  duration: const Duration(milliseconds: 100),
                  child: IgnorePointer(
                    ignoring: widget.viewInsetsBottom != 0 ? true : false,
                    child: Container(
                      height: widget.buttonHeight,
                      margin: EdgeInsets.only(bottom: widget.sizedBoxHeight),
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

    Symptom log = Symptom(
      note: notesController.text,
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
          MediDialog.aiFailureDialog(context,
              message: "Decryption is in progress, please wait a minute");
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

    Symptom newLog = Symptom(
      note: notesController.text,
      epochTimestamp: newLogDate.millisecondsSinceEpoch,
    );

    // return if value does not change
    if (newLog.note == widget.previousLog!.note &&
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
          MediDialog.aiFailureDialog(context,
              message: "Decryption is in progress, please wait a minute");
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

class _SymptomItem extends StatelessWidget {
  const _SymptomItem({
    required this.symptomName,
    required this.maxWidth,
    required this.selectNotifier,
    required this.onPress,
  });

  final String symptomName;
  final double maxWidth;
  final ValueNotifier<bool> selectNotifier;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: maxWidth,
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(
            width: 0.75,
            color: Colors.white,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(187, 187, 187, 0.7),
              offset: Offset(1, 2),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  symptomName,
                  textAlign: TextAlign.start,
                  style: context.style.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: stellarHpGreen,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: selectNotifier,
              builder: (context, selected, _) {
                return Container(
                  height: 24,
                  width: 24,
                  margin: const EdgeInsets.only(left: 16, right: 8),
                  decoration: BoxDecoration(
                    color: selected ? stellarHpBlue : transparentColor,
                    border: Border.all(
                      color: stellarHpBlue,
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
