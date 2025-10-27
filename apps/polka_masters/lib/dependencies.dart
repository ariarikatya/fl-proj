import 'dart:io';

import 'package:polka_masters/blocs_provider.dart';
import 'package:polka_masters/features/calendar/data/bookings_repo.dart';
import 'package:polka_masters/features/contacts/data/contacts_repo.dart';
import 'package:polka_masters/repos/master_repository.dart';
import 'package:shared/shared.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';

const _wsUrl = 'wss://polka-bm.online:9922/api_v1/ws';

class Dependencies {
  Dependencies._();

  factory Dependencies() => _instance;

  static Future<void> init() async {
    _instance = Dependencies._();

    // For debugging released apps
    if (devMode) logger.info('[dev-mode] env values: ${Env.values}');

    // Initialize Crashlytics
    if (Platform.isAndroid || Platform.isIOS) {
      _instance.crashlyticsService = Crashlytics$AppMetricaImpl(apiKey: Env.appMetricaApiKey);
    } else {
      _instance.crashlyticsService = Crashlytics$LoggerImpl();
    }
    await _instance.crashlyticsService.init();
    errorHandler = _instance.crashlyticsService.reportError;

    _instance.dio = DioFactory.createDio();
    _instance.secureStorage = createSecureStorage();
    _instance.udid = await flutterUdid;

    await _instance._initRepositories();

    blocs = MasterBlocsProvider();
    await _instance._initAuth();
    await _instance._initWebSocket();

    await initializeFormatting();

    await _instance.crashlyticsService.reportEvent('Masters App initialized');
    if (_instance.crashlyticsService is Crashlytics$AppMetricaImpl) AppMetrica.sendEventsBuffer();
  }

  Future<void> _initAuth() async {
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
      secureStorage,
      onStateChanged: (prev, state) {
        logger.debug('[auth controller] state changed: ${prev.runtimeType} -> ${state.runtimeType}');
        if (prev is! AuthStateAuthenticated && state is AuthStateAuthenticated) {
          webSocketService.connect();
        } else if (prev is AuthStateAuthenticated && state is! AuthStateAuthenticated) {
          webSocketService.disconnect();
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
  }

  Future<void> _initWebSocket() async {
    webSocketService = WebSocketService$IOImpl(url: _wsUrl, getToken: authController.getAccessToken);
    if (authController.value case AuthStateAuthenticated()) {
      webSocketService.connect();
    }
  }

  Future<void> _initRepositories() async {
    authRepository = RestAuthRepository(dio);
    profileRepository = RestProfileRepository(dio);
    masterRepository = RestMasterRepository(dio);
    bookingsRepository = RestBookingsRepository(dio);
    chatsRepo = RestChatsRepository(dio);
    contactsRepo = RestContactsRepository(dio);
  }

  static late Dependencies _instance;

  late final String udid;

  late final Dio dio;

  late final FlutterSecureStorage secureStorage;

  late final AuthController<Master> authController;

  late final WebSocketService webSocketService;

  late final CrashlyticsService crashlyticsService;

  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final MasterRepository masterRepository;
  late final BookingsRepository bookingsRepository;
  late final ChatsRepository chatsRepo;
  late final ContactsRepository contactsRepo;
}
