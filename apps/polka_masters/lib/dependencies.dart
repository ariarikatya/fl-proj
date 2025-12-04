import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:polka_masters/background_messaging.dart';
import 'package:polka_masters/features/calendar/data/bookings_repo.dart';
import 'package:polka_masters/features/contacts/data/contacts_repo.dart';
import 'package:polka_masters/firebase_options.dart';
import 'package:polka_masters/repos/master_repository.dart';
import 'package:polka_masters/repos/online_booking_repository.dart';
import 'package:polka_masters/repos/schedules_repository.dart';
import 'package:shared/shared.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _wsUrl = 'wss://polka-bm.online:9922/api_v1/ws';

class Dependencies extends AppDependencies {
  Dependencies._();

  factory Dependencies() => _instance;

  static Future<void> init() async {
    _instance = Dependencies._();

    // For debugging released apps
    if (devMode) logger.info('[dev-mode] env values: ${Env.values}');

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await AppMetrica.activate(const AppMetricaConfig(Env.appMetricaApiKey));

    // Initialize Crashlytics
    await _instance.initCrashlyticsAndAnalytics();
    await _instance.initNotifications();

    _instance.dio = DioFactory.createDio();
    _instance.secureStorage = createSecureStorage();
    _instance.udid = await flutterUdid;

    await _instance._initRepositories();
    await _instance.initAuth();
    await _instance.initFormatting();

    _instance.analytics.reportEvent('Masters App initialized');
    _instance.analytics.sendEventsBuffer();
    dependencies = _instance;
  }

  @override
  Future<void> initAuth() async {
    final token = await secureStorage.read(key: 'token');
    final refreshToken = await secureStorage.read(key: 'refreshToken');
    final phoneNumber = await secureStorage.read(key: 'phoneNumber');
    final data = token != null && refreshToken != null && phoneNumber != null
        ? ((accessToken: token, refreshToken: refreshToken), phoneNumber)
        : null;

    if (devMode) logger.info('[local credentials] $data');

    authController = await AuthController.init<Master>(
      data,
      udid,
      authRepository,
      analytics,
      secureStorage,
      onStateChanged: (prev, state) {
        logger.debug('[auth controller] state changed: ${prev.runtimeType} -> ${state.runtimeType}');
        if (prev is! AuthStateAuthenticated && state is AuthStateAuthenticated) {
          onLoggedIn((state as AuthStateAuthenticated<Master>).user.value);
        } else if (prev is AuthStateAuthenticated && state is! AuthStateAuthenticated) {
          onLoggedOut();
        }
      },
    );

    dio.interceptors.add(
      AuthInterceptor(
        getAccessToken: authController.getAccessToken,
        refreshTokens: authController.refreshTokens,
        dio: DioFactory.createDio(),
      ),
    );
    webSocketService = WebSocketService$IOImpl(url: _wsUrl, getToken: () => authController.getAccessToken());

    if (authController.value case AuthStateAuthenticated<Master> state) {
      onLoggedIn(state.user.value);
    }
  }

  @override
  Future<void> initCrashlyticsAndAnalytics() async {
    if (Platform.isAndroid || Platform.isIOS) {
      crashlytics = Crashlytics$AppMetricaImpl()..init();
      analytics = Analytics$AppMetricaImpl()..init();
    } else {
      crashlytics = Crashlytics$LoggerImpl()..init();
      analytics = Analytics$LoggerImpl()..init();
    }
    errorReporter = crashlytics.reportError;
  }

  Future<void> _initRepositories() async {
    authRepository = RestAuthRepository(dio);
    profileRepository = RestProfileRepository(dio);
    masterRepository = RestMasterRepository(dio);
    bookingsRepository = RestBookingsRepository(dio);
    chatsRepo = RestChatsRepository(dio);
    contactsRepo = RestContactsRepository(dio);
    schedulesRepo = RestSchedulesRepository(dio);
    onlineBookingRepo = RestOnlineBookingRepository(dio);
  }

  @override
  Future<void> initNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.info('Handling a foreground message: ${message.messageId}');
    });
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> registerFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    logger.info('FCM Token on login=$token');
    if (token != null) {
      profileRepository.uploadFcmToken(token, udid, defaultTargetPlatform.name);
    }
  }

  @override
  Future<void> requestNotificationPermissions() async {
    final messaging = FirebaseMessaging.instance;
    final result = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    logger.info('Notifications permission: ${result.authorizationStatus}');
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void onLoggedIn(Master master) async {
    webSocketService.connect();
    registerFcmToken();
  }

  void onLoggedOut() {
    webSocketService.disconnect();
  }

  static late Dependencies _instance;

  late final String udid;

  @override
  late final Dio dio;

  late final FlutterSecureStorage secureStorage;

  late final AuthController<Master> authController;

  late final WebSocketService webSocketService;

  @override
  late final CrashlyticsService crashlytics;
  @override
  late final AnalyticsService analytics;

  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final MasterRepository masterRepository;
  late final BookingsRepository bookingsRepository;
  late final ChatsRepository chatsRepo;
  late final ContactsRepository contactsRepo;
  late final SchedulesRepository schedulesRepo;
  late final OnlineBookingRepository onlineBookingRepo;
}
