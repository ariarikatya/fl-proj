import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/shared.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.initialData});

  final Master initialData;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final _master = widget.initialData.copyWith();
  late final _controllers = [
    TextEditingController(text: _master.fullName),
    TextEditingController(text: _master.profession),
    TextEditingController(text: _master.about),
    TextEditingController(text: 'г. ${_master.city}, ${_master.address}'),
  ];
  late final _experience = ValueNotifier<String?>(_master.experience);
  late final _location = ValueNotifier<ServiceLocation?>(_master.location);
  late final address = ValueNotifier<Address?>(null);
  late final _workplaceImages = List<XFile?>.filled(_workplaceMaxImagesLength, null);
  late final _workplacePlaceholders = List<String?>.from(_master.workplace);

  bool _saving = false;
  static const _workplaceMaxImagesLength = 3;

  @override
  void initState() {
    super.initState();
    address.addListener(() => _controllers[3].text = address.value?.cityAndAddress ?? '');
  }

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    _experience.dispose();
    super.dispose();
  }

  Future<void> _pickAddress() async {
    address.value = await context.ext.push<Address>(AddressPage(initialAddress: address.value));
  }

  void _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Личная информация'),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText.headingLarge('Мой профиль'),
                const SizedBox(height: 8),
                const AppText.secondary(
                  'Клиенты смогут просматривать твой профиль и находить и выбирать тебя быстрее при его заполненности',
                  style: AppTextStyles.bodyMedium500,
                ),
                const SizedBox(height: 16),
                AppTextFormField(
                  labelText: 'Имя и Фамилия',
                  controller: _controllers[0],
                  validator: Validators.fullName,
                ),
                const SizedBox(height: 8),
                AppTextFormField(labelText: 'Твоя профессия', controller: _controllers[1]),
                const SizedBox(height: 28),
                const AppText('Расскажи о себе', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                AppTextFormField(
                  hintText: 'Например, что любишь в своей \nработе, как проводишь встречи \nс клиентами',
                  maxLines: 4,
                  controller: _controllers[2],
                  textStyle: AppTextStyles.bodyLarge500,
                ),
                const SizedBox(height: 20),
                const AppText('Твой стаж работы', style: AppTextStyles.headingSmall),
                const SizedBox(height: 12),
                ExperiencePicker(experience: _experience),
                const SizedBox(height: 32),
                const AppText.headingLarge('Где ты принимаешь клиентов'),
                const SizedBox(height: 8),
                const AppText.secondary(
                  'На основе этой иноформации клиенты смогут быстро находить тебя на карте и по фильтрам',
                  style: AppTextStyles.bodyMedium500,
                ),
                const SizedBox(height: 20),
                const AppText.headingSmall('Место работы'),
                const SizedBox(height: 8),
                ServiceLocationPicker(notifier: _location),
                const SizedBox(height: 28),
                const AppText.headingSmall('Адрес оказания услуг'),
                const SizedBox(height: 12),
                GestureOverrideWidget(
                  onTap: _pickAddress,
                  child: AppTextFormField(
                    labelText: 'Адрес услуги',
                    controller: _controllers[3],
                    validator: Validators.isNotEmpty,
                    readOnly: true,
                  ),
                ),
                const SizedBox(height: 28),
                const AppText.headingSmall('Фото рабочего места'),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    children: [
                      for (int i = 0; i < _workplaceMaxImagesLength; i++)
                        ImagePickerWidget(
                          onDelete: () => setState(() => _workplaceImages[i] = null),
                          image: _workplaceImages.elementAtOrNull(i),
                          imagePLaceholderUrl: _workplacePlaceholders.elementAtOrNull(i),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: AppTextButton.large(text: _saving ? 'Сохраняем...' : 'Сохранить изменения', onTap: _save),
            ),
          ),
        ],
      ),
    );
  }
}
