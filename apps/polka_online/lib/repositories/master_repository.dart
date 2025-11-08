import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

abstract class MasterRepository {
  Future<Result<MasterInfo>> getMasterInfo(int masterId);
}

class RestMasterRepository extends MasterRepository {
  RestMasterRepository(this.dio);
  final Dio dio;

  @override
  Future<Result<MasterInfo>> getMasterInfo(int masterId) => tryCatch(() async {
    final response = await dio.get('/masters/$masterId');
    return MasterInfo.fromJson(response.data);
  });
}

// Моковая версия
class MockMasterRepository extends MasterRepository {
  @override
  Future<Result<MasterInfo>> getMasterInfo(int masterId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final master = Master(
      id: masterId,
      firstName: 'Мария',
      lastName: 'Абрамова',
      profession: 'Стилист по волосам',
      city: 'Екатеринбург',
      experience: '6 лет',
      about: 'Профессионалка.',
      address: 'ул. Тверская, 10',
      avatarUrl: '',
      portfolio: const [],
      workplace: const [],
      categories: const [],
      rating: 4.9,
      reviewsCount: 58,
      latitude: 55.7558,
      longitude: 37.6173,
      json: const {},
    );

    final mockServices = [
      Service(
        id: 1,
        category: ServiceCategories.nailService,
        title: 'Маникюр классический',
        duration: const Duration(minutes: 60),
        description: '',
        location: ServiceLocation.studio,
        resultPhotos: [],
        price: 1200,
      ),
      Service(
        id: 2,
        category: ServiceCategories.nailService,
        title: 'Педикюр Spa',
        duration: const Duration(minutes: 90),
        description: '',
        location: ServiceLocation.studio,
        resultPhotos: [],
        price: 2000,
      ),
    ];

    final schedule = Schedule(
      periodStart: DateTime.now(),
      periodEnd: DateTime.now().add(const Duration(days: 30)),
      days: const {},
    );

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
