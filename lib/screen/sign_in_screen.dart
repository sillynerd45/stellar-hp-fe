import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
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

  late TextEditingController skController;

  @override
  void initState() {
    super.initState();
    skController = TextEditingController();
  }

  @override
  void dispose() {
    isLoggingIn.dispose();
    skController.dispose();
    super.dispose();
  }

  Future<void> _invalidSecretKe(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid Secret Key'),
        duration: Duration(milliseconds: 1500),
        backgroundColor: stellarHpBlue,
      ),
    );
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
                  double maxWidth = constraints.maxWidth;
                  double adjustedLogoWidth = maxWidth >= appMaxScreenWidth - 300 ? appMaxScreenWidth - 300 : maxWidth;
                  return ValueListenableBuilder(
                      valueListenable: isLoggingIn,
                      builder: (BuildContext context, bool loggingIn, Widget? child) {
                        if (loggingIn) return const SizedBox(height: 0);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 80),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: SizedBox(
                                  width: adjustedLogoWidth,
                                  child: StellarHpTextField(
                                    label: 'your Secret Key',
                                    color: stellarHpBlue,
                                    textInputAction: TextInputAction.done,
                                    textController: skController,
                                    keyboardType: TextInputType.text,
                                    maxLines: 1,
                                    obscureText: true,
                                  ),
                                ),
                              ),
                              AppElevatedButton(
                                title: 'Connect',
                                onPressed: () async {
                                  if (isLoggingIn.value) return;
                                  isLoggingIn.value = true;

                                  bool isValid = StrKey.isValidStellarSecretSeed(skController.text);
                                  if (!isValid) {
                                    _invalidSecretKe(context);
                                    isLoggingIn.value = false;
                                    return;
                                  }

                                  getIt<UserIdService>().saveNewKeypair(KeyPair.fromSecretSeed(skController.text));

                                  bool userExist = await getIt<HpGetLogHash>()
                                      .invoke(publicKey: getIt<UserIdService>().getPublicKey());
                                  if (!context.mounted) return;

                                  if (userExist) {
                                    await loadAndSetUserData(context, getIt<UserIdService>().getPublicKey());
                                    if (!context.mounted) return;

                                    AccountType? accountType = getIt<MainProvider>().userProfile?.accountType;
                                    if (accountType == null) {
                                      isLoggingIn.value = false;
                                      return;
                                    }

                                    if (accountType == AccountType.user) {
                                      // go to home
                                      context.pushReplacement(NavRoute.home);
                                    } else {
                                      // go to clinic
                                      context.pushReplacement(NavRoute.clinic);
                                    }
                                  } else {
                                    context.push(NavRoute.createProfile);
                                  }

                                  isLoggingIn.value = false;
                                },
                              ),
                            ],
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
    // load user profile
    UserProfile? userProfile = await getIt<DatabaseService>().getUserProfileDataFromContract();
    getIt<MainProvider>().setUserProfile(userProfile);

    // load and setup user health logs data
    Map<String, YearlyHealthLogs>? userHealthLogs = await getIt<DatabaseService>().loadUserHealthLogs(publicKey);
    if (!context.mounted) return;
    if (userHealthLogs != null) {
      context.read<MainProvider>().setUserHealthLogs(userHealthLogs);
    }

    // start decryption process on the first five date
    await context.read<MainProvider>().checkEncryptedDataInFirstFiveDateOnHealthLogs();

    await getIt<ConsultationProvider>().loadConsultFromStorage();
  }
}
