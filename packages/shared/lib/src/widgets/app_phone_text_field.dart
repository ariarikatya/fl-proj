import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared/src/widgets/app_text_form_field.dart';

MaskTextInputFormatter phoneFormatter = MaskTextInputFormatter(
  mask: '(+#) ### - ### - ## - ##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

class AppPhoneTextField extends StatefulWidget {
  const AppPhoneTextField({
    super.key,
    this.fieldKey,
    this.labelText,
    this.notifier,
    this.onNumberChanged,
    this.onNumberSubmitted,
  });

  final Key? fieldKey;
  final String? labelText;

  /// Notifies when the phone number is changed, without the +7 prefix
  @Deprecated('Use onNumberChanged and onNumberSubmitted instead')
  final ValueNotifier<String>? notifier;

  /// Notifies when the phone number is changed, without the +7 prefix
  final void Function(String number)? onNumberChanged;

  /// Notifies when the phone number is submitted, without the +7 prefix
  final void Function(String number)? onNumberSubmitted;

  @override
  State<AppPhoneTextField> createState() => _AppPhoneTextFieldState();
}

class _AppPhoneTextFieldState extends State<AppPhoneTextField> {
  late final _controller = TextEditingController();

  final maskFormatter = MaskTextInputFormatter(
    mask: '(+7) ### - ### - ## - ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onChanged(val) {
    // ignore: deprecated_member_use_from_same_package
    widget.notifier?.value = maskFormatter.getUnmaskedText();
    widget.onNumberChanged?.call(maskFormatter.getUnmaskedText());
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      key: widget.fieldKey,
      controller: _controller,
      onChanged: onChanged,
      onFieldSubmitted: (_) {
        final number = maskFormatter.getUnmaskedText();
        if (number.length == 10) widget.onNumberSubmitted?.call(number);
      },
      clearButton: true,
      validator: (_) {
        final number = maskFormatter.getUnmaskedText();
        if (number.length == 10) return null;
        return 'Введи корректный номер, пожалуйста';
      },
      hintText: '(+7)',
      labelText: widget.labelText ?? 'Номер телефона',
      keyboardType: TextInputType.phone,
      onClear: () {
        maskFormatter.clear();
        onChanged('');
      },
      inputFormatters: [maskFormatter],
    );
  }
}
