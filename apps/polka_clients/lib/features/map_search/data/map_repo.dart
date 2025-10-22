import 'package:polka_clients/features/search/filters/search_filter.dart';
import 'package:shared/shared.dart';
import 'package:dio/dio.dart';

sealed class MapRepository {
  Future<Result<List<MasterMapInfo>>> searchMastersMapFeed(
    String? query,
    SearchFilter? filter,
    String city, {
    (double latitude, double longitude)? location,
    int page = 1,
    int limit = 10,
  });

  Future<Result<List<MasterMarker>>> searchMasterMarkers(
    String? query,
    SearchFilter? filter,
    String city, {
    (double latitude, double longitude)? location,
    int page = 1,
    int limit = 50,
  });

  Future<Result<MasterMapInfo>> getMasterMapInfo(int masterId, {(double latitude, double longitude)? location});
}

class RestMapRepository extends MapRepository {
  RestMapRepository(this.dio);

  final Dio dio;

  Map<String, dynamic> _formQuery(
    SearchFilter? filter,
    String? query,
    String city,
    (double latitude, double longitude)? location,
    int page,
    int limit,
  ) {
    final params = (filter?.toJson() ?? {})
      ..['city'] = city
      ..['page'] = page
      ..['limit'] = limit;

    if (query != null && query.isNotEmpty) params['query'] = query;
    if (location != null) {
      params
        ..['latitude'] = location.$1
        ..['longitude'] = location.$2;
    }

    return params;
  }

  @override
  Future<Result<List<MasterMarker>>> searchMasterMarkers(
    String? query,
    SearchFilter? filter,
    String city, {
    (double latitude, double longitude)? location,
    int page = 1,
    int limit = 10,
  }) => tryCatch(() async {
    final params = _formQuery(filter, query, city, location, page, limit);
    final response = await dio.post('/masters_map', data: params);
    return parseJsonList(response.data['masters'], MasterMarker.fromJson);
  });

  @override
  Future<Result<List<MasterMapInfo>>> searchMastersMapFeed(
    String? query,
    SearchFilter? filter,
    String city, {
    (double latitude, double longitude)? location,
    int page = 1,
    int limit = 10,
  }) => tryCatch(() async {
    final params = _formQuery(filter, query, city, location, page, limit);
    final response = await dio.post('/masters/details', data: params);
    return parseJsonList(response.data['masters'], MasterMapInfo.fromJson);
  });

  @override
  Future<Result<MasterMapInfo>> getMasterMapInfo(int masterId, {(double latitude, double longitude)? location}) =>
      tryCatch(() async {
        final params = location != null ? {'latitude': location.$1, 'longitude': location.$2} : null;
        final response = await dio.get('/masters/details/$masterId', data: params);
        return MasterMapInfo.fromJson(response.data as Map<String, dynamic>);
      });
}
