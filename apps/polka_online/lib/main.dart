import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'welcome.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = AppTheme(
      textPrimary: Colors.black,
      textSecondary: Colors.grey[700]!,
      textPlaceholder: Colors.grey[500]!,
      textDisabled: Colors.grey[400]!,
      borderSubtle: Colors.grey[200]!,
      borderDefault: Colors.grey[300]!,
      borderStrong: Colors.grey[400]!,
      backgroundDefault: Colors.white,
      backgroundSubtle: Colors.grey[50]!,
      backgroundHover: Colors.grey[100]!,
      backgroundDisabled: Colors.grey[200]!,
      iconsDefault: Colors.grey[700]!,
      iconsMuted: Colors.grey[400]!,
      error: Colors.red,
      success: Colors.green,
      successLight: Colors.green[100]!,
      accent: const Color(0xFFFFB9CD),
      accentLight: const Color(0xFFFFF0F4),
      buttonPrimary: Colors.black,
    );

    return AppThemeScope(
      initialTheme: lightTheme,
      themes: {'light': lightTheme},
      child: MaterialApp(
        title: 'Polka Online',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFB9CD), // Pink color from design
          ),
          useMaterial3: true,
        ),
        home: const WelcomePage(),
      ),
    );
  }
}
