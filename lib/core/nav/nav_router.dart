import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/screen/home_screen.dart';
import 'package:stellar_hp_fe/screen/screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    GoRoute(
      path: NavRoute.splash,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return customTransitionPage(state, const SplashScreen());
      },
    ),
    GoRoute(
      path: NavRoute.home,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return customTransitionPage(state, const HomeScreen());
      },
    ),
    GoRoute(
      path: NavRoute.clinic,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return customTransitionPage(state, const ClinicScreen());
      },
    ),
    GoRoute(
      path: NavRoute.consultation,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return customTransitionPage(state, const ConsultationScreen());
      },
    ),
    GoRoute(
      path: NavRoute.signIn,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return customTransitionPage(state, const SignInScreen());
      },
    ),
    GoRoute(
      path: NavRoute.diagnose,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return customTransitionPage(state, const DiagnoseScreen());
      },
    ),
    GoRoute(
      path: NavRoute.report,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return customTransitionPage(state, const ReportScreen());
      },
    ),
    GoRoute(
      path: NavRoute.createProfile,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return customTransitionPage(state, const CreateProfileScreen());
      },
    ),
    GoRoute(
      path: NavRoute.bodyTemperatureLog,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final data = state.extra! as Map<String, dynamic>;
        return customTransitionPage(
            state,
            BodyTemperatureLogScreen(
                chosenDailyHealthLogs: data['chosenDailyHealthLogs'], chosenDate: data['chosenDate']));
      },
    ),
    GoRoute(
      path: NavRoute.bloodPressureLog,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final data = state.extra! as Map<String, dynamic>;
        return customTransitionPage(
            state,
            BloodPressureLogScreen(
                chosenDailyHealthLogs: data['chosenDailyHealthLogs'], chosenDate: data['chosenDate']));
      },
    ),
    GoRoute(
      path: NavRoute.medicineLog,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final data = state.extra! as Map<String, dynamic>;
        return customTransitionPage(state,
            MedicineLogScreen(chosenDailyHealthLogs: data['chosenDailyHealthLogs'], chosenDate: data['chosenDate']));
      },
    ),
    GoRoute(
      path: NavRoute.symptomLog,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final data = state.extra! as Map<String, dynamic>;
        return customTransitionPage(state,
            SymptomLogScreen(chosenDailyHealthLogs: data['chosenDailyHealthLogs'], chosenDate: data['chosenDate']));
      },
    ),
  ],
  errorPageBuilder: (BuildContext context, GoRouterState state) {
    return customTransitionPage(state, const SplashScreen());
  },
  redirect: (BuildContext context, GoRouterState state) async {
    // check for fresh start or after refresh page
    bool freshStart = getIt<MainProvider>().freshStart;
    if (freshStart) return '/';

    return null;
  },
);

CustomTransitionPage<void> customTransitionPage(GoRouterState state, Widget screen) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: screen,
    transitionDuration: const Duration(milliseconds: 50),
    reverseTransitionDuration: const Duration(milliseconds: 50),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}
