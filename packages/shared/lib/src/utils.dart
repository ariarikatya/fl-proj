import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

Future<String> get flutterUdid {
  if (Platform.isAndroid || Platform.isIOS) {
    return FlutterUdid.udid;
  } else {
    return Future.value('mock-udid');
  }
}

Future<bool> launchUrl(Uri url) async {
  logger.info('launching url: $url');
  try {
    await url_launcher.launchUrl(url);
    return true;
  } catch (e, st) {
    handleError(e, st);
    return false;
  }
}

bool get devMode => kDebugMode || Env.devMode;

// Function for reporting errors elsewhere
void Function(Object? err, StackTrace? trace)? errorHandler;

Null handleError(Object? err, [StackTrace? stackTrace, bool showSnackbar = true]) {
  logger.error('Error caught in handleError', err, stackTrace);
  errorHandler?.call(err, stackTrace);

  if (showSnackbar || devMode) {
    String message = '${!showSnackbar && devMode ? '[DEV MODE ONLY] ' : ''}${parseError(err, stackTrace)}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showErrorSnackbar(message);
    });
  }
}

String parseError(Object? err, [StackTrace? stackTrace]) {
  String message = 'Произошла ошибка';
  if (err is CustomException) {
    message = err.message;
  }
  if (err is DioException) {
    if (err.response?.data case <String, Object?>{'error': String error}) {
      message = error;
    } else {
      // Maybe not the best way to show errors to users but okay for now
      message = err.response?.data.toString() ?? message;
    }
  }
  if (devMode) {
    message += '\n\n[DEV MODE]: ${[err, ?stackTrace].join('\n')}';
  }
  return message;
}

List<T> parseJsonList<T, K>(List<K> json, T Function(K json) fromJson, [bool throwOnError = false]) {
  final list = <T>[];
  for (final item in json) {
    try {
      list.add(fromJson(item));
    } catch (e, st) {
      logger.error('Error parsing item', e, st);
      if (throwOnError) rethrow;
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

void showErrorSnackbar(String error) => showSnackbar(errorSnackbar(error));

void showSuccessSnackbar(String text) => showSnackbar(successSnackbar(text));

void showInfoSnackbar(String text) => showSnackbar(infoSnackbar(AppText(text)));

void showSnackbar(SnackBar snackbar) {
  if (navigatorKey.currentContext != null) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).removeCurrentSnackBar();
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(snackbar);
  }
}
