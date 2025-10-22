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
    AppText('Создадим твою услугу', style: AppTextStyles.headingLarge),
    SizedBox(height: 24),
    AppText('Выбери категорию', style: AppTextStyles.headingSmall),
    SizedBox(height: 16),
    _ServicePicker(service: service),
  ];
}

class _ServicePicker extends StatelessWidget {
  const _ServicePicker({required this.service});

  final ValueNotifier<ServiceCategories?> service;

  static const _values = ServiceCategories.categories;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: service,
      builder: (context, value, child) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _values
              .map(
                (e) => AppChip(
                  enabled: value == e,
                  onTap: () => service.value = e,
                  onClose: () => service.value = null,
                  child: AppText(e.label),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
