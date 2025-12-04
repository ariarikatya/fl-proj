import 'package:flutter/material.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:shared/shared.dart';

class ServiceCategoryPage extends StatefulWidget {
  const ServiceCategoryPage({super.key});

  @override
  State<ServiceCategoryPage> createState() => _ServiceCategoryPageState();
}

class _ServiceCategoryPageState extends OnboardingPageState<ServiceCategoryPage, OnboardingController, CategoryData> {
  late final service = useNotifier<ServiceCategories?>('service', null);

  @override
  List<Listenable> get dependencies => [service];

  @override
  void complete(OnboardingController controller, CategoryData data) => controller.completeServiceCategoryPage(data);

  @override
  CategoryData? validateContinue() => service.value;

  @override
  String? get continueLabel => 'Выбрать категорию';

  @override
  List<Widget> content() => [
    AppText('Создадим твою первую услугу', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    AppText(
      'Выбери категорию, чтобы по ней клиенты могли легко находить тебя',
      style: context.ext.textTheme.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
    ),
    const SizedBox(height: 24),
    ServiceCategoryPickerV2(category: service),
  ];
}
