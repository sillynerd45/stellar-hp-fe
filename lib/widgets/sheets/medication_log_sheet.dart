import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class MedicationLogSheet extends StatefulWidget {
  const MedicationLogSheet({
    super.key,
    required this.childSize,
    required this.maxWidth,
    required this.sizedBoxHeight,
    required this.containerHeight1,
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
  final double buttonTopPadding;
  final double buttonHeight;
  final double viewInsetsBottom;
  final Medicine? previousLog;
  final DateTime? chosenDate;
  final bool? fromDashboard;

  static const double _sizedBoxHeight = 16;

  static Future<bool?> show(
    BuildContext context, {
    Medicine? currentLog,
    DateTime? chosenDate,
    bool? fromDashboard,
  }) async {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    double paddingTop = MediaQuery.of(context).viewPadding.top;
    if (paddingTop == 0) paddingTop = 40;
    double heightWithoutSafeArea = displayHeight - paddingTop;

    double containerHeight1 = 110;
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
          child: MedicationLogSheet(
            childSize: recommendedChildSize,
            maxWidth: displayWidth,
            sizedBoxHeight: _sizedBoxHeight,
            containerHeight1: containerHeight1,
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
  State<MedicationLogSheet> createState() => _MedicationLogSheetState();
}

class _MedicationLogSheetState extends State<MedicationLogSheet> {
  // for Date and Time
  late ValueNotifier<Time> timeNotifier;
  late ValueNotifier<String> dateNotifier;
  late DateTime datePickerInitialDate;

  // for Medicine Name and Quantity
  late TextEditingController medicineNameController;
  late ValueNotifier<String> medicineQuantity;
  late ValueNotifier<int> dummyNotifier;

  // for Medicine List
  List<ValueNotifier<String>> medsNotifier = [];
  List<TextEditingController> medsControllers = [];

  // for Add Log button
  bool isForUpdateLog = false;
  late ValueNotifier<bool> isButtonEnabled;
  late ValueNotifier<bool> isAddMedicineButtonEnabled;

  @override
  void initState() {
    super.initState();

    if (widget.previousLog != null) {
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(widget.previousLog!.epochTimestamp);
      timeNotifier = ValueNotifier<Time>(Time.fromTimeOfDay(TimeOfDay.fromDateTime(dt), 0));
      dateNotifier = ValueNotifier<String>(formatDate(dt));
      datePickerInitialDate = dt;
      medicineNameController = TextEditingController();
      if (widget.fromDashboard == null) isForUpdateLog = true;
      medicineQuantity = ValueNotifier<String>('1');
      dummyNotifier = ValueNotifier<int>(0);
      isButtonEnabled = ValueNotifier<bool>(true);
      isAddMedicineButtonEnabled = ValueNotifier<bool>(false);

      for (MedicineProperties m in widget.previousLog!.meds) {
        medsControllers.add(TextEditingController(text: m.name));
        medsNotifier.add(ValueNotifier<String>(m.quantity.toString().replaceAll('.0', '')));
      }
      return;
    }

    if (widget.chosenDate != null) {
      DateTime dt = widget.chosenDate!;
      dateNotifier = ValueNotifier<String>(formatDate(dt));
      datePickerInitialDate = dt;
    } else {
      dateNotifier = ValueNotifier<String>(formatDate(DateTime.now()));
      datePickerInitialDate = DateTime.now();
    }

    medicineNameController = TextEditingController();
    medicineQuantity = ValueNotifier<String>('1');
    dummyNotifier = ValueNotifier<int>(0);
    isButtonEnabled = ValueNotifier<bool>(false);
    isAddMedicineButtonEnabled = ValueNotifier<bool>(false);
    timeNotifier = ValueNotifier<Time>(Time.fromTimeOfDay(TimeOfDay.now(), 0));
  }

  @override
  void dispose() {
    medicineNameController.dispose();
    medicineQuantity.dispose();
    timeNotifier.dispose();
    dateNotifier.dispose();
    dummyNotifier.dispose();
    isButtonEnabled.dispose();
    isAddMedicineButtonEnabled.dispose();
    for (var n in medsNotifier) {
      n.dispose();
    }
    for (var c in medsControllers) {
      c.dispose();
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

  void addMedicine(String name, String quantity) {
    medsControllers.add(TextEditingController(text: name));
    medsNotifier.add(ValueNotifier<String>(quantity));
    dummyNotifier.value++;
    isButtonEnabled.value = true;
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
                    const LoggingAppbar(title: 'Log Medicine'),
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
                              width: widget.maxWidth,
                              color: Colors.white,
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      'Name and Quantity',
                                      textAlign: TextAlign.start,
                                      style: context.style.titleMedium?.copyWith(
                                        color: stellarHpGreen,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: StellarHpTextField(
                                          label: 'i.e. Paracetamol, Aspirin, etc.',
                                          color: stellarHpBlue,
                                          textController: medicineNameController,
                                          keyboardType: TextInputType.text,
                                          onChanged: (value) {
                                            if (value.isEmpty) {
                                              isAddMedicineButtonEnabled.value = false;
                                              return;
                                            }
                                            isAddMedicineButtonEnabled.value = true;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16),
                                        child: ValueListenableBuilder(
                                          valueListenable: medicineQuantity,
                                          builder: (context, unit, _) {
                                            return StellarHpCreateProfileDropdownTwo(
                                              width: 72,
                                              elevation: 0,
                                              maxDropDownMenu: 4,
                                              alignment: AlignmentDirectional.center,
                                              buttonStylePadding: const EdgeInsets.only(left: 2),
                                              initialSelection: unit,
                                              dropdownMenuEntries: const [
                                                '0.25',
                                                '0.5',
                                                '1',
                                                '2',
                                                '3',
                                                '4',
                                                '5',
                                                '6',
                                                '7',
                                                '8',
                                                '9',
                                                '10',
                                              ],
                                              onSelected: (value) {
                                                if (value != null) {
                                                  medicineQuantity.value = value;
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 32,
                                    margin: const EdgeInsets.only(top: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ValueListenableBuilder(
                                            valueListenable: isAddMedicineButtonEnabled,
                                            builder: (context, isEnabled, _) {
                                              return Opacity(
                                                opacity: isEnabled ? 1 : 0.55,
                                                child: LoggingBottomButton(
                                                  text: 'Add Medicine',
                                                  useHorizontalPadding: false,
                                                  padding: EdgeInsets.zero,
                                                  color: orangeWarningColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  onTap: () {
                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                    if (medicineNameController.text.isEmpty) {
                                                      return;
                                                    }
                                                    addMedicine(
                                                      medicineNameController.text.trim(),
                                                      medicineQuantity.value,
                                                    );
                                                    medicineNameController.clear();
                                                    medicineQuantity.value = '1';
                                                    isAddMedicineButtonEnabled.value = false;
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
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
                                    'Medicine List',
                                    textAlign: TextAlign.start,
                                    style: context.style.titleMedium?.copyWith(
                                      color: stellarHpGreen,
                                    ),
                                  ),
                                  ValueListenableBuilder(
                                    valueListenable: dummyNotifier,
                                    builder: (context, n, _) {
                                      if (medsControllers.isNotEmpty && medsNotifier.isNotEmpty) {
                                        return const SizedBox();
                                      }
                                      return Container(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        alignment: Alignment.topCenter,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              emptyListMedication,
                                              width: 250,
                                              fit: BoxFit.fitWidth,
                                              isAntiAlias: true,
                                              gaplessPlayback: true,
                                              filterQuality: FilterQuality.high,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.zero,
                                              child: Text(
                                                'Keep track of your meds.',
                                                textAlign: TextAlign.start,
                                                style: context.style.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w400,
                                                  color: stellarHpGreen,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Add one now.',
                                              textAlign: TextAlign.start,
                                              style: context.style.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w400,
                                                color: stellarHpGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: dummyNotifier,
                      builder: (context, n, _) {
                        if (medsControllers.isEmpty && medsNotifier.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: SizedBox(),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: _MedicineItem(
                                  maxWidth: widget.maxWidth,
                                  textController: medsControllers[index],
                                  amountNotifier: medsNotifier[index],
                                  onPressClose: () {
                                    medsControllers[index].dispose();
                                    medsNotifier[index].dispose();
                                    medsControllers.removeAt(index);
                                    medsNotifier.removeAt(index);
                                    dummyNotifier.value++;
                                    if (medsControllers.isEmpty) isButtonEnabled.value = false;
                                  },
                                ),
                              );
                            },
                            childCount: medsControllers.length,
                          ),
                        );
                      },
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: widget.sizedBoxHeight * 4),
                    ),
                  ],
                ),
                AnimatedOpacity(
                  opacity: widget.viewInsetsBottom != 0 ? 0 : 1,
                  duration: const Duration(milliseconds: 50),
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

    List<MedicineProperties> meds = [];
    for (int i = 0; i < medsControllers.length; i++) {
      meds.add(MedicineProperties(
        name: medsControllers[i].text,
        quantity: double.tryParse(medsNotifier[i].value) ?? 1,
      ));
    }
    // sort name A to Z
    meds.sort((a, b) => a.name.compareTo(b.name));

    Medicine log = Medicine(meds: meds, epochTimestamp: logDate.millisecondsSinceEpoch);

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

    List<MedicineProperties> meds = [];
    for (int i = 0; i < medsControllers.length; i++) {
      meds.add(MedicineProperties(
        name: medsControllers[i].text,
        quantity: double.tryParse(medsNotifier[i].value) ?? 1,
      ));
    }
    // sort name A to Z
    meds.sort((a, b) => a.name.compareTo(b.name));

    Medicine newLog = Medicine(meds: meds, epochTimestamp: newLogDate.millisecondsSinceEpoch);

    // return if value does not change
    if (widget.previousLog!.meds.length == meds.length) {
      List<bool> isTheSameMeds = [];
      for (int i = 0; i < meds.length; i++) {
        isTheSameMeds.add(widget.previousLog!.meds[i].name == meds[i].name &&
            widget.previousLog!.meds[i].quantity == meds[i].quantity);
      }

      // if all value is TRUE, then there is no changes in medicine
      // expect one value in isTheSameMeds list is FALSE
      bool shouldWeContinue = isTheSameMeds.contains(false);
      if (!shouldWeContinue) return;
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

class _MedicineItem extends StatelessWidget {
  const _MedicineItem({
    required this.maxWidth,
    required this.textController,
    required this.amountNotifier,
    required this.onPressClose,
  });

  final double maxWidth;
  final TextEditingController textController;
  final ValueNotifier<String> amountNotifier;
  final VoidCallback onPressClose;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: StellarHpTextField(
              label: 'i.e. Paracetamol, Aspirin, etc.',
              color: stellarHpBlue,
              textController: textController,
              keyboardType: TextInputType.text,
              borderRadius: 12,
              scrollPadding: const EdgeInsets.only(bottom: 350),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ValueListenableBuilder(
              valueListenable: amountNotifier,
              builder: (context, amount, _) {
                return StellarHpCreateProfileDropdownTwo(
                  width: 64,
                  iconSize: 0,
                  elevation: 0,
                  maxDropDownMenu: 4,
                  borderRadius: 12,
                  alignment: AlignmentDirectional.center,
                  buttonStylePadding: const EdgeInsets.only(left: 2),
                  initialSelection: amount,
                  dropdownMenuEntries: const [
                    '0.25',
                    '0.5',
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9',
                    '10',
                  ],
                  onSelected: (value) {
                    if (value != null) {
                      amountNotifier.value = value;
                    }
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 32,
            width: 32,
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              padding: EdgeInsets.zero,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(stopRecordRed),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                overlayColor: WidgetStateProperty.all<Color>(stopRecordRed),
                side: WidgetStateProperty.all(const BorderSide(color: transparentColor)),
                iconSize: WidgetStateProperty.all<double?>(28),
              ),
              onPressed: onPressClose,
            ),
          ),
        ],
      ),
    );
  }
}
