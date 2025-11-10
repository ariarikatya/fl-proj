import 'package:shared/shared.dart';
import 'package:dio/dio.dart';

sealed class MasterRepository {
  Future<Result<Service>> createMasterService(Service service);
  Future<Result<Schedule>> createMasterSchedule(Schedule schedule);
  Future<Result<bool>> updateMaster(Master master);

  Future<Result<MasterInfo>> getMasterInfo(int id);
  Future<Result<OnlineBookingConfig>> getMasterLink(int id);

  Future<Result<String>> getClientPhone(int clientId);

  /// Takes a list of filepaths for photos
  Future<Result<List<String>>> uploadPortfolioPhotos(Iterable<String> photos);
}

class RestMasterRepository extends MasterRepository {
  RestMasterRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<Service>> createMasterService(Service service) async {
    try {
      await dio.post('/master_service', data: service.toJson());
      return Result.ok(service);
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

  @override
  Future<Result<Schedule>> createMasterSchedule(Schedule schedule) async {
    try {
      await dio.post(
        '/schedules',
        data: schedule.toJson()
          ..['slot_interval_min'] = 30
          ..['auto_generate_slots'] = true,
      );
      return Result.ok(schedule);
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

  @override
  Future<Result<List<String>>> uploadPortfolioPhotos(Iterable<String> photos) async {
    try {
      final formData = FormData.fromMap({'photos': photos.map((f) => MultipartFile.fromFileSync(f)).toList()});
      final result = await dio.post('/master/photos/portfolio', data: formData);
      return Result.ok((result.data['general_portfolio'] as List).cast<String>());
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

  @override
  Future<Result<MasterInfo>> getMasterInfo(int masterId) => tryCatch(() async {
    final response = await dio.get('/masters/$masterId');
    return MasterInfo.fromJson(response.data);
  });

  @override
  Future<Result<String>> getClientPhone(int clientId) async => tryCatch(() async {
    final response = await dio.get('/client-phone/$clientId');
    return response.data['phone_number'] as String;
  });

  @override
  Future<Result<OnlineBookingConfig>> getMasterLink(int id) {
    return Future.value(
      Result.ok(
        OnlineBookingConfig(
          masterLink: 'https://polka-bm.online?master_id=$id',
          publicMode: OnlineBookingPublicMode.private,
          nightMode: true,
        ),
      ),
    );
  }

  @override
  Future<Result<bool>> updateMaster(Master master) async => tryCatch(() async {
    final response = await dio.put('/master/profile', data: master.toJson()..remove('id'));
    return response.data['success'] == true;

    // return Master.fromJson(response.data['profile']); // Потому что поля блять живут своей жизнью на бэке х2
  });
}
