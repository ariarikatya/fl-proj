import 'dart:async';

import 'package:flutter/material.dart';
import 'package:polka_masters/app.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/splash_screen.dart';
import 'package:shared/shared.dart';

void main() => runZonedGuarded(
  () async {
    runApp(const SplashScreen());
    WidgetsFlutterBinding.ensureInitialized();
    await Dependencies.init();
    await Future.delayed(const Duration(seconds: 2));
    runApp(const App());
  },
  (error, stack) {
    CrashlyticsService().reportError(error, stack);
    logger.handle(error, stack, 'This error was caught by ZoneGuarded');
  },
);
