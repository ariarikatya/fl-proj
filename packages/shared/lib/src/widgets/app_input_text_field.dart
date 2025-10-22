import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/icons.dart';
import 'package:shared/src/widgets/app_text.dart';

class AppInputTextField extends StatefulWidget {
  const AppInputTextField({
    super.key,
    this.hintText,
    this.maxLines,
    this.controller,
    this.prefixIcon,
    this.focusNode,
    this.suffixIconBuilder,
    this.onFieldSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.suffixWidth,
  });

  final String? hintText;
  final int? maxLines;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget Function(Widget uploadBtn)? suffixIconBuilder;
  final double? suffixWidth;

  @override
  State<AppInputTextField> createState() => _AppInputTextFieldState();
}

class _AppInputTextFieldState extends State<AppInputTextField> {
  late final _focusNode = FocusNode()..addListener(_focusListener);
  late final _focusNotifier = ValueNotifier(false);

  void _focusListener() => _focusNotifier.value = _focusNode.hasFocus;

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.iconsDefault),
      borderRadius: BorderRadius.circular(16),
    );

    final uploadBtn = ValueListenableBuilder(
      valueListenable: _focusNotifier,
      builder: (context, hasFocus, child) {
        return GestureDetector(
          onTap: () {
            final text = widget.controller?.text.trim();
            if (text?.isNotEmpty == true) {
              widget.onFieldSubmitted?.call(text!);
            } else {
              widget.controller?.clear();
            }
          },
          child: Container(
            margin: EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasFocus ? AppColors.accent : AppColors.textDisabled,
              borderRadius: BorderRadius.circular(40),
            ),
            child: AppIcons.arrowUp.icon(size: 16, color: AppColors.backgroundDefault),
          ),
        );
      },
    );

    Widget child = Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          child: TextFormField(
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            // onTapOutside: (_) => _focusNode.unfocus(),
            onChanged: widget.onChanged,
            focusNode: _focusNode,
            maxLines: 5,
            minLines: 1,
            controller: widget.controller,
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            cursorColor: AppColors.textPlaceholder,
            onFieldSubmitted: widget.onFieldSubmitted,
            autovalidateMode: AutovalidateMode.onUnfocus,
            errorBuilder: (context, error) =>
                AppText(error, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
            decoration: InputDecoration(
              prefixIcon: SizedBox(),
              prefixIconConstraints: BoxConstraints.tight(Size(40, 40)),
              suffixIcon: SizedBox(),
              suffixIconConstraints: BoxConstraints.tightFor(width: widget.suffixWidth ?? 48, height: 48),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              hintText: widget.hintText,
              floatingLabelStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPlaceholder),
              alignLabelWithHint: true,
              labelStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPlaceholder),
              hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPlaceholder),
              border: border,
              filled: true,
              fillColor: AppColors.backgroundDefault,
              enabledBorder: border,
              disabledBorder: border,
              focusedBorder: border,
              errorBorder: border.copyWith(borderSide: BorderSide(color: AppColors.error)),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(padding: EdgeInsets.all(4), child: widget.suffixIconBuilder?.call(uploadBtn) ?? uploadBtn),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(padding: EdgeInsets.all(4), child: widget.prefixIcon),
        ),
      ],
    );

    return child;
  }
}
