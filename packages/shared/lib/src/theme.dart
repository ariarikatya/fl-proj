import 'package:flutter/material.dart';

@immutable
/// Represents colors from Polka UI kit
class PolkaThemeExtension extends ThemeExtension<PolkaThemeExtension> {
  const PolkaThemeExtension({
    required this.black,
    required this.white,
    required this.pink,
    required this.primary,
    required this.success,
    required this.warning,
    required this.error,
  });

  @override
  ThemeExtension<PolkaThemeExtension> copyWith({
    ColorsSpectrum? black,
    ColorsSpectrum? white,
    ColorsSpectrum? pink,
    Color? primary,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return PolkaThemeExtension(
      black: black ?? this.black,
      white: white ?? this.white,
      pink: pink ?? this.pink,
      primary: primary ?? this.primary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  ThemeExtension<PolkaThemeExtension> lerp(covariant ThemeExtension<PolkaThemeExtension>? other, double t) {
    return other ?? this;
  }

  final ColorsSpectrum black;
  final ColorsSpectrum white;
  final ColorsSpectrum pink;

  final Color primary;
  final Color success;
  final Color warning;
  final Color error;
}

/// Represents a spectre of colors
class ColorsSpectrum {
  const ColorsSpectrum(this.colors);

  final Map<int, Color> colors;

  Color operator [](int index) {
    assert(colors[index] != null, '$this has no color with value [$index]');
    return colors[index] ?? colors.values.first;
  }
}

const polkaClientsThemeExtension = PolkaThemeExtension(
  black: ColorsSpectrum({
    100: Color(0xFFDAD5D2),
    300: Color(0xFFBDB5B0),
    500: Color(0xFF7E7672),
    700: Color(0xFF52443E),
    900: Color(0xFF2D1E17),
  }),
  white: ColorsSpectrum({
    100: Color(0xFFFFFEFD),
    200: Color(0xFFF9F9F4),
    300: Color(0xFFEBEBE6),
    400: Color(0xFFD1CCC8),
  }),
  pink: ColorsSpectrum({
    50: Color(0xFFFFF9FB),
    100: Color(0xFFFFEBF4),
    300: Color(0xFFFBB9D6),
    500: Color(0xFFFA93BE),
    900: Color(0xFFC95F89),
  }),
  primary: Color(0xFFFA93BE),
  success: Color(0xFFB7C6A7),
  warning: Color(0xFFE8CDA0),
  error: Color(0xFFD47A7A),
);

const polkaMastersThemeExtension = PolkaThemeExtension(
  black: ColorsSpectrum({
    100: Color(0xFFDAD5D2),
    300: Color(0xFFBDB5B0),
    500: Color(0xFF7E7672),
    700: Color(0xFF52443E),
    900: Color(0xFF2D1E17),
  }),
  white: ColorsSpectrum({
    100: Color(0xFFFFFEFD),
    200: Color(0xFFF9F9F4),
    300: Color(0xFFEBEBE6),
    400: Color(0xFFD1CCC8),
  }),
  pink: ColorsSpectrum({
    50: Color(0xFFFFF9FB),
    100: Color(0xFFFFEBF4),
    300: Color(0xFFFBB9D6),
    500: Color(0xFFFA93BE),
    900: Color(0xFFC95F89),
  }),
  primary: Color(0xFF2D1E17),
  success: Color(0xFFB7C6A7),
  warning: Color(0xFFE8CDA0),
  error: Color(0xFFD47A7A),
);

const polkaThemeExtension = PolkaThemeExtension(
  black: ColorsSpectrum({
    100: Color(0xFFDAD5D2),
    300: Color(0xFFBDB5B0),
    500: Color(0xFF7E7672),
    700: Color(0xFF52443E),
    900: Color(0xFF2D1E17),
  }),
  white: ColorsSpectrum({
    100: Color(0xFFFFFEFD),
    200: Color(0xFFF9F9F4),
    300: Color(0xFFEBEBE6),
    400: Color(0xFFD1CCC8),
  }),
  pink: ColorsSpectrum({
    50: Color(0xFFFFF9FB),
    100: Color(0xFFFFEBF4),
    300: Color(0xFFFBB9D6),
    500: Color(0xFFFA93BE),
    900: Color(0xFFC95F89),
  }),
  primary: Color(0xFF2D1E17),
  success: Color(0xFFB7C6A7),
  warning: Color(0xFFE8CDA0),
  error: Color(0xFFD47A7A),
);
