import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/scopes/master_model.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.initialData});

  final Master initialData;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
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
  late final _workplaceImages = List<String?>.generate(
    _workplaceMaxImagesCount,
    (index) => _master.workplace.elementAtOrNull(index),
  );
  late final _portfolioImages = List<String?>.generate(
    _portfolioMaxImagesCount,
    (index) => _master.portfolio.elementAtOrNull(index),
  );

  bool _saving = false;

  static const _workplaceMaxImagesCount = 5;
  static const _portfolioMaxImagesCount = 5;

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

  Master? _validate() {
    if (!_formKey.currentState!.validate() || _experience.value == null || _location.value == null) return null;
    final parts = _controllers[0].text.trim().split(' ');

    return _master.copyWith(
      firstName: () => parts.first,
      lastName: () => parts.last,
      profession: () => _controllers[1].text,
      about: () => _controllers[2].text,
      experience: () => _experience.value!,
      location: () => _location.value!,
      address: address.value == null ? null : () => address.value!.address,
      city: address.value == null ? null : () => address.value!.city,
      workplace: () => _workplaceImages.nonNulls.toList(),
      portfolio: () => _portfolioImages.nonNulls.toList(),
    );
  }

  void _save() async {
    final updatedMaster = _validate();
    if (updatedMaster == null) return;

    setState(() => _saving = true);

    final result = await Dependencies().masterRepository.updateMaster(updatedMaster);
    result.when(
      ok: (data) {
        if (mounted) {
          context.read<MasterModel>().updateMaster(updatedMaster);
          showInfoSnackbar('Профиль успешно сохранен');
          context.ext.pop();
        }
      },
      err: handleError,
    );
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Личная информация'),
      child: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                        for (int i = 0; i < _workplaceMaxImagesCount; i++)
                          NewImagePickerWidget(
                            upload: Dependencies().profileRepository.uploadSinglePhoto,
                            onImageUpdate: (imageUrl) {
                              setState(() => _workplaceImages[i] = imageUrl);
                            },
                            initialImageUrl: _workplaceImages.elementAtOrNull(i),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const AppText.headingSmall('Портфолио'),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    clipBehavior: Clip.none,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 8,
                      children: [
                        for (int i = 0; i < _portfolioMaxImagesCount; i++)
                          NewImagePickerWidget(
                            upload: Dependencies().profileRepository.uploadSinglePhoto,
                            onImageUpdate: (imageUrl) {
                              setState(() => _portfolioImages[i] = imageUrl);
                            },
                            initialImageUrl: _portfolioImages.elementAtOrNull(i),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: AppTextButton.large(text: 'Сохранить изменения', onTap: _save, enabled: !_saving),
            ),
          ),
        ],
      ),
    );
  }
}
