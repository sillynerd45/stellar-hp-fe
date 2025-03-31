import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/widgets/widgets.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController weightController;

  late FocusNode ageFocus;
  late FocusNode weightFocus;

  ValueNotifier<String> ageUnit = ValueNotifier<String>('Years');
  ValueNotifier<String> weightUnit = ValueNotifier<String>('Kilograms');
  ValueNotifier<ProfileSex> profileSex = ValueNotifier<ProfileSex>(ProfileSex.male);
  ValueNotifier<AccountType> accountType = ValueNotifier<AccountType>(AccountType.user);

  String currentAgeUnit = 'Years';
  String currentWeightUnit = 'Kilograms';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    ageController = TextEditingController();
    weightController = TextEditingController();
    ageFocus = FocusNode();
    weightFocus = FocusNode();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    profileSex.dispose();
    accountType.dispose();
    ageUnit.dispose();
    weightUnit.dispose();
    ageFocus.dispose();
    weightFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 128, top: 8),
                  child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    double maxWidth = constraints.maxWidth;
                    double adjustedLogoWidth = maxWidth >= appMaxScreenWidth ? appMaxScreenWidth : maxWidth;
                    return SizedBox(
                      width: adjustedLogoWidth,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Create Your Profile',
                              textAlign: TextAlign.center,
                              style: context.style.headlineSmall?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'this help the app understand you better',
                              textAlign: TextAlign.center,
                              style: context.style.titleMedium?.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          StellarHpInputCard(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Name:',
                                  textAlign: TextAlign.start,
                                  style: context.style.titleMedium?.copyWith(
                                    color: stellarHpGreen,
                                  ),
                                ),
                              ),
                              StellarHpTextField(
                                label: 'your name',
                                color: stellarHpBlue,
                                textController: nameController,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) {
                                  if (value.isNotEmpty) ageFocus.requestFocus();
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
                                ],
                              ),
                            ],
                          ),
                          StellarHpInputCard(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Account Type:',
                                  textAlign: TextAlign.start,
                                  style: context.style.titleMedium?.copyWith(
                                    color: stellarHpGreen,
                                  ),
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: accountType,
                                builder: (BuildContext context, AccountType profileAccountType, Widget? child) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 166,
                                        child: RadioListTile<AccountType>(
                                          title: Text(
                                            'User',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: stellarHpBlue,
                                                ),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          activeColor: stellarHpBlue,
                                          fillColor: WidgetStateProperty.all<Color>(stellarHpBlue),
                                          value: AccountType.user,
                                          groupValue: profileAccountType,
                                          onChanged: (AccountType? value) {
                                            if (value != null) accountType.value = value;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 166,
                                        child: RadioListTile<AccountType>(
                                          title: Text(
                                            'Health Worker',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: stellarHpBlue,
                                                ),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          activeColor: stellarHpBlue,
                                          fillColor: WidgetStateProperty.all<Color>(stellarHpBlue),
                                          value: AccountType.healthWorker,
                                          groupValue: profileAccountType,
                                          onChanged: (AccountType? value) {
                                            if (value != null) accountType.value = value;
                                          },
                                        ),
                                      ),
                                      const Row(children: [SizedBox()]),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          StellarHpInputCard(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Sex:',
                                  textAlign: TextAlign.start,
                                  style: context.style.titleMedium?.copyWith(
                                    color: stellarHpGreen,
                                  ),
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: profileSex,
                                builder: (BuildContext context, ProfileSex profile, Widget? child) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 166,
                                        child: RadioListTile<ProfileSex>(
                                          title: Text(
                                            'Male',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: stellarHpBlue,
                                                ),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          activeColor: stellarHpBlue,
                                          fillColor: WidgetStateProperty.all<Color>(stellarHpBlue),
                                          value: ProfileSex.male,
                                          groupValue: profile,
                                          onChanged: (ProfileSex? value) {
                                            if (value != null) profileSex.value = value;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 166,
                                        child: RadioListTile<ProfileSex>(
                                          title: Text(
                                            'Female',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: stellarHpBlue,
                                                ),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          activeColor: stellarHpBlue,
                                          fillColor: WidgetStateProperty.all<Color>(stellarHpBlue),
                                          value: ProfileSex.female,
                                          groupValue: profile,
                                          onChanged: (ProfileSex? value) {
                                            if (value != null) profileSex.value = value;
                                          },
                                        ),
                                      ),
                                      const Row(children: [SizedBox()]),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          StellarHpInputCard(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Age:',
                                  textAlign: TextAlign.start,
                                  style: context.style.titleMedium?.copyWith(
                                    color: stellarHpGreen,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: StellarHpTextField(
                                      label: 'your current age',
                                      color: stellarHpBlue,
                                      focusNode: ageFocus,
                                      textInputAction: TextInputAction.next,
                                      textController: ageController,
                                      keyboardType: TextInputType.number,
                                      onFieldSubmitted: (value) {
                                        if (value.isNotEmpty) weightFocus.requestFocus();
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: ValueListenableBuilder(
                                      valueListenable: ageUnit,
                                      builder: (context, unit, _) {
                                        return StellarHpCreateProfileDropdownTwo(
                                          width: 122,
                                          elevation: 0,
                                          initialSelection: unit,
                                          dropdownMenuEntries: const ['Years', 'Months', 'Weeks'],
                                          onSelected: (value) {
                                            if (value != null) {
                                              currentAgeUnit = value;
                                              ageUnit.value = value;
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          StellarHpInputCard(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Weight:',
                                  textAlign: TextAlign.start,
                                  style: context.style.titleMedium?.copyWith(
                                    color: stellarHpGreen,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: StellarHpTextField(
                                      label: 'your current weight',
                                      color: stellarHpBlue,
                                      focusNode: weightFocus,
                                      textInputAction: TextInputAction.done,
                                      textController: weightController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                                        LengthLimitingTextInputFormatter(3),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: ValueListenableBuilder(
                                      valueListenable: weightUnit,
                                      builder: (context, unit, _) {
                                        return StellarHpCreateProfileDropdownTwo(
                                          width: 144,
                                          elevation: 0,
                                          initialSelection: unit,
                                          dropdownMenuEntries: const ['Kilograms', 'Pounds'],
                                          onSelected: (value) {
                                            if (value != null) {
                                              currentWeightUnit = value;
                                              weightUnit.value = value;
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                double maxWidth = constraints.maxWidth;
                double adjustedLogoWidth = maxWidth >= appMaxScreenWidth ? appMaxScreenWidth : maxWidth;
                return SizedBox(
                  width: adjustedLogoWidth,
                  child: CreateProfileBottomButton(
                    text: 'Create Profile',
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();

                      // check profile value
                      String userName = nameController.text;
                      int age = int.tryParse(ageController.text) ?? 0;
                      int weight = int.tryParse(weightController.text) ?? 0;

                      if (userName.isEmpty || age <= 0 || weight <= 0) {
                        MediDialog.aiFailureDialog(context, message: 'please check your name, age, and weight');
                        return;
                      }

                      // show waiting dialog
                      MediDialog.loading(context);

                      // try save data
                      DateTime now = DateTime.now();
                      UserProfile userProfile = UserProfile(
                        name: userName,
                        gender: profileSex.value == ProfileSex.male ? 'male' : 'female',
                        age: Age(value: age, unit: currentAgeUnit),
                        weight: Weight(value: weight, unit: currentWeightUnit),
                        encryptedData: null,
                        accountType: accountType.value,
                        logHash: getIt<HashService>().generate(publicKey: getIt<UserIdService>().getPublicKey()),
                      );

                      bool isRegisterSuccess =
                          await getIt<DatabaseService>().registerUserProfileDataToContract(now, userProfile);

                      if (!context.mounted) return;
                      if (!isRegisterSuccess) {
                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          MediDialog.aiFailureDialog(context, message: 'please try again');
                        });
                        return;
                      }
                      context.read<MainProvider>().setUserProfile(userProfile);

                      if (userProfile.accountType == AccountType.user) {
                        // go to home
                        GoRouter.of(context).popAllAndPushReplaced(NavRoute.home);
                      } else {
                        // go to clinic
                        GoRouter.of(context).popAllAndPushReplaced(NavRoute.clinic);
                      }
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
