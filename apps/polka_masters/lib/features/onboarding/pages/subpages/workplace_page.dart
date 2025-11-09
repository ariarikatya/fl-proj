import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polka_masters/features/onboarding/controller.dart';
import 'package:shared/shared.dart';

class WorkplacePage extends StatefulWidget {
  const WorkplacePage({super.key});

  @override
  State<WorkplacePage> createState() => _WorkplacePageState();
}

class _WorkplacePageState extends OnboardingPageState<WorkplacePage, OnboardingController, WorkplaceData> {
  late final workplace = List<ValueNotifier<XFile?>>.generate(3, (i) => useNotifier<XFile?>('$i', null));
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
    const AppText('Расскажи, где ты принимаешь клиентов', style: AppTextStyles.headingLarge),
    const SizedBox(height: 24),
    const AppText('Выбери место', style: AppTextStyles.headingSmall),
    const SizedBox(height: 16),
    ServiceLocationPicker(notifier: place),
    const SizedBox(height: 24),
    const AppText('Выбери адрес', style: AppTextStyles.headingSmall),
    const SizedBox(height: 8),
    GestureOverrideWidget(
      onTap: _pickAddress,
      child: AppTextFormField(
        labelText: 'Адрес услуги',
        controller: _controller,
        validator: Validators.isNotEmpty,
        readOnly: true,
      ),
    ),
    const SizedBox(height: 24),
    const AppText('Добавь фото рабочего места', style: AppTextStyles.headingSmall),
    const SizedBox(height: 16),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        for (var i = 0; i < workplace.length; i++)
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: workplace[i],
              builder: (context, value, child) {
                return ImagePickerWidget(
                  onImageAdded: (image) => workplace[i].value = image,
                  onDelete: () => workplace[i].value = null,
                  image: workplace[i].value,
                );
              },
            ),
          ),
      ],
    ),
  ];
}
