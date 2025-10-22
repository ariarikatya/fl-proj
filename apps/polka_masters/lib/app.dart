import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/home_page.dart';
import 'package:polka_masters/scopes/authentication_scope.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:shared/shared.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> {
  Widget $injectScopes(Widget child) {
    return AuthenticationScopeWidget(
      controller: Dependencies().authController,
      child: CalendarScopeWidget(controller: EventController(), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('ru', 'RU')],
      home: HomePage(),
      navigatorKey: navigatorKey,
      navigatorObservers: [talkerRouteObserver()],
      builder: (context, child) => $injectScopes(child!),
    );
  }
}
