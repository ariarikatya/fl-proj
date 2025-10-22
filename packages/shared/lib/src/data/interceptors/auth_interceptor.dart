import 'dart:async';

import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getAccessToken;
  final Future<bool> Function() refreshTokens;
  final Dio dio;

  AuthInterceptor({required this.getAccessToken, required this.refreshTokens, required this.dio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final success = await refreshTokens();
      if (success) {
        // Retry the original request
        try {
          final response = await _retry(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.reject(e);
        }
      }
    }
    handler.next(err);
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await getAccessToken();

    final options = Options(
      method: requestOptions.method,
      extra: requestOptions.extra..addAll({'retry': true}),
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $token'},
    );

    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
