import 'package:flutter/material.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/about_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/portfolio_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/schedule_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/avatar_upload_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/service_category_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/service_description_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/workplace_page.dart';

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
        physics: NeverScrollableScrollPhysics(),
        children: [
          AboutOnboardingPage(),
          AvatarUploadPage(),
          WorkplacePage(),
          ServiceCategoryPage(),
          ServiceDescriptionPage(),
          SchedulePage(),
          PortfolioPage(),
        ],
      ),
    );
  }
}
