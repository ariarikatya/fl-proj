import 'dart:io';
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
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  XFile? _avatarImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _birthdayController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _avatarImage = image);
    }
  }

  bool _validateForm() {
    final nameParts = _nameController.text.trim().split(' ');
    if (nameParts.length < 2) {
      showErrorSnackbar('Введите имя и фамилию');
      return false;
    }
    if (_cityController.text.trim().isEmpty) {
      showErrorSnackbar('Введите город');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      showErrorSnackbar('Введите номер телефона');
      return false;
    }
    return true;
  }

  Future<void> _saveClient() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);
    try {
      // Логика сохранения клиента
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

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: 'Создай новую карточку'),
      backgroundColor: AppColors.backgroundDefault,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: [
                // ===== Верхний блок с аватаром и кнопкой "Добавить" =====
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: BlotAvatar(
                          avatarUrl: _avatarImage?.path ?? '',
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
                // ===========================================================

                // Personal Info Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    AppText(
                      'Расскажи о клиенте',
                      style: AppTextStyles.headingSmall,
                    ),
                    AppText(
                      'Запиши данные, чтобы сохранить все данные и поздравлять с Днём рождения',
                      style: AppTextStyles.bodyMedium500.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppTextFormField(
                      labelText: 'Имя и Фамилия',
                      controller: _nameController,
                    ),
                    AppTextFormField(
                      labelText: 'Город',
                      controller: _cityController,
                    ),
                    AppTextFormField(
                      labelText: 'День рождения',
                      controller: _birthdayController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _DateInputFormatter(),
                      ],
                    ),
                  ],
                ),

                // Contacts Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    AppText('Контакты', style: AppTextStyles.headingSmall),
                    AppText(
                      'Запиши данные, чтобы быть на связи с клиентом',
                      style: AppTextStyles.bodyMedium500.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppTextFormField(
                      labelText: 'Номер телефона',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    AppTextFormField(
                      labelText: 'E-mail',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),

                // Notes Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    AppText(
                      'Добавь заметку о клиенте',
                      style: AppTextStyles.headingSmall,
                    ),
                    AppText(
                      'Запиши данные, чтобы не забыть важные детали, например, предпочтения или аллергии',
                      style: AppTextStyles.bodyMedium500.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Stack(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 104,
                            maxHeight: 104,
                          ),
                          child: AppTextFormField(
                            labelText: 'Например, аллергия на коллаген',
                            controller: _notesController,
                            maxLines: 4,
                          ),
                        ),
                        if (_notesController.text.isNotEmpty)
                          Positioned(
                            right: 12,
                            top: 12,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _notesController.clear()),
                              child: AppIcons.close.icon(size: 16),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: AppColors.backgroundDefault,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: _isSaving
                    ? const Center(child: LoadingIndicator())
                    : AppTextButton.large(
                        text: 'Создать контакт',
                        onTap: _saveClient,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
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
