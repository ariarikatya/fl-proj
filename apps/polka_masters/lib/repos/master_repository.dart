import 'package:shared/shared.dart';
import 'package:dio/dio.dart';

sealed class MasterRepository {
  Future<Result<Service>> createMasterService(Service service);
  Future<Result<Schedule>> createMasterSchedule(Schedule schedule);
  Future<Result<MasterInfo>> getMasterInfo(int id);

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
}
