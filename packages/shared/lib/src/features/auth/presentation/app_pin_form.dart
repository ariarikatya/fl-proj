import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/app_text_styles.dart';

class AppPinForm extends StatefulWidget {
  const AppPinForm({super.key, required this.validateCode});

  final Future<String?> Function(String code) validateCode;

  @override
  State<AppPinForm> createState() => _AppPinFormState();
}

class _AppPinFormState extends State<AppPinForm> {
  String? errorText;

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: AppTextStyles.headingMedium,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.ext.theme.backgroundHover,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: context.ext.theme.borderStrong),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: context.ext.theme.error),
    );

    return Pinput(
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      errorPinTheme: errorPinTheme,
      length: 4,
      errorText: errorText,
      forceErrorState: errorText != null,
      validator: (s) {
        return s?.length == 4 ? null : 'Неправильный код';
      },
      errorTextStyle: AppTextStyles.bodyLarge.copyWith(
        color: context.ext.theme.error,
      ),
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onCompleted: (pin) async {
        setState(() => this.errorText = null);
        final errorText = await widget.validateCode(pin);
        setState(() => this.errorText = errorText);
      },
    );
  }
}
