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
  late final _controllers = [useController('name'), useController('description'), useController('price')];
  late final duration = useNotifier<Duration>('duration', Duration(minutes: 60));
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
      description: useController('description').text.trim(),
      price: int.parse(useController('price').text.trim()),
      duration: duration.value,
      image: image.value!,
    );
    return data;
  }

  @override
  List<Widget> content() => [
    AppText('Создадим твою услугу', style: AppTextStyles.headingLarge),
    SizedBox(height: 16),
    AppTextFormField(labelText: 'Название услуги', controller: useController('name')),
    SizedBox(height: 16),
    AppTextFormField(hintText: 'Расскажи о своей услуге', controller: useController('description'), maxLines: 3),
    SizedBox(height: 24),
    AppText('Установи Цену, ₽', style: AppTextStyles.headingSmall),
    SizedBox(height: 8),
    AppTextFormField(
      hintText: '1500',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: useController('price'),
      prefixIcon: AppText('₽', style: AppTextStyles.bodyLarge),
    ),
    SizedBox(height: 24),
    AppText('Выбери длительность', style: AppTextStyles.headingSmall),
    SizedBox(height: 8),
    DurationPicker(duration: duration),
    SizedBox(height: 24),
    AppText('Добавь фотографию результата этой услуги', style: AppTextStyles.headingSmall),
    SizedBox(height: 16),
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
        Spacer(),
        Spacer(),
      ],
    ),
  ];
}
