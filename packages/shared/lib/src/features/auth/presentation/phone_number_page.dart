import 'package:flutter/material.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/widgets/app_page.dart';
import 'package:shared/src/widgets/app_phone_text_field.dart';
import 'package:shared/src/widgets/app_text.dart';
import 'package:shared/src/widgets/app_text_button.dart';

class PhoneNumberPage extends StatelessWidget {
  const PhoneNumberPage({super.key, required this.onCodeSended, required this.sendCode});

  final void Function(String phoneNumber) onCodeSended;
  final Future<Result<bool>> Function(String phoneNumber) sendCode;

  Future<void> _onSubmit(String phoneNumber) async {
    sendCode(phoneNumber).ignore();
    onCodeSended(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText('Введи номер телефона', style: AppTextStyles.headingLarge),
                SizedBox(height: 8),
                AppText(
                  'Мы отправим вам SMS с кодом\nдля входа',
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 24),
                AppPhoneForm(onSubmit: _onSubmit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppPhoneForm extends StatefulWidget {
  const AppPhoneForm({super.key, this.onSubmit});

  final void Function(String)? onSubmit;

  @override
  State<AppPhoneForm> createState() => _AppPhoneFormState();
}

class _AppPhoneFormState extends State<AppPhoneForm> {
  final _formKey = GlobalKey<FormState>();
  final _notifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    final fieldKey = GlobalKey<FormFieldState<String>>();
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppPhoneTextField(fieldKey: fieldKey, notifier: _notifier),
          SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: _notifier,
            builder: (context, value, child) {
              return AppTextButton.large(
                text: 'Получить код',
                enabled: value.length == 10,
                onTap: () {
                  final valid = _formKey.currentState?.validate();
                  if (valid == true) {
                    final number = '7${_notifier.value}';
                    widget.onSubmit?.call(number);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
