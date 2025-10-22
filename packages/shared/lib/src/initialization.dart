import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> initializeFormatting() async {
  await initializeDateFormatting('ru', null);
}

final navigatorKey = GlobalKey<NavigatorState>();
