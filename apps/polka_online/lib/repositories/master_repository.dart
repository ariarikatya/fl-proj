import 'package:shared/shared.dart';

abstract class MasterRepository {
  Future<Result<MasterInfo>> getMasterInfo(int masterId);
}

// Мок репозитория для тестирования
class MockMasterRepository implements MasterRepository {
  @override
  Future<Result<MasterInfo>> getMasterInfo(int masterId) async {
    // задержка сети
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
