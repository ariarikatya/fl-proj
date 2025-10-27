import 'package:flutter/material.dart';
import 'package:polka_clients/features/onboarding/pages/controller.dart';
import 'package:shared/shared.dart';

class OnboardingPage$Completed extends StatefulWidget {
  const OnboardingPage$Completed({super.key});

  @override
  State<OnboardingPage$Completed> createState() => _OnboardingPage$CompletedState();
}

class _OnboardingPage$CompletedState extends OnboardingPageState<OnboardingPage$Completed, OnboardingController, bool> {
  @override
  void complete(controller, data) => controller.completeOnboarding();

  @override
  List<Widget> content() => [
    AppText('Поздравлем, теперь ты в POLKA!', style: AppTextStyles.headingLarge),
    SizedBox(height: 8),
    AppText(
      'Здесь ты найдешь своего мастера за пять минут',
      style: AppTextStyles.bodyLarge.copyWith(color: context.ext.theme.textSecondary),
    ),
  ];

  @override
  List<Listenable> get dependencies => [];

  @override
  bool get centerContent => true;

  @override
  String? get continueLabel => 'Найти бьюти-услуги!';

  @override
  bool? validateContinue() => true;
}
