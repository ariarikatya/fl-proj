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

    // Show splash for at least 2.5 seconds
    await Future.wait([Dependencies.init(), Future.delayed(const Duration(milliseconds: 2500))]);
    runApp(const App());
  },
  (error, stack) {
    errorReporter?.call(error, stack);
    logger.handle(error, stack, 'This error was caught by ZoneGuarded');
  },
);
