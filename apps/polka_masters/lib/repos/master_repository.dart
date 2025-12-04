import 'package:shared/shared.dart';
import 'package:dio/dio.dart';

sealed class MasterRepository {
  Future<Result<Service>> createService(Service service);
  Future<Result<bool>> deleteService(int serviceId);
  Future<Result<Service>> updateService(Service service);
  Future<Result<bool>> setServiceVisibility(int serviceId, bool visible);

  /// Returns Map where values are [bool] service_enabled
  Future<Result<Map<Service, bool>>> getServices();

  Future<Result<bool>> updateMaster(Master master);
  Future<Result<MasterInfo>> getMasterInfo(int id);

  Future<Result<String>> getClientPhone(int clientId);

  /// Takes a list of filepaths for photos
  Future<Result<List<String>>> uploadPortfolioPhotos(Iterable<String> photos);
}

final class RestMasterRepository extends MasterRepository {
  RestMasterRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<Service>> createService(Service service) async {
    try {
      await dio.post('/master_service', data: service.toJson());
      return Result.ok(service);
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
  Future<Result<String>> getClientPhone(int clientId) => tryCatch(() async {
    final response = await dio.get('/client-phone/$clientId');
    return response.data['phone_number'] as String;
  });

  @override
  Future<Result<bool>> updateMaster(Master master) async => tryCatch(() async {
    final response = await dio.put('/master/profile', data: master.toJson()..remove('id'));
    return response.data['success'] == true;

    // return Master.fromJson(response.data['profile']); // Потому что поля блять живут своей жизнью на бэке х2
  });

  @override
  Future<Result<bool>> setServiceVisibility(int serviceId, bool visible) => tryCatch(() async {
    final response = await dio.patch('/master/service/$serviceId/toggle', data: {'is_active': visible});
    return response.data['success'] == true;
  });

  @override
  Future<Result<Map<Service, bool>>> getServices() => tryCatch(() async {
    final response = await dio.get('/master/services');
    final data = <Service, bool>{};
    for (final item in response.data['data']) {
      try {
        data[Service.fromJson(item['service'])] = item['enabled'] as bool;
      } catch (e, st) {
        logger.error('Error parsing item', e, st);
        rethrow;
      }
    }
    return data;
  });

  @override
  Future<Result<Service>> updateService(Service service) => tryCatch(() async {
    final response = await dio.put('/master/service/${service.id}', data: service.toJson()..remove('id'));
    return Service.fromJson(response.data['service']);
  });

  @override
  Future<Result<bool>> deleteService(int serviceId) => tryCatch(() async {
    await dio.delete('/master/service/$serviceId');
    return true;
  });
}
