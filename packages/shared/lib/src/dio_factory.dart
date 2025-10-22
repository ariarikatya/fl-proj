import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

const _baseUrl = 'https://polka-bm.online:9922/api_v1';

abstract class DioFactory {
  static Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 10),
      ),
    )..interceptors.addAll([dioLogger(), apiErrorInterceptor]);
  }
}

final apiErrorInterceptor = InterceptorsWrapper(
  onError: (error, handler) {
    showErrorSnackbar(parseError(error));
    handler.next(error);
  },
);
