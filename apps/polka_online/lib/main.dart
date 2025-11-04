import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- добавили
import 'package:shared/shared.dart';
import 'welcome.dart';
import 'dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация локали для intl
  await initializeDateFormatting('ru_RU', null);

  // true = использовать моковые данные, false = реальные с сервера
  Dependencies.instance.init();

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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB9CD)),
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final uri = Uri.parse(settings.name ?? '/');

          if (uri.pathSegments.isEmpty) {
            return MaterialPageRoute(
              builder: (context) => const WelcomePage(masterId: '5'),
              settings: settings,
            );
          }

          if (uri.pathSegments.length == 2 &&
              uri.pathSegments[0] == 'masters') {
            final masterId = uri.pathSegments[1];
            return MaterialPageRoute(
              builder: (context) => WelcomePage(masterId: masterId),
              settings: settings,
            );
          }

          return MaterialPageRoute(
            builder: (context) => const WelcomePage(),
            settings: settings,
          );
        },
      ),
    );
  }
}
