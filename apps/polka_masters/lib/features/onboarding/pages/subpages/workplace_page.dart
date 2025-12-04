import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:shared/shared.dart';

class WorkplacePage extends StatefulWidget {
  const WorkplacePage({super.key});

  @override
  State<WorkplacePage> createState() => _WorkplacePageState();
}

class _WorkplacePageState extends OnboardingPageState<WorkplacePage, OnboardingController, WorkplaceData> {
  late final workplace = List<ValueNotifier<String?>>.generate(5, (i) => useNotifier<String?>('$i', null));
  late final place = useNotifier<ServiceLocation?>('place', ServiceLocation.home);
  late final address = useNotifier<Address?>('address', null);
  late final _controller = useController('address');

  @override
  void initState() {
    super.initState();
    address.addListener(() => _controller.text = address.value?.cityAndAddress ?? '');
  }

  @override
  List<Listenable> get dependencies => [place, address];

  @override
  void complete(OnboardingController controller, WorkplaceData data) => controller.completeWorkplacePage(data);

  @override
  WorkplaceData? validateContinue() {
    if (place.value == null || address.value == null) return null;

    final data = (
      location: place.value!,
      address: address.value!,
      photos: workplace.map((n) => n.value).nonNulls.toList(),
    );
    return data;
  }

  Future<void> _pickAddress() async {
    address.value = await context.ext.push<Address>(AddressPage(initialAddress: address.value));
  }

  @override
  List<Widget> content() => [
    AppText('Расскажи, где ты работаешь', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    AppText(
      'Укажи адрес и добавь фото рабочего места — уют и чистота решают многое',
      style: context.ext.textTheme.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
    ),
    const SizedBox(height: 16),
    GestureOverrideWidget(
      onTap: _pickAddress,
      child: AppTextFormField(
        labelText: 'Выбери адрес',
        controller: _controller,
        validator: Validators.isNotEmpty,
        readOnly: true,
      ),
    ),
    const SizedBox(height: 16),
    ServiceLocationPicker(notifier: place),
    const SizedBox(height: 24),
    AppText('Добавь фото рабочего места', style: context.ext.textTheme.headlineMedium),
    const SizedBox(height: 16),
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          for (var i = 0; i < workplace.length; i++)
            NewImagePickerWidget(
              onImageUpdate: (url) => workplace[i].value = url,
              upload: Dependencies().profileRepository.uploadSinglePhoto,
            ),
        ],
      ),
    ),
  ];
}
