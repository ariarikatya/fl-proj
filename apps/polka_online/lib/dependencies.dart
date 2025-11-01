import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

class Dependencies {
  Dependencies._();

  static final Dependencies instance = Dependencies._();

  late final MasterRepository masterRepository;
  late final Dio dio;

  void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://mock.polka.test/api', // Моковый URL
        contentType: 'application/json',
      ),
    );

    // 🔸 Сейчас используем мок, потом можно легко заменить:
    // masterRepository = RestMasterRepository(dio);
    masterRepository = MockMasterRepository();
  }
}

// ============================================================
// 🔹 Абстрактный репозиторий
// ============================================================
abstract class MasterRepository {
  Future<Result<MasterInfo>> getMasterInfo(int masterId);
}

// ============================================================
// 🔹 Моковая реализация (без сервера, для теста WelcomePage)
// ============================================================
class MockMasterRepository extends MasterRepository {
  @override
  Future<Result<MasterInfo>> getMasterInfo(int masterId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // ----- Master -----
    final master = Master(
      id: masterId,
      firstName: 'Алла',
      lastName: 'Светлова',
      profession: 'Визажист',
      city: 'Москва',
      experience: '5 лет',
      about:
          'Профессиональный визажист. Работаю с макияжем любой сложности. Люблю делать людей красивыми 😊',
      address: 'ул. Тверская, 10',
      avatarUrl: 'assets/images/master_photo.png',
      portfolio: const [],
      workplace: const [],
      categories: const [], // пусто, потому что ServiceCategories — enum
      rating: 4.9,
      reviewsCount: 58,
      latitude: 55.7558,
      longitude: 37.6173,
      json: const {},
    );

    // ----- Schedule -----
    final schedule = Schedule(
      periodStart: DateTime.now(),
      periodEnd: DateTime.now().add(const Duration(days: 30)),
      days: const {}, // пустая карта для WeekDays
    );

    // ----- MasterInfo -----
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
// 🔹 Когда появится реальный сервер — просто замени строку в init()
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
