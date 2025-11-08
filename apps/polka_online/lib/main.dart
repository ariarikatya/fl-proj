import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared/shared.dart';
import 'dependencies.dart';
import 'authorization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ru_RU', null);

  Dependencies.instance.init();

  final masterId = Dependencies.getMasterIdFromUrl();
  logger.info('[main] Starting app with masterId: $masterId');

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
        navigatorKey: navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          final uri = Uri.base;
          final masterId = Dependencies.getMasterIdFromUrl() ?? '1';

          logger.info('[Router] Routing to: ${settings.name}');
          logger.info('[Router] URI path: ${uri.path}');
          logger.info('[Router] MasterId: $masterId');

          if (uri.pathSegments.isEmpty ||
              (uri.pathSegments.length >= 2 &&
                  uri.pathSegments[0] == 'masters')) {
            return MaterialPageRoute(
              builder: (context) => AuthorizationPage(masterId: masterId),
              settings: settings,
            );
          }

          return MaterialPageRoute(
            builder: (context) => AuthorizationPage(masterId: masterId),
            settings: settings,
          );
        },
      ),
    );
  }
}
