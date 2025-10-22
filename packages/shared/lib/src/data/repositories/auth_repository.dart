// ignore_for_file: type_literal_in_constant_pattern

import 'package:dio/dio.dart';
import 'package:shared/src/models/auth_result.dart';
import 'package:shared/src/models/client.dart';
import 'package:shared/src/models/master/master.dart';
import 'package:shared/src/models/user.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/utils.dart';

enum AuthRole { client, master }

sealed class AuthRepository {
  Future<Result<bool>> sendCode(String phone);
  Future<Result<AuthResult<T>>> verifyCode<T extends User>(String phone, String code, String udid);
  Future<Result<T>> getProfile<T extends User>(String token);
  Future<Result<TokensPair>> refreshTokens<T extends User>(String refreshToken, String udid);
  Future<Result<bool>> deleteAccount();
}

class RestAuthRepository extends AuthRepository {
  RestAuthRepository(this.dio);

  final Dio dio;

  @override
  Future<Result<bool>> sendCode(String phone) => tryCatch(() async {
    final response = await dio.post('/send_code', data: {'phone': phone});
    return response.data['message'] == 'Код отправлен';
  });

  @override
  Future<Result<AuthResult<T>>> verifyCode<T extends User>(String phone, String code, String udid) =>
      tryCatch(() async {
        final role = switch (T) {
          Client => 'client',
          Master => 'master',
          _ => throw Exception('Invalid role: $T'),
        };

        final response = await dio.post(
          '/auth/verify_code',
          data: {'phone': phone, 'code': code, 'role': role, 'device_id': udid},
        );

        final account = switch (T) {
          Client => response.data['client_profile'] != null ? Client.fromJson(response.data['client_profile']) : null,
          Master => response.data['master_profile'] != null ? Master.fromJson(response.data['master_profile']) : null,
          _ => throw Exception('Invalid role: $T'),
        };
        final tokens = (
          accessToken: response.data['token'] as String,
          refreshToken: response.data['refresh_token'] as String,
        );

        return (phoneNumber: phone, tokens: tokens, account: account as T?);
      });

  @override
  Future<Result<bool>> deleteAccount() => tryCatch(() async {
    final response = await dio.delete('/user_profile');
    return response.data['success'] == true;
  });

  @override
  Future<Result<T>> getProfile<T extends User>(String token) => tryCatch(() async {
    final response = await dio.get('/user_profile', options: Options(headers: {'Authorization': 'Bearer $token'}));
    return switch (T) {
      Client => Client.fromJson(response.data['client_profile']) as T,
      Master => Master.fromJson(response.data['master_profile']) as T,
      _ => throw Exception('Invalid role: $T'),
    };
  });

  @override
  Future<Result<TokensPair>> refreshTokens<T extends User>(String refreshToken, String udid) => tryCatch(() async {
    final role = switch (T) {
      Client => 'client',
      Master => 'master',
      _ => throw Exception('Invalid role: $T'),
    };

    final response = await dio.post(
      '/auth/refresh_token',
      data: {'refresh_token': refreshToken, 'device_id': udid, 'role': role},
    );
    if (response.data case <String, dynamic>{'token': String token, 'refresh_token': String refreshToken}) {
      return (accessToken: token, refreshToken: refreshToken);
    }
    throw Exception('Invalid response: ${response.data}');
  });
}
