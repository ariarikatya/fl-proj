import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

class Dependencies {
  Dependencies._();

  static final Dependencies instance = Dependencies._();

  late final MasterRepository masterRepository;
  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final Dio dio;

  void init() {
    // Создаём Dio через DioFactory из shared - точно как в polka_clients
    dio = DioFactory.createDio();

    // Инициализируем репозитории - точно как в polka_clients
    masterRepository = RestMasterRepository(dio);
    authRepository = RestAuthRepository(dio);
    profileRepository = RestProfileRepository(dio);

    logger.info('[Dependencies] Initialized');
  }

  /// Извлекает masterId из текущего URL
  /// Поддерживает форматы:
  /// - /masters/:masterId
  /// - /?masterId=123
  static String? getMasterIdFromUrl() {
    final uri = Uri.base;

    logger.debug('[Dependencies] Current URL: $uri');
    logger.debug('[Dependencies] Path: ${uri.path}');
    logger.debug('[Dependencies] Query params: ${uri.queryParameters}');

    // Проверяем query параметры: /?masterId=123
    if (uri.queryParameters.containsKey('masterId')) {
      final masterId = uri.queryParameters['masterId'];
      logger.info('[Dependencies] Found masterId in query: $masterId');
      return masterId;
    }

    // Проверяем путь: /masters/123
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

// ============================================================
// 🔹 Репозиторий мастеров (REST API) - точно как в polka_clients
// ============================================================
class RestMasterRepository extends MasterRepository {
  RestMasterRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<MasterInfo>> getMasterInfo(int masterId) => tryCatch(() async {
    final response = await dio.get('/masters/$masterId');
    return MasterInfo.fromJson(response.data);
  });
}

// ============================================================
// 🔹 Абстрактный репозиторий
// ============================================================
abstract class MasterRepository {
  Future<Result<MasterInfo>> getMasterInfo(int masterId);
}
