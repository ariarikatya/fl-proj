import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polka_masters/dependencies.dart';
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
  late final image = useNotifier<String?>('image', null);

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
      imageUrl: image.value!,
    );
    return data;
  }

  @override
  List<Widget> content() => [
    AppText('Создадим твою первую услугу', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    AppText(
      'Опиши, что ты предлагаешь: название, цену, длительность. Это поможет клиентам быстро понять формат и записаться без уточнений',
      style: context.ext.textTheme.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
    ),
    const SizedBox(height: 16),
    AppTextFormField(labelText: 'Название услуги', controller: useController('name')),
    const SizedBox(height: 24),
    AppText('Установи Цену, ₽', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 12),
    AppTextFormField(
      hintText: '1500',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: useController('price'),
      prefixIcon: AppText(
        '₽',
        style: context.ext.textTheme.bodyLarge?.copyWith(color: context.ext.colors.black[500]),
        textAlign: TextAlign.center,
      ),
      prefixIconConstraints: const BoxConstraints.tightFor(width: 32, height: 42),
    ),
    const SizedBox(height: 24),
    AppText('Выбери длительность', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    DurationPicker(duration: duration),
    const SizedBox(height: 36),
    AppText('Добавь фото', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    AppText(
      'Эта фотография станет заглавной для твоей услуги и по ней клиенты будут выбирать',
      style: context.ext.textTheme.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
    ),
    const SizedBox(height: 16),
    NewImagePickerWidget(
      onImageUpdate: (url) => image.value = url,
      upload: Dependencies().profileRepository.uploadSinglePhoto,
    ),
  ];
}
