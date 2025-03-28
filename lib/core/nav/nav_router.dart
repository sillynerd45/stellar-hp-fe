import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stellar_hp_fe/core/core.dart';
import 'package:stellar_hp_fe/screen/screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    GoRoute(
      path: "/",
      pageBuilder: (BuildContext context, GoRouterState state) {
        return customTransitionPage(state, const SplashScreen());
      },
    ),
    GoRoute(
      path: NavRoute.signIn,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return customTransitionPage(state, const SignInScreen());
      },
    ),
    GoRoute(
      path: NavRoute.createProfile,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return customTransitionPage(state, const CreateProfileScreen());
      },
    ),
  ],
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
