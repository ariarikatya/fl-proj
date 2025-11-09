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
  List<Widget> content() => [
    const AppText('Создадим твою услугу', style: AppTextStyles.headingLarge),
    const SizedBox(height: 24),
    const AppText('Выбери категорию', style: AppTextStyles.headingSmall),
    const SizedBox(height: 16),
    ServiceCategoryPicker(category: service),
  ];
}
