import 'dart:developer';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';

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

  Future<void> reportEvent(String eventName);
}

final class Crashlytics$AppMetricaImpl extends CrashlyticsService {
  Crashlytics$AppMetricaImpl({required this.apiKey}) : super._();

  final String apiKey;

  @override
  Future<void> init() async {
    await AppMetrica.activate(AppMetricaConfig(apiKey));
    CrashlyticsService._instance = this;
  }

  @override
  Future<void> reportError(Object? err, [StackTrace? stackTrace]) => AppMetrica.reportError(
    message: err.toString(),
    errorDescription: stackTrace != null ? AppMetricaErrorDescription(stackTrace, type: 'Unhandled Exception') : null,
  );

  @override
  Future<void> reportEvent(String eventName) => AppMetrica.reportEvent(eventName);
}

final class Crashlytics$LoggerImpl extends CrashlyticsService {
  Crashlytics$LoggerImpl() : super._();

  @override
  Future<void> init() async {
    log('log crashlytics initialized');
  }

  @override
  Future<void> reportError(Object? err, [StackTrace? stackTrace]) async {
    log('log crashlytics caught error: $err\n$stackTrace');
  }

  @override
  Future<void> reportEvent(String eventName) async {
    log('log crashlytics report event: $eventName');
  }
}
