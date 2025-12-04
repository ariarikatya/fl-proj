import 'dart:math';

import 'package:flutter/material.dart';

abstract class $OnboardingController extends InheritedWidget {
  const $OnboardingController(this.pageController, {super.key, required this.stepsCount, required super.child});

  final PageController pageController;
  final int stepsCount;

  double get progress => ((pageController.page ?? 0.0) + 0.0) / (max(stepsCount - 1, 1));

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static T of<T extends $OnboardingController>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<T>()!;
  }

  void _animateToPage(int page) {
    pageController.animateToPage(page, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void back() {
    final currentPage = pageController.page ?? -1;
    if (currentPage >= 1) _animateToPage(currentPage.toInt() - 1);
  }

  void next() {
    final currentPage = pageController.page ?? 0;
    _animateToPage(currentPage.toInt() + 1);
  }
}
