import 'package:shared/shared.dart';
import 'package:dio/dio.dart';

sealed class FavoritesRepository {
  Future<Result<List<Master>>> getFavoriteMasters({int limit = 10, int offset = 0});
  Future<Result<bool>> addFavoriteMaster(int masterId);
  Future<Result<bool>> removeFavoriteMaster(int masterId);
}

final class RestFavoritesRepository extends FavoritesRepository {
  RestFavoritesRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<List<Master>>> getFavoriteMasters({int limit = 10, int offset = 0}) =>
      tryCatch(() async {
        final response = await dio.get(
          '/favorites',
          queryParameters: {'limit': limit, 'offset': offset},
        );
        return parseJsonList(response.data['masters'], Master.fromJson);
      });

  @override
  Future<Result<bool>> addFavoriteMaster(int masterId) => tryCatch(() async {
    final response = await dio.post('/favorites/add', data: {'master_id': masterId});
    return response.data['is_favorite'] as bool;
  });

  @override
  Future<Result<bool>> removeFavoriteMaster(int masterId) => tryCatch(() async {
    final response = await dio.post('/favorites/remove', data: {'master_id': masterId});
    return response.data['is_favorite'] as bool;
  });
}
