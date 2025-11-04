import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

// Флаг для переключения между моком и реальным API
const bool useMockData = true;

class Dependencies {
  Dependencies._();

  static final Dependencies instance = Dependencies._();

  late final MasterRepository masterRepository;
  late final AuthRepository authRepository;
  late final Dio dio;

  void init() {
    if (useMockData) {
      // Для разработки: используем моковый Dio с интерцептором
      dio = _createMockDio();
      masterRepository = MockMasterRepository();
      authRepository = RestAuthRepository(dio);
    } else {
      // Для продакшена: используем реальный API
      dio = Dio(
        BaseOptions(
          baseUrl: 'https://polka-bm.online/api_v1',
          contentType: 'application/json',
        ),
      );
      masterRepository = RestMasterRepository(dio);
      authRepository = RestAuthRepository(dio);
    }
  }

  // Создаем Dio с моковым интерцептором
  Dio _createMockDio() {
    final mockDio = Dio(
      BaseOptions(baseUrl: 'https://mock.api', contentType: 'application/json'),
    );

    // Добавляем интерцептор для мока
    mockDio.interceptors.add(MockApiInterceptor());

    return mockDio;
  }
}

// ============================================================
// 🔹 Моковый интерцептор для имитации API
// ============================================================
class MockApiInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    logger.info('[Mock API] ${options.method} ${options.path}');

    // Имитируем задержку сети
    await Future.delayed(const Duration(milliseconds: 500));

    // Отправка кода
    if (options.path.contains('/auth/send-code')) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true},
        ),
      );
      return;
    }

    // Проверка кода
    if (options.path.contains('/auth/verify-code')) {
      final code = options.data['code'] as String?;

      // Принимаем любой 4-значный код
      if (code != null && code.length == 4) {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'phone_number': options.data['phone_number'],
              'access_token':
                  'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
              'refresh_token':
                  'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
              'account': {
                'id': 1,
                'first_name': 'Тест',
                'last_name': 'Пользователь',
                'phone_number': options.data['phone_number'],
              },
            },
          ),
        );
      } else {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 400,
              data: {'error': 'Неверный код'},
            ),
          ),
        );
      }
      return;
    }

    // Если маршрут не найден
    handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 404,
          data: {'error': 'Mock endpoint not found'},
        ),
      ),
    );
  }
}

// ============================================================
// 🔹 Абстрактный репозиторий мастеров
// ============================================================
abstract class MasterRepository {
  Future<Result<MasterInfo>> getMasterInfo(int masterId);
}

// ============================================================
// 🔹 Моковая реализация репозитория мастеров
// ============================================================
class MockMasterRepository extends MasterRepository {
  @override
  Future<Result<MasterInfo>> getMasterInfo(int masterId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final master = Master(
      id: masterId,
      firstName: 'Алла',
      lastName: 'Светлова',
      profession: 'Визажист',
      city: 'Москва',
      experience: '5 лет',
      about: 'Профессиональный визажист. Работаю с макияжем любой сложности.',
      address: 'ул. Тверская, 10',
      avatarUrl: 'assets/images/master_photo.png',
      portfolio: const [],
      workplace: const [],
      categories: const [],
      rating: 4.9,
      reviewsCount: 58,
      latitude: 55.7558,
      longitude: 37.6173,
      json: const {},
    );

    final schedule = Schedule(
      periodStart: DateTime.now(),
      periodEnd: DateTime.now().add(const Duration(days: 30)),
      days: const {},
    );

    final masterInfo = MasterInfo(
      master: master,
      services: const [],
      schedule: schedule,
      reviews: const [],
      json: const {},
    );

    return Result.ok(masterInfo);
  }
}

// ============================================================
// 🔹 REST реализация репозитория мастеров (для продакшена)
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
