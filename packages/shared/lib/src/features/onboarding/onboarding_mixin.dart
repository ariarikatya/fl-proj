import 'package:flutter/material.dart';

mixin OnboardingMixin<S extends StatefulWidget, T extends Object?> on State<S> {
  late final ValueNotifier<T?> continueNotifier;

  T? validateContinue();

  void _updateContinue() {
    continueNotifier.value = validateContinue();
  }

  void addContinueDependencies(List<Listenable> dependencies) {
    for (var dependency in dependencies) {
      dependency.addListener(_updateContinue);
    }
  }

  @override
  void initState() {
    continueNotifier = ValueNotifier(validateContinue());
    super.initState();
  }

  @override
  void dispose() {
    continueNotifier.dispose();
    super.dispose();
  }
}
