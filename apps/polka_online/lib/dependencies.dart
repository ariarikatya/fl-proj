import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

class Dependencies {
  Dependencies._();

  static final Dependencies instance = Dependencies._();

  late final MasterRepository masterRepository;
  late final Dio dio;

  void init() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://mock.polka.test/api', // Моковый URL для тестирования
      contentType: 'application/json',
    ));

    masterRepository = MockMasterRepository(); // Используем мок для тестирования
  }
}

class MasterRepository {
  Future<Result<MasterInfo>> getMasterInfo(int masterId) async {
    throw UnimplementedError();
  }
}

// Мок репозитория для тестирования
class MockMasterRepository extends MasterRepository {
  @override
  Future<Result<MasterInfo>> getMasterInfo(int masterId) async {
    // Имитируем задержку сети
    await Future.delayed(const Duration(seconds: 1));
    
    // Возвращаем тестовые данные
    final master = Master(
      id: masterId,
      firstName: 'Мария',
      lastName: 'Абрамова',
      profession: 'Стилист по волосам',
      city: 'Москва',
      experience: '6 лет',
      about: 'Профессиональный стилист с опытом работы более 6 лет',
      address: 'ул. Примерная, д. 1',
      avatarUrl: '', // Пустая строка - будет использоваться локальная картинка
      portfolio: const [],
      workplace: const [],
      categories: const [],
      rating: 4.9,
      reviewsCount: 134,
      latitude: 55.7558,
      longitude: 37.6173,
    );

    final schedule = Schedule(
      periodStart: DateTime.now(),
      periodEnd: DateTime.now().add(const Duration(days: 30)),
      days: const {}, // Пустая карта для WeekDays
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