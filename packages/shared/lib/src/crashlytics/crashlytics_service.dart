import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:shared/src/logger.dart';

sealed class CrashlyticsService {
  CrashlyticsService._();

  static CrashlyticsService? _instance;

  static CrashlyticsService get _$instance {
    if (_instance == null) {
      throw StateError('CrashlyticsService not initialized. Call init() first.');
    }
    return _instance!;
  }

  factory CrashlyticsService() => _$instance;
  Future<void> init();

  Future<void> reportError(Object? err, [StackTrace? stackTrace]);
}

final class Crashlytics$AppMetricaImpl extends CrashlyticsService {
  Crashlytics$AppMetricaImpl() : super._();

  @override
  Future<void> init() async {
    CrashlyticsService._instance = this;
    FlutterError.onError = (FlutterErrorDetails details) {
      reportError(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      reportError(error, stack);
      return true;
    };
    logger.info('AppMetrica crashlytics initialized');
  }

  @override
  Future<void> reportError(Object? err, [StackTrace? stackTrace]) => AppMetrica.reportError(
    message: err.toString(),
    errorDescription: stackTrace != null ? AppMetricaErrorDescription(stackTrace, type: 'Unhandled Exception') : null,
  );
}

final class Crashlytics$LoggerImpl extends CrashlyticsService {
  Crashlytics$LoggerImpl() : super._();

  @override
  Future<void> init() async {
    logger.info('log crashlytics initialized');
  }

  @override
  Future<void> reportError(Object? err, [StackTrace? stackTrace]) async {
    logger.info('log crashlytics caught error: $err\n$stackTrace');
  }
}
