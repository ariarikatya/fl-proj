import 'package:flutter/material.dart';
import 'package:polka_clients/features/onboarding/pages/completed_page.dart';
import 'package:polka_clients/features/onboarding/pages/interests_page.dart';
import 'package:polka_clients/features/onboarding/pages/about_page.dart';
import 'package:polka_clients/features/onboarding/pages/controller.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late final _pageCtrl = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingController(
      _pageCtrl,
      phoneNumber: widget.phoneNumber,
      child: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [const OnboardingPage$About(), const OnboardingPage$Interests(), const OnboardingPage$Completed()],
      ),
    );
  }
}
