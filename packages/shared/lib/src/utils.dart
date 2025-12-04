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

bool get devMode => devModeOverride ?? (kDebugMode || Env.devMode);
bool? devModeOverride;

// Function for reporting errors elsewhere (to CrashlyticsService or AppMetrica)
void Function(Object? err, StackTrace? trace)? errorReporter;

Null handleError(Object? err, [StackTrace? stackTrace, bool showSnackbar = true]) {
  logger.error('Error caught in handleError', err, stackTrace);
  errorReporter?.call(err, stackTrace);

  if (showSnackbar || devMode) {
    String message = '${!showSnackbar && devMode ? '[DEV MODE ONLY] ' : ''}${parseError(err, stackTrace)}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showErrorSnackbar(message);
    });
  }
}

String parseError(Object? err, [StackTrace? stackTrace]) {
  String message = 'Что-то пошло не так';
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
  WidgetsBinding.instance.scheduleForcedFrame();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (navigatorKey.currentContext != null && navigatorKey.currentContext!.mounted) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).removeCurrentSnackBar();
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(snackbar);
    }
  });
}

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void load(BuildContext context, Future future, {String? message}) {
    LoadingOverlay.show(context, message: message);
    future.whenComplete(() => LoadingOverlay.hide());
  }

  static void show(BuildContext context, {String? message}) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        body: Align(
          child: FittedBox(
            child: Container(
              width: 200,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.ext.colors.white[100],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  LoadingIndicator(),
                  if (message != null) AppText.headingSmall(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
