import 'package:flutter/material.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/about_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/portfolio_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/schedule_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/avatar_upload_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/service_category_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/service_description_page.dart';
import 'package:polka_masters/features/onboarding/pages/subpages/workplace_page.dart';
import 'package:shared/shared.dart';

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
      child: AppPage(
        child: Column(
          children: [
            Builder(
              builder: (ctx) {
                final controller = $OnboardingController.of<OnboardingController>(ctx);
                return ListenableBuilder(
                  listenable: controller.pageController,
                  builder: (context, child) => SizedBox(
                    height: 24,
                    child: Stack(
                      children: controller.pageController.hasClients
                          ? [
                              Align(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(72, 0, 72, 0),
                                  child: LinearProgressIndicator(
                                    value: controller.progress,
                                    backgroundColor: ctx.ext.colors.white[200],
                                    color: ctx.ext.colors.pink[300],
                                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              if ((controller.pageController.page ?? 0) >= 1)
                                GestureDetector(
                                  onTap: $OnboardingController.of<OnboardingController>(ctx).back,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: FIcons.arrow_left.icon(ctx),
                                  ),
                                ),
                            ]
                          : [],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  AboutOnboardingPage(),
                  AvatarUploadPage(),
                  WorkplacePage(),
                  ServiceCategoryPage(),
                  ServiceDescriptionPage(),
                  SchedulePage(),
                  PortfolioPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
