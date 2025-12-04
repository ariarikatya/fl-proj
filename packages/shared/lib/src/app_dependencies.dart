import 'package:dio/dio.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared/src/crashlytics/analytics_service.dart';
import 'package:shared/src/crashlytics/crashlytics_service.dart';

late AppDependencies dependencies;

abstract class AppDependencies {
  Future<void> initAuth();

  Future<void> initCrashlyticsAndAnalytics();

  Future<void> initFormatting() async {
    await initializeDateFormatting('ru', null);
  }

  Future<void> initNotifications();

  Future<void> requestNotificationPermissions();

  late final CrashlyticsService crashlytics;
  late final AnalyticsService analytics;
  late final Dio dio;
}
