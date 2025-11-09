import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:shared/shared.dart';

class ServiceDescriptionPage extends StatefulWidget {
  const ServiceDescriptionPage({super.key});

  @override
  State<ServiceDescriptionPage> createState() => _ServiceDescriptionPageState();
}

class _ServiceDescriptionPageState
    extends OnboardingPageState<ServiceDescriptionPage, OnboardingController, ServiceData?> {
  late final _controllers = [useController('name'), useController('price')];
  late final duration = useNotifier<Duration>('duration', const Duration(minutes: 60));
  late final image = useNotifier<XFile?>('image', null);

  @override
  List<Listenable> get dependencies => [..._controllers, duration, image];

  @override
  String? get continueLabel => 'Создать услугу';

  @override
  void complete(OnboardingController controller, ServiceData? data) => controller.completeServicePage(data);

  @override
  ServiceData? validateContinue() {
    if (_controllers.any((c) => c.text.trim().isEmpty) ||
        image.value == null ||
        int.tryParse(useController('price').text.trim()) == null) {
      return null;
    }

    final data = (
      serviceName: useController('name').text.trim(),
      price: int.parse(useController('price').text.trim()),
      duration: duration.value,
      image: image.value!,
    );
    return data;
  }

  @override
  List<Widget> content() => [
    const AppText('Создадим твою услугу', style: AppTextStyles.headingLarge),
    const SizedBox(height: 16),
    AppTextFormField(labelText: 'Название услуги', controller: useController('name')),
    const SizedBox(height: 16),
    const AppText('Установи Цену, ₽', style: AppTextStyles.headingSmall),
    const SizedBox(height: 8),
    AppTextFormField(
      hintText: '1500',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: useController('price'),
      prefixIcon: const AppText('₽', style: AppTextStyles.bodyLarge),
      prefixIconConstraints: const BoxConstraints.tightFor(width: 32),
    ),
    const SizedBox(height: 24),
    const AppText('Выбери длительность', style: AppTextStyles.headingSmall),
    const SizedBox(height: 8),
    DurationPicker(duration: duration),
    const SizedBox(height: 24),
    const AppText('Добавь фотографию результата этой услуги', style: AppTextStyles.headingSmall),
    const SizedBox(height: 16),
    Row(
      spacing: 8,
      children: [
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: image,
            builder: (context, value, child) {
              return ImagePickerWidget(
                onImageAdded: (image0) => image.value = image0,
                onDelete: () => image.value = null,
                image: value,
              );
            },
          ),
        ),
        // Photo takes 1/3 of available space
        const Spacer(),
        const Spacer(),
      ],
    ),
  ];
}
