import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

class Dependencies {
  Dependencies._();

  static final Dependencies instance = Dependencies._();

  late final Dio dio;
  late final MasterRepository masterRepository;
  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final BookingsRepository bookingsRepository;
  TokensPair? _tokens;

  String? get accessToken => _tokens?.accessToken;

  void setTokens(TokensPair tokens) {
    _tokens = tokens;
    logger.info('[Dependencies] Tokens updated');
  }

  void init() {
    logger.info('[Dependencies] 🌐 Initializing API');
    dio = DioFactory.createDio();

    // Add auth interceptor
    dio.interceptors.add(
      AuthInterceptor(
        getAccessToken: () async => accessToken,
        refreshTokens: () async {
          if (_tokens?.refreshToken == null) return false;
          final result = await RestAuthRepository(
            dio,
          ).refreshTokens<Client>(_tokens!.refreshToken, 'web_polka_online');
          return result.when(
            ok: (newTokens) {
              setTokens(newTokens);
              return true;
            },
            err: (_, __) => false,
          );
        },
        dio: dio,
      ),
    );

    masterRepository = RestMasterRepository(dio);
    authRepository = RestAuthRepository(dio);
    profileRepository = RestProfileRepository(dio);
    bookingsRepository = RestBookingsRepository(dio);
  }

  /// Извлекает masterId из текущего URL
  static String? getMasterIdFromUrl() {
    final uri = Uri.base;

    logger.debug('[Dependencies] Current URL: $uri');
    logger.debug('[Dependencies] Path: ${uri.path}');
    logger.debug('[Dependencies] Query params: ${uri.queryParameters}');

    // Проверяю query: /?masterId=123
    if (uri.queryParameters.containsKey('masterId')) {
      final masterId = uri.queryParameters['masterId'];
      logger.info('[Dependencies] Found masterId in query: $masterId');
      return masterId;
    }

    // Проверяю: /masters/123
    final pathSegments = uri.pathSegments;
    if (pathSegments.length >= 2 && pathSegments[0] == 'masters') {
      final masterId = pathSegments[1];
      logger.info('[Dependencies] Found masterId in path: $masterId');
      return masterId;
    }

    logger.warning('[Dependencies] No masterId found in URL, using default: 1');
    return null;
  }
}

// Repository для работы с мастерами
abstract class MasterRepository {
  Future<Result<MasterInfo>> getMasterInfo(int masterId);
  Future<Result<List<AvailableSlot>>> getSlots(int masterId, int serviceId);
}

class RestMasterRepository extends MasterRepository {
  RestMasterRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<MasterInfo>> getMasterInfo(int masterId) => tryCatch(() async {
    logger.debug('[MasterRepository] Fetching master info for id: $masterId');

    final response = await dio.get('/masters/$masterId');

    logger.debug('[MasterRepository] Response status: ${response.statusCode}');
    logger.debug(
      '[MasterRepository] Response data keys: ${response.data.keys}',
    );

    final masterInfo = MasterInfo.fromJson(response.data);

    logger.info(
      '[MasterRepository] Successfully loaded master: ${masterInfo.master.fullName}',
    );
    logger.info(
      '[MasterRepository] Avatar URL: "${masterInfo.master.avatarUrl}"',
    );

    return masterInfo;
  });

  @override
  Future<Result<List<AvailableSlot>>> getSlots(
    int masterId,
    int serviceId,
  ) => tryCatch(() async {
    logger.debug(
      '[MasterRepository] Fetching slots for masterId: $masterId, serviceId: $serviceId',
    );

    final response = await dio.get(
      '/masters/$masterId/calendar',
      queryParameters: {
        'service_id': serviceId,
        'date_from': DateTime.now().toJson(),
        'date_to': DateTime.now().add(const Duration(days: 10)).toJson(),
      },
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }

    final slotsData = (response.data['slots'] as List)
        .cast<Map<String, dynamic>>();
    final slots = parseJsonList(slotsData, AvailableSlot.fromJson);

    logger.info('[MasterRepository] Successfully loaded ${slots.length} slots');

    return slots;
  });
}

// Repository для бронирований
abstract class BookingsRepository {
  Future<Result<int>> makeAppointment({
    required int masterId,
    required int serviceId,
    required int slotId,
    required String clientName,
    String? clientNotes,
  });
}

class RestBookingsRepository extends BookingsRepository {
  RestBookingsRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<int>> makeAppointment({
    required int masterId,
    required int serviceId,
    required int slotId,
    required String clientName,
    String? clientNotes,
  }) => tryCatch(() async {
    logger.info(
      '[BookingsRepository] Making appointment - masterId: $masterId, serviceId: $serviceId, slotId: $slotId, clientName: $clientName',
    );

    final response = await dio.post(
      '/appointments/from-slot',
      data: {
        'master_id': masterId,
        'service_id': serviceId,
        'slot_id': slotId,
        'client_name': clientName,
        'client_notes': clientNotes,
      },
    );

    final appointmentId = response.data['appointment']['id'] as int;
    logger.info(
      '[BookingsRepository] Appointment created successfully with id: $appointmentId',
    );

    return appointmentId;
  });
}
