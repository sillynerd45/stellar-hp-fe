import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension BuildContextX on BuildContext {
  /// [style] shorten syntax for textTheme
  TextTheme get style => Theme.of(this).textTheme;
}

extension GoRouterX on GoRouter {
  // Navigate back to a specific route
  void popUntil(String ancestorPath) {
    while (routerDelegate.currentConfiguration.matches.last.matchedLocation != ancestorPath) {
      if (!canPop()) {
        return;
      }
      pop();
    }
  }

  // Navigate back until the last route and push replaced
  void popAllAndPushReplaced(String location) {
    while (canPop()) {
      pop();
    }
    pushReplacement(location);
  }
}