import 'package:flutter/material.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/widgets/app_text.dart';

typedef AppButtonStyle = ({EdgeInsets padding, TextStyle textStyle, TextOverflow? overflow});

final AppButtonStyle _largeStyle = (
  padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
  textStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
  overflow: null,
);

final AppButtonStyle _mediumStyle = (
  padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
  textStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
  overflow: TextOverflow.ellipsis,
);

final AppButtonStyle _smallStyle = (
  padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
  textStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
  overflow: TextOverflow.ellipsis,
);

class AppTextButton extends StatelessWidget {
  const AppTextButton._({
    required this.text,
    required this.onTap,
    required this.style,
    required this.enabled,
    required this.shrinkWrap,
  });

  factory AppTextButton.large({
    required String text,
    required VoidCallback onTap,
    bool enabled = true,
    bool shrinkWrap = false,
  }) => AppTextButton._(text: text, onTap: onTap, enabled: enabled, style: _largeStyle, shrinkWrap: shrinkWrap);

  factory AppTextButton.medium({
    required String text,
    required VoidCallback onTap,
    bool enabled = true,
    bool shrinkWrap = false,
  }) => AppTextButton._(text: text, onTap: onTap, enabled: enabled, style: _mediumStyle, shrinkWrap: shrinkWrap);

  factory AppTextButton.small({
    required String text,
    required VoidCallback onTap,
    bool enabled = true,
    bool shrinkWrap = true,
  }) => AppTextButton._(text: text, onTap: onTap, enabled: enabled, style: _smallStyle, shrinkWrap: shrinkWrap);

  final String text;
  final VoidCallback onTap;
  final bool enabled;
  final bool shrinkWrap;

  final AppButtonStyle style;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: style.padding,
        width: shrinkWrap ? null : double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: enabled ? context.ext.theme.buttonPrimary : context.ext.theme.backgroundDisabled,
        ),
        child: AppText(
          text,
          style: style.textStyle.copyWith(
            color: enabled ? context.ext.theme.backgroundHover : context.ext.theme.backgroundSubtle,
            overflow: style.overflow,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class AppTextButtonSecondary extends StatelessWidget {
  const AppTextButtonSecondary._({
    required this.text,
    required this.onTap,
    required this.style,
    required this.enabled,
    required this.shrinkWrap,
  });

  factory AppTextButtonSecondary.large({required String text, required VoidCallback onTap, bool enabled = true}) =>
      AppTextButtonSecondary._(text: text, onTap: onTap, enabled: enabled, style: _largeStyle, shrinkWrap: false);

  factory AppTextButtonSecondary.medium({required String text, required VoidCallback onTap, bool enabled = true}) =>
      AppTextButtonSecondary._(text: text, onTap: onTap, enabled: enabled, style: _mediumStyle, shrinkWrap: false);

  factory AppTextButtonSecondary.small({required String text, required VoidCallback onTap, bool enabled = true}) =>
      AppTextButtonSecondary._(text: text, onTap: onTap, enabled: enabled, style: _mediumStyle, shrinkWrap: true);

  final String text;
  final VoidCallback onTap;
  final bool enabled;
  final bool shrinkWrap;

  final AppButtonStyle style;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: style.padding,
        width: shrinkWrap ? null : double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: enabled ? context.ext.theme.backgroundHover : context.ext.theme.backgroundDisabled,
        ),
        child: AppText(
          text,
          style: style.textStyle.copyWith(
            color: enabled ? context.ext.theme.textPrimary : context.ext.theme.backgroundSubtle,
            overflow: style.overflow,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
