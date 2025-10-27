import 'dart:async';

import 'package:flutter/material.dart';
import 'package:polka_clients/app.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:shared/shared.dart';

void main() => runZonedGuarded(
  () async {
    WidgetsFlutterBinding.ensureInitialized();
    await Dependencies.init();
    runApp(const App());
  },
  (error, stack) {
    CrashlyticsService().reportError(error, stack);
    logger.handle(error, stack, 'This error was caught by ZoneGuarded');
  },
);
