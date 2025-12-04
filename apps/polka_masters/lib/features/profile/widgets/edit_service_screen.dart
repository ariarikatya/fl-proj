import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/profile/controller/services_cubit.dart';
import 'package:polka_masters/features/profile/widgets/profile_screen.dart';
import 'package:shared/shared.dart';

class EditServiceScreen extends StatefulWidget {
  const EditServiceScreen({super.key, required this.service});

  final Service? service;

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  late Service _service =
      widget.service?.copyWith() ??
      const Service(
        id: -1,
        category: ServiceCategories.nailService,
        title: '',
        duration: Duration(hours: 1),
        resultPhotos: [],
        price: 1000,
        cost: null,
      );
  late final _controllers = [
    TextEditingController(text: _service.title),
    TextEditingController(text: _service.price.toString()),
    TextEditingController(),
  ];
  late final _duration = ValueNotifier(_service.duration);
  late final _category = ValueNotifier<ServiceCategories?>(_service.category);

  String? _status;

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    _duration.dispose();
    super.dispose();
  }

  void _save() {
    final title = _controllers[0].text.trim();
    final price = int.tryParse(_controllers[1].text.trim());
    final cost = int.tryParse(_controllers[2].text.trim());
    final duration = _duration.value;
    final category = _category.value;

    if (title.isEmpty || price == null || category == null) {
      return showErrorSnackbar('Пожалуйста, проверь правильность заполнения полей');
    }

    final service = _service.copyWith(
      title: () => title,
      price: () => price,
      cost: () => cost,
      category: () => category,
      duration: () => duration,
    );
    context.ext.pop(service);
  }

  void _delete(int serviceId) async {
    final delete = await showConfirmBottomSheet(
      context: context,
      title: 'Удалить услугу?',
      description: 'Ты собираешься удалить услугу без возможности восстановления',
      acceptText: 'Да, удалить',
      declineText: 'Нет, я передумала',
    );

    if (delete == true && mounted) {
      context.read<ServicesCubit>().deleteService(serviceId);
      context.ext.pop();
    }
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
                      imageUrl: _service.resultPhotos.firstOrNull,
                      height: 320,
                      width: double.infinity,
                      borderRadius: 0,
                    ),
                    Positioned(
                      right: 24,
                      bottom: 24,
                      child: EditButton(
                        onTap: () async {
                          final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (photo != null) {
                            final upload = await Dependencies().profileRepository.uploadPhotos([photo]);
                            final url = upload.unpack()?.values.first;
                            if (url != null) {
                              setState(() => _service = _service.copyWith(resultPhotos: () => [url]));
                            }
                          }
                        },
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
                      AppTextFormField(
                        labelText: 'Название услуги',
                        controller: _controllers[0],
                        validator: Validators.isNotEmpty,
                      ),
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
                        validator: Validators.isNotEmpty,
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
                  if (widget.service != null)
                    AppTextButtonDangerous.large(
                      text: _status ?? 'Удалить услугу',
                      onTap: () => _delete(widget.service!.id),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
