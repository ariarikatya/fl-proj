import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:flutter_udid/flutter_udid.dart';

Future<String> get flutterUdid => FlutterUdid.udid;

bool get devMode => kDebugMode || Env.devMode;

Null handleError(Object? err, [StackTrace? stackTrace, bool showSnackbar = true]) {
  logger.error('Error caught', err, stackTrace);
  if (showSnackbar) {
    showErrorSnackbar(parseError(err, stackTrace));
  } else if (devMode) {
    showErrorSnackbar('[DEV MODE ONLY]\n${parseError(err, stackTrace)}');
  }
}

void showErrorSnackbar(String error) {
  if (navigatorKey.currentContext != null) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).removeCurrentSnackBar();
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(errorSnackbar(error));
  }
}

void showSuccessSnackbar(String text) {
  if (navigatorKey.currentContext != null) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).removeCurrentSnackBar();
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(successSnackbar(text));
  }
}

String parseError(Object? err, [StackTrace? stackTrace]) {
  String message = 'Произошла ошибка';
  if (err is CustomException) {
    message = err.message;
  }
  if (err is DioException) {
    message = err.response?.data['error'] ?? message;
  }
  if (kDebugMode) {
    message += '\n\nDEBUG ONLY: $err\n$stackTrace';
  }
  return message;
}

List<T> parseJsonList<T, K>(List<K> json, T Function(K json) fromJson) {
  final list = <T>[];
  for (final item in json) {
    try {
      list.add(fromJson(item));
    } catch (e, st) {
      logger.error('Error parsing item', e, st);
    }
  }
  return list;
}

Future<Result<T>> tryCatch<T>(Future<T> Function() fn) async {
  try {
    return Result.ok(await fn());
  } catch (e, st) {
    logger.error('Error in tryCatch', e, st);
    return Result.err(e, st);
  }
}
