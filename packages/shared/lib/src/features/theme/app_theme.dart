import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme({
    required this.textPrimary,
    required this.textSecondary,
    required this.textPlaceholder,
    required this.textDisabled,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.backgroundDefault,
    required this.backgroundSubtle,
    required this.backgroundHover,
    required this.backgroundDisabled,
    required this.iconsDefault,
    required this.iconsMuted,
    required this.error,
    required this.errorLight,
    required this.success,
    required this.successLight,
    required this.accent,
    required this.accentLight,
    required this.buttonPrimary,
  });

  final Color textPrimary;
  final Color textSecondary;
  final Color textPlaceholder;
  final Color textDisabled;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;

  final Color backgroundDefault;
  final Color backgroundSubtle;
  final Color backgroundHover;
  final Color backgroundDisabled;

  final Color iconsDefault;
  final Color iconsMuted;

  final Color buttonPrimary;

  final Color error;
  final Color errorLight;
  final Color success;
  final Color successLight;
  final Color accent;
  final Color accentLight;
}
