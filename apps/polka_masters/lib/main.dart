import 'dart:async';

import 'package:flutter/material.dart';
import 'package:polka_masters/app.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:shared/shared.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';

void main() => runZonedGuarded(
  () async {
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.handle(details.exception, details.stack);
    };

    WidgetsFlutterBinding.ensureInitialized();
    await Dependencies.init();
    runApp(const App());
  },
  (error, stack) {
    AppMetrica.reportError(
      message: error.toString(),
      errorDescription: AppMetricaErrorDescription(stack, type: 'Unhandled Exception'),
    );
    logger.handle(error, stack, 'This error was caught by ZoneGuarded');
  },
);
