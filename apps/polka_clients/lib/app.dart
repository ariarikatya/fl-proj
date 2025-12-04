import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:polka_clients/authentication_scope.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/main_page.dart';
import 'package:shared/shared.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  Widget $injectScopes(Widget child) {
    return AuthenticationScopeWidget(controller: Dependencies().authController, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('ru', 'RU')],
      theme: ThemeData(extensions: [polkaClientsThemeExtension], textTheme: polkaTextTheme),
      home: const MainPage(),
      navigatorKey: navigatorKey,
      navigatorObservers: [talkerRouteObserver()],
      builder: (context, child) => $injectScopes(child!),
    );
  }
}
