import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:shared/src/logger.dart';

sealed class AnalyticsService {
  AnalyticsService._();

  static AnalyticsService? _instance;

  static AnalyticsService get _$instance {
    if (_instance == null) {
      throw StateError('AnalyticsService not initialized. Call init() first.');
    }
    return _instance!;
  }

  factory AnalyticsService() => _$instance;
  Future<void> init();

  Future<void> reportEvent(String eventName, {Map<String, Object?>? params});

  Future<void> setUserProfileId(String userId);

  Future<void> reportUserProfile(Map<String, Object?> attributes);

  Future<void> sendEventsBuffer();
}

final class Analytics$AppMetricaImpl extends AnalyticsService {
  Analytics$AppMetricaImpl() : super._();

  @override
  Future<void> init() async {
    AnalyticsService._instance = this;
    logger.info('AppMetrica analytics initialized');
  }

  @override
  Future<void> reportEvent(String eventName, {Map<String, Object?>? params}) => AppMetrica.reportEvent(eventName);

  @override
  Future<void> setUserProfileId(String userId) {
    return AppMetrica.setUserProfileID(userId);
  }

  @override
  Future<void> reportUserProfile(Map<String, Object?> attributes) {
    final $attributes = <AppMetricaStringAttribute>[];
    for (final MapEntry(:key, :value) in attributes.entries) {
      $attributes.add(AppMetricaStringAttribute.withValue(key, value.toString()));
    }
    return AppMetrica.reportUserProfile(AppMetricaUserProfile($attributes));
  }

  @override
  Future<void> sendEventsBuffer() => AppMetrica.sendEventsBuffer();
}

final class Analytics$LoggerImpl extends AnalyticsService {
  Analytics$LoggerImpl() : super._();

  @override
  Future<void> init() async {
    logger.info('Analytics\$LoggerImpl initialized');
  }

  @override
  Future<void> reportEvent(String eventName, {Map<String, Object?>? params}) async {
    logger.info('Analytics\$LoggerImpl report event: $eventName${params != null ? ', params: $params' : ''}');
  }

  @override
  Future<void> setUserProfileId(String userId) async {
    logger.info('Analytics\$LoggerImpl set user_profile_id: $userId');
  }

  @override
  Future<void> reportUserProfile(Map<String, Object?> attributes) async {
    logger.info('Analytics\$LoggerImpl report user profile: $attributes');
  }

  @override
  Future<void> sendEventsBuffer() async => logger.info('Analytics\$LoggerImpl *sent events buffer*');
}
