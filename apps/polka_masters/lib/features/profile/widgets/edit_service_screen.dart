import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polka_masters/features/profile/widgets/profile_screen.dart';
import 'package:shared/shared.dart';

class EditServiceScreen extends StatefulWidget {
  const EditServiceScreen({super.key, required this.service});

  final Service? service;

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  late final _service = widget.service?.copyWith();
  late final _controllers = [
    TextEditingController(text: _service?.title),
    TextEditingController(text: _service?.price.toString()),
    TextEditingController(),
  ];
  late final _duration = ValueNotifier(_service?.duration ?? const Duration(hours: 1));
  late final _category = ValueNotifier<ServiceCategories?>(_service?.category);

  String? _status;

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    _duration.dispose();
    super.dispose();
  }

  void _save() async {
    setState(() => _status = 'Загрузка');
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _status = null);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: ''),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ImageClipped(
                      imageUrl: _service?.resultPhotos.firstOrNull,
                      height: 320,
                      width: double.infinity,
                      borderRadius: 0,
                    ),
                    Positioned(
                      right: 24,
                      bottom: 24,
                      child: EditButton(
                        onTap: () {},
                        child: const AppText.secondary('Изменить фото', style: AppTextStyles.bodyMedium),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.headingSmall('Основная информация'),
                      const SizedBox(height: 16),
                      AppTextFormField(labelText: 'Название услуги', controller: _controllers[0]),
                      const SizedBox(height: 16),
                      const AppText.headingSmall('Цена услуги, ₽'),
                      const SizedBox(height: 16),
                      AppTextFormField(
                        hintText: '1500',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        controller: _controllers[1],
                        prefixIcon: const AppText('₽', style: AppTextStyles.bodyLarge),
                        prefixIconConstraints: const BoxConstraints.tightFor(width: 32),
                      ),
                      const SizedBox(height: 16),
                      const AppText.headingSmall('Себестоимость услуги, ₽'),
                      const SizedBox(height: 8),
                      const AppText.secondary(
                        'Это поле необязательное, но если ты знаешь себестоимость своей услуги, ты можешь указать, а мы учтем это в аналитике дохода',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      AppTextFormField(
                        hintText: '1500',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        controller: _controllers[2],
                        prefixIcon: const AppText('₽', style: AppTextStyles.bodyLarge),
                        prefixIconConstraints: const BoxConstraints.tightFor(width: 32),
                      ),
                      const SizedBox(height: 16),
                      const AppText.headingSmall('Длительность услуги'),
                      const SizedBox(height: 8),
                      DurationPicker(duration: _duration),
                      const SizedBox(height: 16),
                      const AppText.headingSmall('Категория услуги'),
                      const SizedBox(height: 16),
                      ServiceCategoryPicker(category: _category),
                      const SizedBox(height: 160),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Column(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.service == null
                      ? AppTextButton.large(text: _status ?? 'Создать новую услугу', onTap: _save)
                      : AppTextButton.large(text: _status ?? 'Сохранить изменения', onTap: _save),
                  AppTextButtonDangerous.large(text: _status ?? 'Удалить услугу', onTap: _save),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
