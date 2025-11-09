import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:shared/shared.dart';

const _baseUrl = 'https://polka-bm.online:9922/api_v1';

abstract class DioFactory {
  static Dio createDio({String? baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    )..interceptors.add(dioLogger());

    dio.interceptors.addAll([retryInterceptor(dio), apiErrorInterceptor()]);

    return dio;
  }
}

Interceptor retryInterceptor(Dio dio) => RetryInterceptor(dio: dio, retries: 3, logPrint: logger.warning);

Interceptor apiErrorInterceptor() => InterceptorsWrapper(
  onError: (error, handler) {
    Future(() => showErrorSnackbar(parseError(error)));
    return handler.next(error);
  },
);
