import 'dart:async';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polka_clients/app.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:shared/shared.dart';

void main() => runZonedGuarded(
  () async {
    WidgetsFlutterBinding.ensureInitialized();
    await Dependencies.init();
    runApp(const App());

    if (kDebugMode) {
      Timer.periodic(const Duration(seconds: 5), (_) {
        print('${imageCache.currentSize}, ${(imageCache.currentSizeBytes / 1024 / 1024).toStringAsFixed(1)} MB');
      });
    }
  },
  (error, stack) {
    AppMetrica.reportError(
      message: error.toString(),
      errorDescription: AppMetricaErrorDescription(stack, type: 'Unhandled Exception'),
    );
    logger.handle(error, stack, 'This error was caught by ZoneGuarded');
  },
);
