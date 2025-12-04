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
      width: 56,
      height: 64,
      textStyle: AppTextStyles.headingMedium,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: context.ext.colors.white[200]),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: context.ext.colors.black[500]),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(border: Border.all(color: context.ext.colors.error));

    return Pinput(
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      errorPinTheme: errorPinTheme,
      length: 4,
      closeKeyboardWhenCompleted: true,
      errorText: errorText,
      forceErrorState: errorText != null,
      validator: (s) {
        return s?.length == 4 ? null : 'Неправильный код';
      },
      errorTextStyle: AppTextStyles.bodyLarge.copyWith(color: context.ext.colors.error),
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
