import 'dart:async';
import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:polka_clients/background_messaging.dart';
import 'package:polka_clients/features/booking/data/bookings_repo.dart';
import 'package:polka_clients/features/favorites/data/favorites_repo.dart';
import 'package:polka_clients/features/map_search/data/map_repo.dart';
import 'package:shared/shared.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:polka_clients/repositories/client_repository.dart';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:polka_clients/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

    // Initialize Crashlytics and Analytics
    await _instance.initCrashlyticsAndAnalytics();
    await _instance.initNotifications();

    _instance.dio = DioFactory.createDio();
    _instance.secureStorage = createSecureStorage();
    _instance.udid = await flutterUdid;

    await _instance._initRepositories();

    if (Platform.isAndroid || Platform.isIOS) {
      _instance.mapkitInit = Completer()
        ..future.whenComplete(() => logger.info('[mapkit] mapkit initialization completed'));
    } else {
      _instance.mapkitInit = Completer()..complete();
    }

    await _instance.initAuth();
    await _instance.initFormatting();

    await _instance.analytics.reportEvent('Clients App initialized');
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

    authController = await AuthController.init<Client>(
      data,
      udid,
      authRepository,
      analytics,
      secureStorage,
      onStateChanged: (prev, state) {
        logger.debug('[auth controller] state changed: ${prev.runtimeType} -> ${state.runtimeType}');
        if (prev is! AuthStateAuthenticated && state is AuthStateAuthenticated) {
          onLoggedIn((state as AuthStateAuthenticated<Client>).user.value);
        } else if (prev is AuthStateAuthenticated && state is! AuthStateAuthenticated) {
          onLoggedOut();
        }
      },
    );

    dio.interceptors.add(
      AuthInterceptor(
        getAccessToken: () => authController.getAccessToken(),
        refreshTokens: () => authController.refreshTokens(),
        dio: DioFactory.createDio(),
      ),
    );
    webSocketService = WebSocketService$IOImpl(url: _wsUrl, getToken: () => authController.getAccessToken());

    if (authController.value case AuthStateAuthenticated<Client> state) {
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
    clientRepository = RestClientRepository(dio);
    bookingsRepo = RestBookingsRepository(dio);
    favoritesRepo = RestFavoritesRepository(dio);
    chatsRepo = RestChatsRepository(dio);
    mapRepo = RestMapRepository(dio);
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

  void onLoggedIn(Client client) async {
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

  late final AuthController<Client> authController;

  late final WebSocketService webSocketService;

  @override
  late final CrashlyticsService crashlytics;
  @override
  late final AnalyticsService analytics;

  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final ClientRepository clientRepository;
  late final BookingsRepository bookingsRepo;
  late final FavoritesRepository favoritesRepo;
  late final ChatsRepository chatsRepo;
  late final MapRepository mapRepo;

  late final Completer mapkitInit;
}
