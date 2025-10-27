import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

const clientsTheme = AppTheme(
  textPrimary: Color(0xFF2D2D2D),
  textSecondary: Color(0xFF656565),
  textPlaceholder: Color(0xFFA3A3A3),
  textDisabled: Color(0xFFD4D4D4),
  borderSubtle: Color(0xFFE5E5E5),
  borderDefault: Color(0xFFD4D4D4),
  borderStrong: Color(0xFF737373),
  backgroundDefault: Color(0xFFFFFDFD),
  backgroundSubtle: Color(0xFFFAFAFA),
  backgroundHover: Color(0xFFF5F5F5),
  backgroundDisabled: Color(0xFFE5E5E5),
  iconsDefault: Color(0xFF525252),
  iconsMuted: Color(0xFFA3A3A3),
  error: Color(0xFFFF383C),
  success: Color(0xFF34C759),
  successLight: Color(0xFFE2FFE6),
  accent: Color(0xFFFF85C5),
  accentLight: Color(0xFFFFE6F3),
  buttonPrimary: Color(0xFFFF85C5),
);

const clientsDarkTheme = AppTheme(
  textPrimary: Color(0xFF2D2D2D),
  textSecondary: Color(0xFF656565),
  textPlaceholder: Color(0xFFA3A3A3),
  textDisabled: Color(0xFFD4D4D4),
  borderSubtle: Color(0xFFE5E5E5),
  borderDefault: Color(0xFFD4D4D4),
  borderStrong: Color(0xFF737373),
  backgroundDefault: Color(0xFFFFFDFD),
  backgroundSubtle: Color(0xFFFAFAFA),
  backgroundHover: Color(0xFFF5F5F5),
  backgroundDisabled: Color(0xFFE5E5E5),
  iconsDefault: Color(0xFF525252),
  iconsMuted: Color(0xFFA3A3A3),
  error: Color(0xFFFF383C),
  success: Color(0xFF34C759),
  successLight: Color(0xFFE2FFE6),
  accent: Color(0xFFFF85C5),
  accentLight: Color(0xFFFFE6F3),
  buttonPrimary: Color(0xFF2D2D2D),
);

const pivnayaTheme = AppTheme(
  // Rich stout/dark beer text
  textPrimary: Color(0xFF3A2F29), // Dark roasted malt brown
  textSecondary: Color(0xFF70584A), // Medium malt tone
  textPlaceholder: Color(0xFFA88A78),
  textDisabled: Color(0xFFD9C9BF),

  // Subtle bubbly beige borders
  borderSubtle: Color(0xFFEDE1D8),
  borderDefault: Color(0xFFD7C5BA),
  borderStrong: Color(0xFF8C6E5B),

  // Beer foam + pub wood backgrounds
  backgroundDefault: Color(0xFFFFFCF7), // Light creamy, like foam
  backgroundSubtle: Color(0xFFFDF7F0),
  backgroundHover: Color(0xFFF7EDE3),
  backgroundDisabled: Color(0xFFE6D5C9),

  // Icon tones
  iconsDefault: Color(0xFF5C4539),
  iconsMuted: Color(0xFFB89B8A),

  // Emotions — keep meaning but beer-styled
  error: Color(0xFFD93D3D), // Slightly darker ale red
  success: Color(0xFF7BB662), // Hops green
  successLight: Color(0xFFEAF6E2), // Light hops foam
  // Main accent — lager gold
  accent: Color(0xFFF4B740), // Beer gold
  accentLight: Color(0xFFFFE9B0), // Soft golden foam
  // Primary button — deep stout
  buttonPrimary: Color(0xFF3A2F29),
);

Map<String, AppTheme> themes = {
  'Default': clientsTheme,
  'Dark': clientsDarkTheme,
  if (devMode) '🍺 Пивная (dev)': pivnayaTheme,
};
