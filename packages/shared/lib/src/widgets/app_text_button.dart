import 'package:flutter/material.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/widgets/app_text.dart';

typedef AppButtonStyle = ({EdgeInsets padding, double radius, TextStyle textStyle, TextOverflow? overflow});

final AppButtonStyle _largeStyle = (
  padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
  radius: 14,
  textStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
  overflow: null,
);

final AppButtonStyle _mediumStyle = (
  padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
  radius: 10,
  textStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
  overflow: TextOverflow.ellipsis,
);

final AppButtonStyle _smallStyle = (
  radius: 8,
  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
          borderRadius: BorderRadius.circular(style.radius),
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

class AppTextButtonDangerous extends StatelessWidget {
  const AppTextButtonDangerous._({
    required this.text,
    required this.onTap,
    required this.style,
    required this.enabled,
    required this.shrinkWrap,
  });

  factory AppTextButtonDangerous.large({required String text, required VoidCallback onTap, bool enabled = true}) =>
      AppTextButtonDangerous._(text: text, onTap: onTap, enabled: enabled, style: _largeStyle, shrinkWrap: false);

  factory AppTextButtonDangerous.medium({required String text, required VoidCallback onTap, bool enabled = true}) =>
      AppTextButtonDangerous._(text: text, onTap: onTap, enabled: enabled, style: _mediumStyle, shrinkWrap: false);

  factory AppTextButtonDangerous.small({required String text, required VoidCallback onTap, bool enabled = true}) =>
      AppTextButtonDangerous._(text: text, onTap: onTap, enabled: enabled, style: _mediumStyle, shrinkWrap: true);

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
            color: enabled ? context.ext.theme.error : context.ext.theme.errorLight,
            overflow: style.overflow,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class AppTextButtonTertiary extends StatelessWidget {
  const AppTextButtonTertiary._({
    required this.text,
    required this.onTap,
    required this.style,
    required this.enabled,
    required this.shrinkWrap,
  });

  factory AppTextButtonTertiary.large({required String text, required VoidCallback onTap, bool enabled = true}) =>
      AppTextButtonTertiary._(text: text, onTap: onTap, enabled: enabled, style: _largeStyle, shrinkWrap: false);

  factory AppTextButtonTertiary.medium({required String text, required VoidCallback onTap, bool enabled = true}) =>
      AppTextButtonTertiary._(text: text, onTap: onTap, enabled: enabled, style: _mediumStyle, shrinkWrap: false);

  factory AppTextButtonTertiary.small({required String text, required VoidCallback onTap, bool enabled = true}) =>
      AppTextButtonTertiary._(text: text, onTap: onTap, enabled: enabled, style: _mediumStyle, shrinkWrap: true);

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
          color: enabled ? context.ext.theme.accent : context.ext.theme.backgroundDisabled,
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
