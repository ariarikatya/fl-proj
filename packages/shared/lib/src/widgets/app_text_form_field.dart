import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/src/app_colors.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/icons.dart';
import 'package:shared/src/widgets/app_text.dart';

class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.maxLines = 1,
    this.controller,
    this.prefixIcon,
    this.fillColor,
    this.focusNode,
    this.compact = false,
    this.onFieldSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.clearButton = true,
    this.readOnly = false,
    this.validator,
    this.enabled = true,
    this.onClear,
    this.maxLength,
  });

  final String? labelText;
  final String? hintText;
  final int? maxLines, maxLength;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final bool clearButton;
  final Color? fillColor;
  final bool compact;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final VoidCallback? onClear;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late final FocusNode focusNode;
  late final bool disposeFocusNode;

  @override
  void initState() {
    focusNode = widget.focusNode ?? FocusNode(canRequestFocus: !widget.readOnly, skipTraversal: widget.readOnly);
    disposeFocusNode = widget.focusNode == null;
    super.initState();
  }

  @override
  void dispose() {
    if (disposeFocusNode) focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.borderDefault),
      borderRadius: BorderRadius.circular(14),
    );
    final prefix = widget.prefixIcon != null
        ? Padding(padding: const EdgeInsets.fromLTRB(16, 10, 4, 10), child: widget.prefixIcon!)
        : null;
    final clearBtn = (widget.controller != null && widget.maxLines == 1 && widget.clearButton && !widget.readOnly)
        ? GestureDetector(
            onTap: () async {
              widget.controller?.clear();
              widget.onClear?.call();
              // This is required for correct autovalidation
              focusNode.requestFocus();
              Future(() => focusNode.unfocus());
            },
            child: Padding(padding: const EdgeInsets.all(16), child: AppIcons.close.icon()),
          )
        : null;

    Widget child = TextFormField(
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      canRequestFocus: !widget.readOnly,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onTapOutside: (event) {
        focusNode.unfocus();
        if (widget.controller != null) {
          widget.onFieldSubmitted?.call(widget.controller?.text ?? '');
        }
      },
      focusNode: focusNode,
      maxLines: widget.maxLines,
      controller: widget.controller,
      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      textAlignVertical: widget.compact ? TextAlignVertical.bottom : null,
      cursorColor: AppColors.textPlaceholder,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUnfocus,
      errorBuilder: (context, error) => AppText(error, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
      decoration: InputDecoration(
        prefixIcon: prefix,
        suffixIcon: clearBtn,
        suffixIconConstraints: BoxConstraints.tight(Size(48, 48)),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelText: widget.labelText,
        hintText: widget.hintText,
        floatingLabelStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPlaceholder),
        alignLabelWithHint: true,
        prefixIconConstraints: BoxConstraints.tight(Size(44, 44)),
        labelStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPlaceholder),
        hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPlaceholder),
        border: border,
        fillColor: widget.fillColor ?? AppColors.backgroundHover,
        filled: true,
        enabledBorder: border.copyWith(borderSide: BorderSide.none),
        disabledBorder: border.copyWith(borderSide: BorderSide.none),
        focusedBorder: border.copyWith(borderSide: BorderSide(color: AppColors.borderStrong)),
        errorBorder: border.copyWith(borderSide: BorderSide(color: AppColors.error)),
      ),
    );

    if (widget.compact) {
      child = SizedBox.fromSize(size: Size(double.infinity, 48), child: child);
    }
    return child;
  }
}
