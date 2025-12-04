import 'package:flutter/material.dart';
import 'package:shared/src/app_links.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/features/auth/presentation/support_button.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/utils.dart';
import 'package:shared/src/widgets/app_link_button.dart';
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
          SizedBox(
            height: 360,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    'Введи номер телефона',
                    style: context.ext.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  AppText(
                    'Мы пришлём тебе код для входа, чтобы POLKA могла тебя узнать',
                    style: context.ext.textTheme.bodyMedium?.copyWith(color: context.ext.colors.black[700]),
                  ),
                  SizedBox(height: 24),
                  AppPhoneForm(onSubmit: _onSubmit),
                ],
              ),
            ),
          ),
          Align(child: SupportButton()),
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
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: AppText.rich(
              [
                TextSpan(
                  text: 'Нажимая “Получить код”, вы подтверждаете свое согласие с обработкой ',
                  style: context.ext.textTheme.bodySmall?.copyWith(color: context.ext.colors.black[700]),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: AppLinkButton(
                    text: 'персональных данных',
                    padding: EdgeInsets.zero,
                    style: context.ext.textTheme.bodySmall?.copyWith(
                      color: context.ext.colors.black[900],
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    underlineOffset: .5,
                    onTap: () => launchUrl(Uri.parse(AppLinks.docs.privacyPolicy)),
                  ),
                ),
              ],
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
