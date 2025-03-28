import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // based on stellarHp-logo-long.png size
  final Size logoSize = const Size(535, 188);

  // total of left and right horizontal padding, each is 64
  final double horizontalPadding = 128;

  ValueNotifier<bool> isLoggingIn = ValueNotifier<bool>(false);

  @override
  void dispose() {
    isLoggingIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double maxWidth = constraints.maxWidth;
                  double maxWidthAfterPadding = maxWidth - horizontalPadding;
                  double adjustedLogoWidth =
                      maxWidthAfterPadding >= logoSize.width ? logoSize.width : maxWidthAfterPadding;
                  return Image.asset(
                    key: stellarHpLongLogoKey,
                    imgStellarHpLogoLong,
                    width: adjustedLogoWidth,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    filterQuality: FilterQuality.high,
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: isLoggingIn,
                builder: (BuildContext context, bool loggingIn, Widget? child) {
                  if (!loggingIn) return const SizedBox(height: 64);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 78),
                    child: Lottie.asset(
                      lottieAiCircle,
                      height: 100,
                      fit: BoxFit.fitHeight,
                      filterQuality: FilterQuality.high,
                      frameRate: FrameRate.max,
                    ),
                  );
                },
              ),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ValueListenableBuilder(
                      valueListenable: isLoggingIn,
                      builder: (BuildContext context, bool loggingIn, Widget? child) {
                        if (loggingIn) return const SizedBox(height: 0);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 80),
                          child: AppElevatedButton(
                            title: 'Connect',
                            onPressed: () async {
                              if (isLoggingIn.value) return;
                              isLoggingIn.value = true;

                              // TODO: check user profile in soroban
                              // TODO: invoke SMART CONTRACT get_log_hash here
                              // TODO: if no log hash found then redirect user to : context.push(NavRoute.createProfileFirst);

                              bool userExist =
                                  await getIt<HpGetLogHash>().invoke(publicKey: getIt<UserIdService>().getPublicKey());
                              if (!context.mounted) return;
                              debugPrint('userExist : $userExist');

                              if (userExist) {
                                // await loadAndSetUserData(context, getIt<UserIdService>().getPublicKey());
                                // if (!context.mounted) return;
                                // context.pushReplacement(NavRoute.dashboard);
                              } else {
                                context.push(NavRoute.createProfile);
                              }

                              // TODO: if the profile exist, load user data
                              // TODO: then redirect to : context.pushReplacement(NavRoute.dashboard);

                              isLoggingIn.value = false;
                            },
                          ),
                        );
                      });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadAndSetUserData(BuildContext context, String publicKey) async {
    // load and setup user health logs data
    Map<String, YearlyHealthLogs>? userHealthLogs = await getIt<DatabaseService>().loadUserHealthLogs(publicKey);
    if (!context.mounted) return;
    if (userHealthLogs != null) {
      context.read<MainProvider>().setUserHealthLogs(userHealthLogs);
    }

    // start decryption process on the first five date
    await context.read<MainProvider>().checkEncryptedDataInFirstFiveDateOnHealthLogs();
  }
}
