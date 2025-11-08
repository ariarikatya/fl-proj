import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

const bool useMockData = false;

class Dependencies {
  Dependencies._();

  static final Dependencies instance = Dependencies._();

  late final MasterRepository masterRepository;
  late final AuthRepository authRepository;
  late final ProfileRepository profileRepository;
  late final Dio dio;

  void init() {
    if (useMockData) {
      logger.info(
        '[Dependencies] 🎭 Using MOCK data (set useMockData = false to use real API)',
      );
      dio = _createMockDio();
      masterRepository = MockMasterRepository();
      authRepository = RestAuthRepository(dio);
      profileRepository = RestProfileRepository(dio);
    } else {
      logger.info('[Dependencies] 🌐 Using REAL API');
      dio = DioFactory.createDio();
      masterRepository = RestMasterRepository(dio);
      authRepository = RestAuthRepository(dio);
      profileRepository = RestProfileRepository(dio);
    }
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

  Dio _createMockDio() {
    final mockDio = Dio(
      BaseOptions(baseUrl: 'https://mock.api', contentType: 'application/json'),
    );
    mockDio.interceptors.add(_MockApiInterceptor());
    return mockDio;
  }
}

class RestMasterRepository extends MasterRepository {
  RestMasterRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<MasterInfo>> getMasterInfo(int masterId) => tryCatch(() async {
    logger.debug('[MasterRepository] Fetching master info for id: $masterId');

    final response = await dio.get('/masters/$masterId');

    logger.debug('[MasterRepository] Response status: ${response.statusCode}');

    final masterInfo = MasterInfo.fromJson(response.data);

    logger.info(
      '[MasterRepository] Successfully loaded master: ${masterInfo.master.fullName}',
    );

    return masterInfo;
  });
}

abstract class MasterRepository {
  Future<Result<MasterInfo>> getMasterInfo(int masterId);
}

class _MockApiInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    logger.info('[Mock API] ${options.method} ${options.path}');

    await Future.delayed(const Duration(milliseconds: 300));

    if (options.path.contains('/send_code')) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'message': 'Код отправлен'},
        ),
      );
      return;
    }

    if (options.path.contains('/auth/verify_code')) {
      final code = options.data['code'] as String?;
      if (code != null && code.length == 4) {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'phone': options.data['phone'],
              'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
              'refresh_token':
                  'mock_refresh_${DateTime.now().millisecondsSinceEpoch}',
              'client_profile': {
                'id': 1,
                'first_name': 'Тест',
                'last_name': 'Пользователь',
                'city': 'Москва',
                'preferred_services': [],
                'avatar_url': '',
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

class MockMasterRepository extends MasterRepository {
  @override
  Future<Result<MasterInfo>> getMasterInfo(int masterId) async {
    logger.info(
      '[MockMasterRepository] Loading mock data for master $masterId',
    );

    await Future.delayed(const Duration(milliseconds: 500));

    final master = Master(
      id: masterId,
      firstName: 'Мария',
      lastName: 'Абрамова',
      profession: 'Стилист по волосам',
      city: 'Екатеринбург',
      experience: '6 лет',
      about: 'Профессиональный стилист с большим опытом работы',
      address: 'ул. Ленина, 50',
      avatarUrl: 'https://i.pravatar.cc/300?img=47',
      portfolio: const [],
      workplace: const [],
      categories: const [ServiceCategories.hairStyling],
      rating: 4.9,
      reviewsCount: 58,
      latitude: 56.838011,
      longitude: 60.597474,
      json: const {},
    );

    final mockServices = [
      Service(
        id: 1,
        category: ServiceCategories.hairStyling,
        title: 'Стрижка женская',
        duration: const Duration(minutes: 60),
        description: 'Профессиональная женская стрижка',
        location: ServiceLocation.studio,
        resultPhotos: [],
        price: 1500,
      ),
      Service(
        id: 2,
        category: ServiceCategories.hairStyling,
        title: 'Окрашивание',
        duration: const Duration(minutes: 120),
        description: 'Окрашивание волос',
        location: ServiceLocation.studio,
        resultPhotos: [],
        price: 3500,
      ),
    ];

    final schedule = Schedule(
      periodStart: DateTime.now(),
      periodEnd: DateTime.now().add(const Duration(days: 30)),
      days: const {},
    );

    logger.info('[MockMasterRepository] Mock data loaded successfully');

    return Result.ok(
      MasterInfo(
        master: master,
        services: mockServices,
        schedule: schedule,
        reviews: const [],
        json: const {},
      ),
    );
  }
}
