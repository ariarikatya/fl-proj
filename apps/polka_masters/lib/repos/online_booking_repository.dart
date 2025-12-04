import 'package:shared/shared.dart';
import 'package:dio/dio.dart';

sealed class OnlineBookingRepository {
  Future<Result<OnlineBookingConfig>> getPublicLinkConfig();
  Future<Result<void>> setPublicLinkVisibility(OnlineBookingVisibility visibility);
  Future<Result<void>> toggleNightStop();
}

final class RestOnlineBookingRepository extends OnlineBookingRepository {
  RestOnlineBookingRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<OnlineBookingConfig>> getPublicLinkConfig() => tryCatch(() async {
    final response = await dio.get('/master/online-booking/settings');
    logger.debug('response: ${response.data}');
    return OnlineBookingConfig.fromJson(response.data['data']);
  });

  @override
  Future<Result<void>> setPublicLinkVisibility(OnlineBookingVisibility visibility) => tryCatch(() async {
    await dio.put('/master/online-booking/visibility', data: {'visibility': visibility.toJson()});
  });

  @override
  Future<Result<void>> toggleNightStop() => tryCatch(() async {
    await dio.post('/master/online-booking/toggle-night-stop');
  });
}
