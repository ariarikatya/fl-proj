import 'package:image_picker/image_picker.dart';
import 'package:polka_clients/features/search/filters/search_filter.dart';
import 'package:shared/shared.dart';
import 'package:dio/dio.dart';

sealed class ClientRepository {
  Future<Result<List<Master>>> getMastersFeed({int limit = 10, int offset = 0});
  Future<Result<List<Master>>> searchMasters(String query, SearchFilter? filter);
  Future<Result<MasterInfo>> getMasterInfo(int masterId);
  Future<Result<List<Review>>> getMasterReviews(int masterId);
  Future<Result<List<AvailableSlot>>> getSlots(int masterId, int serviceId);
  Future<Result<int>> makeAppointment({required int serviceId, required int slotId, String? notes});
  Future<Result<String>> uploadClientAvatar(XFile photo);
  Future<Result<String>> getMasterPhone(int masterId);
  Future<Result<List<ServiceCategories>>> updatePreferredServices(List<ServiceCategories> services);
}

class RestClientRepository extends ClientRepository {
  RestClientRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<List<Master>>> getMastersFeed({int limit = 10, int offset = 0}) async {
    try {
      final response = await dio.get('/masters_feed', queryParameters: {'limit': limit, 'offset': offset});
      final masters = parseJsonList(response.data['masters'], Master.fromJson);
      return Result.ok(masters);
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

  @override
  Future<Result<List<Master>>> searchMasters(String query, SearchFilter? filter) async {
    try {
      final data = (filter?.toJson() ?? {})..['query'] = query;
      final response = await dio.post('/search_masters', data: data);
      final masters = parseJsonList(response.data['results'], Master.fromJson);
      return Result.ok(masters);
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
  Future<Result<List<AvailableSlot>>> getSlots(int masterId, int serviceId) async {
    try {
      final response = await dio.get(
        '/masters/$masterId/calendar',
        queryParameters: {
          'service_id': serviceId,
          'date_from': DateTime.now().toJson(),
          'date_to': DateTime.now().add(const Duration(days: 10)).toJson(),
        },
      );
      final data = parseJsonList(response.data['slots'], AvailableSlot.fromJson);
      return Result.ok(data);
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

  @override
  Future<Result<int>> makeAppointment({required int serviceId, required int slotId, String? notes}) =>
      tryCatch(() async {
        final response = await dio.post(
          '/appointments/from-slot',
          data: {'slot_id': slotId, 'service_id': serviceId, 'client_notes': ?notes},
        );
        return response.data['appointment']['id'] as int;
      });

  @override
  Future<Result<List<Review>>> getMasterReviews(int masterId) async => tryCatch(() async {
    final response = await dio.get('/reviews/master/$masterId');
    return parseJsonList(response.data['reviews'], Review.fromJson);
  });

  @override
  Future<Result<String>> uploadClientAvatar(XFile photo) => tryCatch(() async {
    final formData = FormData.fromMap({'photo': MultipartFile.fromFileSync(photo.path)});
    final result = await dio.post('/client/avatar', data: formData);
    return result.data['avatar_url'] as String;
  });

  @override
  Future<Result<String>> getMasterPhone(int masterId) async => tryCatch(() async {
    final response = await dio.get('/master_phone/$masterId');
    return response.data['phone_number'] as String;
  });

  @override
  Future<Result<List<ServiceCategories>>> updatePreferredServices(List<ServiceCategories> services) =>
      tryCatch(() async {
        final response = await dio.put(
          '/client/preferred-services',
          data: {"preferred_services": services.map((e) => e.toJson()).toList()},
        );
        return parseJsonList(response.data['preferred_services'], ServiceCategories.fromJson);
      });
}
