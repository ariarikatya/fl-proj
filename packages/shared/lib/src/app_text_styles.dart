import 'package:flutter/material.dart';

abstract class AppTextStyles {
  static const heading = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  static const headingLarge = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  static const headingMedium = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  static const headingSmall = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  static const bodyLarge = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const bodyLarge2 = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static const bodyMedium500 = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const bodySmall = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
}
