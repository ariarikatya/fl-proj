import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared/shared.dart';
import 'dependencies.dart';
import 'authorization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ru', null);

  Dependencies.instance.init();

  final masterId = Dependencies.getMasterIdFromUrl();
  logger.info('[main] Starting app with masterId: $masterId');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polka Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB9CD)), useMaterial3: true),
      navigatorKey: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.base;
        final masterId = Dependencies.getMasterIdFromUrl() ?? '1';

        logger.info('[Router] Routing to: ${settings.name}');
        logger.info('[Router] URI path: ${uri.path}');
        logger.info('[Router] MasterId: $masterId');

        if (uri.pathSegments.isEmpty || (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'masters')) {
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
    );
  }
}
