import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/widgets/app_text.dart';

class AppLinkButton extends StatelessWidget {
  const AppLinkButton({
    super.key,
    required this.text,
    this.onTap,
    this.style,
    this.padding,
    this.underlineOffset = 1.5,
    this.underlineThickness = 1.5,
  });

  final String text;
  final VoidCallback? onTap;
  final TextStyle? style;
  final EdgeInsets? padding;
  final double underlineOffset;
  final double underlineThickness;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final $style =
        style ??
        context.ext.textTheme.bodyLarge?.copyWith(color: context.ext.colors.black[900], fontWeight: FontWeight.w600);
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: padding ?? EdgeInsets.all(4),
          child: AppText(
            text,
            style: $style?.copyWith(
              decoration: TextDecoration.underline,
              shadows: [
                Shadow(
                  color: isDisabled ? Colors.grey : $style.color ?? context.ext.colors.black[900],
                  offset: Offset(0, -max(underlineOffset, .01)),
                ),
              ],
              decorationColor: isDisabled ? Colors.grey : $style.color,
              decorationThickness: underlineThickness,
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
