import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared/shared.dart';

class CreateClientPage extends StatefulWidget {
  const CreateClientPage({super.key});

  @override
  State<CreateClientPage> createState() => _CreateClientPageState();
}

class _CreateClientPageState extends State<CreateClientPage> {
  final _controllers = _FormControllers();
  String? _uploadedAvatarUrl;
  bool _isSaving = false;

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    logger.debug('picking client avatar');
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    logger.info(
      'Image picked: ${image.path}, size: ${await image.length() ~/ 1024} KB',
    );

    try {
      setState(() => _uploadedAvatarUrl = image.path);
    } catch (e, st) {
      handleError(e, st);
    }
  }

  bool _validateForm() {
    if (_controllers.name.text.trim().split(' ').length < 2) {
      showErrorSnackbar('Введите имя и фамилию');
      return false;
    }
    if (_controllers.city.text.trim().isEmpty) {
      showErrorSnackbar('Введите город');
      return false;
    }
    if (_controllers.phone.text.trim().isEmpty) {
      showErrorSnackbar('Введите номер телефона');
      return false;
    }
    return true;
  }

  Future<void> _saveClient() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);
    try {
      final nameParts = _controllers.name.text.trim().split(' ');
      final client = {
        'firstName': nameParts.first,
        'lastName': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        'city': _controllers.city.text.trim(),
        'birthday': _controllers.birthday.text.trim(),
        'phone': _controllers.phone.text.trim(),
        'email': _controllers.email.text.trim(),
        'messenger': _controllers.messenger.text.trim(),
        'notes': _controllers.notes.text.trim(),
        'avatarUrl': _uploadedAvatarUrl,
      };

      logger.debug('added client: $client');

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        showSuccessSnackbar('Клиент успешно создан');
        Navigator.pop(context, true);
      }
    } catch (e, st) {
      handleError(e, st);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildSection(String title, String subtitle, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(title, style: AppTextStyles.headingSmall),
        const SizedBox(height: 8),
        AppText(
          subtitle,
          style: AppTextStyles.bodyMedium500.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Создай новую карточку'),
      backgroundColor: AppColors.backgroundDefault,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: BlotAvatar(
                      avatarUrl: _uploadedAvatarUrl ?? '',
                      size: 68,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundHover,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          AppIcons.camera.icon(size: 16),
                          AppText(
                            'Добавить',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              'Расскажи о клиенте',
              'Запиши данные, чтобы сохранить все данные и поздравлять с Днём рождения',
              [
                AppTextFormField(
                  labelText: 'Имя и Фамилия',
                  controller: _controllers.name,
                ),
                const SizedBox(height: 8),
                AppTextFormField(
                  labelText: 'Город',
                  controller: _controllers.city,
                ),
                const SizedBox(height: 8),
                AppTextFormField(
                  labelText: 'День рождения',
                  controller: _controllers.birthday,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _DateInputFormatter(),
                  ],
                ),
              ],
            ),
            _buildSection(
              'Контакты',
              'Запиши данные, чтобы быть на связи с клиентом',
              [
                AppTextFormField(
                  labelText: 'Номер телефона',
                  controller: _controllers.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_PhoneInputFormatter()],
                ),
                const SizedBox(height: 8),
                AppTextFormField(
                  labelText: 'E-mail',
                  controller: _controllers.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                AppTextFormField(
                  labelText: 'Telegram/WhatsApp',
                  controller: _controllers.messenger,
                ),
              ],
            ),
            _buildSection(
              'Добавь заметку о клиенте',
              'Запиши данные, чтобы не забыть важные детали, например, предпочтения или аллергии',
              [
                Stack(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 104,
                        maxHeight: 104,
                      ),
                      child: AppTextFormField(
                        labelText: 'Например, аллергия на коллаген',
                        controller: _controllers.notes,
                        maxLines: 4,
                      ),
                    ),
                    if (_controllers.notes.text.isNotEmpty)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _controllers.notes.clear()),
                          child: AppIcons.close.icon(size: 16),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _isSaving
                      ? const Center(child: LoadingIndicator())
                      : AppTextButton.large(
                          text: 'Создать контакт',
                          onTap: _saveClient,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormControllers {
  final name = TextEditingController();
  final city = TextEditingController();
  final birthday = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final messenger = TextEditingController();
  final notes = TextEditingController();

  void dispose() {
    name.dispose();
    city.dispose();
    birthday.dispose();
    phone.dispose();
    email.dispose();
    messenger.dispose();
    notes.dispose();
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.length > 10) return oldValue;

    String formatted = '';
    int digitCount = 0;

    for (int i = 0; i < text.length; i++) {
      if (RegExp(r'\d').hasMatch(text[i])) {
        formatted += text[i];
        digitCount++;
        if (digitCount == 2 || digitCount == 4) formatted += '.';
      }
    }

    if (formatted.endsWith('.') && digitCount != 2 && digitCount != 4) {
      formatted = formatted.substring(0, formatted.length - 1);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    if (!text.startsWith('+7')) {
      final digitsOnly = text.replaceAll(RegExp(r'\D'), '');
      final newText = '+7$digitsOnly';
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    if (text.length > 12) return oldValue;

    return newValue;
  }
}
