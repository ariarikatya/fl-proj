import 'package:flutter/material.dart';
import 'package:shared/src/app_text_styles.dart';

import '../app_colors.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.selectable = false,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final $style = TextStyle(color: AppColors.textPrimary, overflow: overflow).merge(style ?? AppTextStyles.bodyLarge);

    if (selectable) {
      return SelectableText(text, textAlign: textAlign, style: $style, maxLines: maxLines);
    }

    return Text(text, textAlign: textAlign, style: $style, maxLines: maxLines);
  }
}
