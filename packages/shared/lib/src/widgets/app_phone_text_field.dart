import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/app_text_styles.dart';

MaskTextInputFormatter phoneFormatter = MaskTextInputFormatter(
  mask: '(+#) ### - ### - ## - ##',
  filter: {"#": RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

class AppPhoneTextField extends StatelessWidget {
  const AppPhoneTextField({super.key, this.fieldKey, this.notifier});

  final Key? fieldKey;

  /// Notifies when the phone number is changed, without the +7 prefix
  final ValueNotifier<String>? notifier;

  @override
  Widget build(BuildContext context) {
    final maskFormatter = MaskTextInputFormatter(
      mask: '(+7) ### - ### - ## - ##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: context.ext.theme.borderDefault),
      borderRadius: BorderRadius.circular(14),
    );

    return TextFormField(
      key: fieldKey,
      onChanged: (value) {
        notifier?.value = maskFormatter.getUnmaskedText();
      },
      validator: (_) {
        print((maskFormatter.getUnmaskedText(), maskFormatter.getUnmaskedText().length));
        if (maskFormatter.getUnmaskedText().length == 10) {
          return null;
        }
        return 'Пожалуйста, введи корректный номер';
      },
      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: '(+7)',
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: context.ext.theme.textPlaceholder,
          fontWeight: FontWeight.bold,
        ),
        border: border,
        fillColor: context.ext.theme.backgroundHover,
        filled: true,
        enabledBorder: border.copyWith(borderSide: BorderSide.none),
        focusedBorder: border.copyWith(borderSide: BorderSide(color: context.ext.theme.borderStrong)),
        errorBorder: border.copyWith(borderSide: BorderSide(color: context.ext.theme.error)),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [maskFormatter],
    );
  }
}
