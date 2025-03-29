import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:flutter/material.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class LoggingDateTime extends StatelessWidget {
  const LoggingDateTime({
    super.key,
    required this.height,
    required this.width,
    required this.dateNotifier,
    required this.timeNotifier,
    required this.onPressCalendar,
  });

  final double height;
  final double width;
  final ValueNotifier<String> dateNotifier;
  final ValueNotifier<Time> timeNotifier;
  final VoidCallback onPressCalendar;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Date and Time',
              textAlign: TextAlign.start,
              style: context.style.titleMedium?.copyWith(
                color: stellarHpGreen,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder(
                  valueListenable: dateNotifier,
                  builder: (BuildContext context, String date, Widget? child) {
                    return StellarHpDateTimeOptionButton(
                      icon: Icons.calendar_today,
                      title: date,
                      onPressed: onPressCalendar,
                    );
                  }),
              const SizedBox(width: 16),
              ValueListenableBuilder(
                  valueListenable: timeNotifier,
                  builder: (BuildContext context, Time time, Widget? child) {
                    String hour = time.hour.toString();
                    if (hour.length == 1) hour = '0${time.hour}';
                    String minute = time.minute.toString();
                    if (minute.length == 1) minute = '0${time.minute}';

                    return Builder(builder: (BuildContext context) {
                      double maxWidth = MediaQuery.sizeOf(context).width;
                      double availableWidthAfterLimit = maxWidth - appMaxScreenWidth;
                      bool isZeroWidth = availableWidthAfterLimit <= 80;
                      double horizontalPadding = isZeroWidth ? 40 : availableWidthAfterLimit / 2;
                      return StellarHpDateTimeOptionButton(
                        icon: Icons.access_time,
                        title: '$hour:$minute',
                        onPressed: () {
                          Navigator.of(context).push(
                            showPicker(
                              context: context,
                              value: time,
                              onChange: (_) {},
                              is24HrFormat: true,
                              borderRadius: 16,
                              dialogInsetPadding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24.0),
                              okText: 'OK',
                              okStyle: context.style.titleMedium!.copyWith(
                                color: startRecordBlue,
                              ),
                              cancelText: 'CANCEL',
                              cancelStyle: context.style.titleMedium!.copyWith(
                                color: stopRecordRed,
                              ),
                              onChangeDateTime: (DateTime dateTime) {
                                timeNotifier.value = Time(hour: dateTime.hour, minute: dateTime.minute);
                              },
                            ),
                          );
                        },
                      );
                    });
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
