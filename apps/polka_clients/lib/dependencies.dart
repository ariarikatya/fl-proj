import 'dart:async';

import 'package:polka_clients/features/booking/data/bookings_repo.dart';
import 'package:polka_clients/features/favorites/data/favorites_repo.dart';
import 'package:polka_clients/features/map_search/data/map_repo.dart';
import 'package:shared/shared.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:polka_clients/blocs_provider.dart';
import 'package:polka_clients/repositories/client_repository.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';

const _wsUrl = 'wss://polka-bm.online:9922/api_v1/ws';

class Dependencies {
  Dependencies._();

  factory Dependencies() => _instance;

  static Future<void> init() async {
    _instance = Dependencies._();

    // For debugging released apps
    if (devMode) logger.info('[dev-mode] env values: ${Env.values}');

    // Initialize AppMetrica
    await AppMetrica.activate(AppMetricaConfig(Env.appMetricaApiKey));

    _instance.dio = DioFactory.createDio();
    _instance.secureStorage = createSecureStorage();
    _instance.udid = await flutterUdid;

    await _instance._initRepositories();

    _instance.mapkitInit = Completer()
      ..future.whenComplete(() => logger.info('[mapkit] mapkit initialization completed'));

    blocs = ClientBlocsProvider();
    await _instance._initAuth();
    await _instance._initWebSocket();

    await initializeFormatting();

    await AppMetrica.reportEvent('App initialized');
    AppMetrica.sendEventsBuffer();
  }

  Future<void> _initAuth() async {
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
    clientRepository = RestClientRepository(dio);
    bookingsRepo = RestBookingsRepository(dio);
    favoritesRepo = RestFavoritesRepository(dio);
    chatsRepo = RestChatsRepository(dio);
    mapRepo = RestMapRepository(dio);
  }

  static late Dependencies _instance;

  late final String udid;

  late final Dio dio;
  late final FlutterSecureStorage secureStorage;

  late final AuthController<Client> authController;

  late final WebSocketService webSocketService;

  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final ClientRepository clientRepository;
  late final BookingsRepository bookingsRepo;
  late final FavoritesRepository favoritesRepo;
  late final ChatsRepository chatsRepo;
  late final MapRepository mapRepo;

  late final Completer mapkitInit;
}
