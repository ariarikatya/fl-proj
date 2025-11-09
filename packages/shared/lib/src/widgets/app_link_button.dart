import 'package:flutter/material.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/widgets/app_text.dart';

class AppLinkButton extends StatelessWidget {
  const AppLinkButton({super.key, required this.text, this.onTap, this.style, this.padding});

  final String text;
  final VoidCallback? onTap;
  final TextStyle? style;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final $style = style ?? AppTextStyles.bodyLarge;
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: padding ?? EdgeInsets.all(4),
          child: AppText(
            text,
            style: $style.copyWith(
              decoration: TextDecoration.underline,
              shadows: [
                Shadow(
                  color: isDisabled ? Colors.grey : $style.color ?? context.ext.theme.textPrimary,
                  offset: Offset(0, -1.5),
                ),
              ],
              decorationThickness: 1.5,
              fontWeight: FontWeight.bold,
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
