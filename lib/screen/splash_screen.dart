import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stellar_hp_fe/core/core.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // based on stellarHp-logo-long.png size
  final Size logoSize = const Size(535, 188);

  // total of left and right horizontal padding, each is 64
  final double horizontalPadding = 128;

  bool splashLogicCalled = false;

  Future<void> precacheAppImage() async {
    precacheImage(Image.asset(key: aiWarningKey, imgAiWarning).image, context);
    precacheImage(Image.asset(key: stellarHpShortLogoKey, imgStellarHpLogoLong).image, context);
  }

  Future<void> createDateList() async {
    final DateTime now = DateTime.now();
    final DateFormat dayFormatter = DateFormat('EEE');
    final DateFormat dateFormatter = DateFormat('dd');
    final DateFormat monthFormatter = DateFormat('MMM');
    final DateFormat titleFormatter = DateFormat('EEE, dd MMM');
    final List<StellarHpDate> dateList = [];

    for (int i = 0; i < 60; i++) {
      final DateTime date = now.subtract(Duration(days: i));
      final String dayFormattedDate = dayFormatter.format(date);
      final String dateFormattedDate = dateFormatter.format(date);
      final String monthFormattedDate = monthFormatter.format(date);
      final String titleFormattedDate = titleFormatter.format(date);
      final int unixTimestampInSeconds = date.millisecondsSinceEpoch ~/ 1000;
      dateList.add(StellarHpDate(
        day: dayFormattedDate,
        date: dateFormattedDate,
        month: monthFormattedDate,
        title: titleFormattedDate,
        dateTime: date,
        unixTime: unixTimestampInSeconds,
      ));
    }

    dateList.sort((a, b) => b.unixTime!.compareTo(a.unixTime!));

    String timezone = '';
    try {
      timezone = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      timezone = DateTime.now().timeZoneName;
    }

    if (!mounted) return;
    context.read<MainProvider>().setDateList(dateList);
    context.read<MainProvider>().setTimeZone(timezone);
  }

  splashLogic() async {
    await precacheAppImage();
    await createDateList();
    if (!mounted) return;
    getIt<MainProvider>().setFreshStart();
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    context.pushReplacement(NavRoute.signIn);
  }

  @override
  void didChangeDependencies() {
    if (!splashLogicCalled) {
      splashLogicCalled = true;
      splashLogic();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: stellarHpLightGreen,
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: const Color.fromRGBO(255, 255, 255, 0.001),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double maxWidth = constraints.maxWidth;
            double maxWidthAfterPadding = maxWidth - horizontalPadding;
            double adjustedLogoWidth = maxWidthAfterPadding >= logoSize.width ? logoSize.width : maxWidthAfterPadding;
            return Center(
              child: Image.asset(
                key: stellarHpLongLogoKey,
                imgStellarHpLogoLong,
                width: adjustedLogoWidth,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                filterQuality: FilterQuality.high,
              ),
            );
          },
        ),
      ),
    );
  }
}
