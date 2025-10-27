import 'package:flutter/material.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/extensions/context.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.selectable = false,
  }) : _secondaryTextColor = false;

  const AppText.secondary(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.selectable = false,
  }) : _secondaryTextColor = true;

  factory AppText.rich(
    List<InlineSpan> children, {
    TextStyle? style,
    int? maxLines,
    TextOverflow? overflow,
    bool selectable = false,
    TextAlign? textAlign,
  }) => _RichText(
    '',
    children: children,
    style: style,
    maxLines: maxLines,
    overflow: overflow,
    selectable: selectable,
    textAlign: textAlign,
  );

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final Color? color;
  final bool selectable;
  final bool _secondaryTextColor;

  @override
  Widget build(BuildContext context) {
    final $color =
        color ??
        style?.color ??
        (_secondaryTextColor ? context.ext.theme.textSecondary : context.ext.theme.textPrimary);
    final $style = TextStyle(color: $color, overflow: overflow).merge(style ?? AppTextStyles.bodyLarge);

    if (selectable) {
      return SelectableText(text, textAlign: textAlign, style: $style, maxLines: maxLines);
    }

    return Text(text, textAlign: textAlign, style: $style, maxLines: maxLines);
  }
}

class _RichText extends AppText {
  const _RichText(
    super.text, {
    required this.children,
    super.style,
    super.maxLines,
    super.overflow,
    super.selectable,
    super.textAlign,
  });

  final List<InlineSpan> children;

  @override
  Widget build(BuildContext context) {
    final $color = context.ext.theme.textPrimary;
    final $style = TextStyle(color: $color, overflow: overflow).merge(style ?? AppTextStyles.bodyLarge);

    if (selectable) {
      return SelectableText.rich(
        maxLines: maxLines,
        textAlign: textAlign ?? TextAlign.start,
        TextSpan(children: children, style: $style),
      );
    }
    return RichText(
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign ?? TextAlign.start,
      text: TextSpan(children: children, style: $style),
    );
  }
}
