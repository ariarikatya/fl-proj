import 'package:flutter/material.dart';
import 'package:polka_clients/features/onboarding/pages/controller.dart';
import 'package:shared/shared.dart';

class OnboardingPage$Interests extends StatefulWidget {
  const OnboardingPage$Interests({super.key});

  @override
  State<OnboardingPage$Interests> createState() => _OnboardingPage$InterestsState();
}

class _OnboardingPage$InterestsState
    extends OnboardingPageState<OnboardingPage$Interests, OnboardingController, CategoriesData> {
  late final interests = {
    for (var interest in ServiceCategories.categories) interest: useNotifier<bool>('$interest', false),
  };

  @override
  void complete(controller, data) => controller.completeInterestsPage(data);

  @override
  List<Listenable> get dependencies => interests.values.toList();

  @override
  CategoriesData? validateContinue() {
    if (interests.values.every((interest) => !interest.value)) return null;

    return interests.entries.map((e) => e.value.value ? e.key : null).nonNulls.toList();
  }

  @override
  List<Widget> content() => [
    const AppText('Выбери, \nчто тебе интересно', style: AppTextStyles.headingLarge),
    const SizedBox(height: 8),
    AppText(
      'Мы сможем сделать для тебя подборку максимально интересной',
      style: AppTextStyles.bodyLarge.copyWith(color: context.ext.theme.textSecondary),
    ),
    const SizedBox(height: 24),
    ListView.separated(
      shrinkWrap: true,
      itemCount: ServiceCategories.categories.length,
      itemBuilder: (context, index) => _card(interests.entries.elementAt(index)),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    ),
  ];

  Widget _card(MapEntry<ServiceCategories, ValueNotifier<bool>> entry) => ValueListenableBuilder(
    valueListenable: entry.value,
    builder: (context, value, child) {
      final interest = entry.key;
      final notifier = entry.value;
      return GestureDetector(
        onTap: () => notifier.value = !notifier.value,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
          decoration: BoxDecoration(
            color: value ? context.ext.theme.accentLight : context.ext.theme.backgroundHover,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              AppText(interest.label, style: AppTextStyles.bodyLarge),
              const Spacer(),
              if (value) Icon(Icons.check, color: context.ext.theme.iconsDefault, size: 16),
            ],
          ),
        ),
      );
    },
  );
}
