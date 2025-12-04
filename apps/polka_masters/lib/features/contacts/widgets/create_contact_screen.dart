import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/contacts/widgets/contact_avatar.dart';
import 'package:shared/shared.dart';

class CreateContactScreen extends StatefulWidget {
  const CreateContactScreen({super.key});

  @override
  State<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends State<CreateContactScreen> {
  late final _controllers = List.generate(5, (_) => TextEditingController());
  late var _contact = const Contact(id: -1, name: '', number: '');
  final emailValidator = Validators.email;

  bool get canCreate =>
      _contact.name.isNotEmpty && _contact.city != null && _contact.city!.isNotEmpty && _contact.number.isNotEmpty;

  @override
  void dispose() {
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _onImagePicked(XFile xfile) async {
    final result = await Dependencies().profileRepository.uploadPhotos([xfile]);
    _updateContact(_contact.copyWith(avatarUrl: () => result.unpack()?.values.first));
  }

  void _updateContact(Contact contact) {
    setState(() => _contact = contact);
  }

  void _pickCity() async {
    final $city = await context.ext.push<City>(CityPage(initialCity: _contact.city));
    if ($city != null && mounted) {
      _updateContact(_contact.copyWith(city: () => $city.name));
      _controllers[1].text = $city.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Создай  новую карточку'),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ContactBlotAvatar(contact: _contact, size: 70),
                          AddPhotoBtn(onImagePicked: _onImagePicked),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const AppText('Расскажи о клиенте', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 8),
                  AppText(
                    'Запиши данные, чтобы сохранить все данные и поздравлять с Днём рождения',
                    style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.colors.black[700]),
                  ),
                  const SizedBox(height: 24),
                  AppTextFormField(
                    hintText: 'Имя и Фамилия*',
                    controller: _controllers[0],
                    onFieldSubmitted: (value) => _updateContact(_contact.copyWith(name: () => value)),
                  ),
                  const SizedBox(height: 8),
                  GestureOverrideWidget(
                    onTap: _pickCity,
                    child: AppTextFormField(hintText: 'Город*', readOnly: true, controller: _controllers[1]),
                  ),
                  const SizedBox(height: 8),
                  AppTextFormField(
                    hintText: 'День рождения',
                    controller: _controllers[2],
                    inputFormatters: [birthdayMask],
                    onFieldSubmitted: (birthday) {
                      final date = DateTime.tryParse(birthday.split('.').reversed.join('-'));
                      _updateContact(_contact.copyWith(birthday: () => date));
                    },
                  ),
                  const SizedBox(height: 24),
                  const AppText('Контакты', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 8),
                  AppText(
                    'Запиши данные, чтобы быть на связи с клиентом',
                    style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.colors.black[700]),
                  ),
                  const SizedBox(height: 24),
                  AppPhoneTextField(
                    labelText: 'Номер телефона*',
                    onNumberChanged: (value) {
                      if (value.length != 10) _updateContact(_contact.copyWith(number: () => ''));
                    },
                    onNumberSubmitted: (number) => _updateContact(_contact.copyWith(number: () => '7$number')),
                  ),
                  const SizedBox(height: 8),
                  AppTextFormField(
                    hintText: 'E-mail',
                    controller: _controllers[3],
                    onFieldSubmitted: (email) {
                      final valid = email.isNotEmpty && emailValidator(email) == null;
                      if (valid) _updateContact(_contact.copyWith(email: () => email));
                    },
                    validator: emailValidator,
                  ),
                  const SizedBox(height: 24),
                  const AppText('Добавь заметку о клиенте', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 8),
                  AppText(
                    'Запиши данные, чтобы не забыть важные детали, например, предпочтения или аллергии',
                    style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.colors.black[700]),
                  ),
                  const SizedBox(height: 24),
                  AppTextFormField(
                    hintText: 'Например, аллергия на коллаген',
                    maxLength: 1000,
                    maxLines: 4,
                    controller: _controllers[4],
                    onFieldSubmitted: (value) => _updateContact(_contact.copyWith(notes: () => value)),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: AppTextButton.large(
                text: 'Создать контакт',
                onTap: () => context.ext.pop(_contact),
                enabled: canCreate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
