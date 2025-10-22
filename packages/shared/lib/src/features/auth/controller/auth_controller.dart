import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared/src/blocs_provider.dart';
import 'package:shared/src/features/auth/controller/auth_state.dart';
import 'package:shared/src/logger.dart';
import 'package:shared/src/models/auth_result.dart';
import 'package:shared/src/models/user.dart';
import 'package:shared/src/data/repositories/auth_repository.dart';

typedef AuthStateChanged<T extends User> = void Function(AuthState<T> prev, AuthState<T> curr);

class AuthController<T extends User> extends ValueNotifier<AuthState<T>> {
  AuthController(
    super.value, {
    required this.authRepository,
    required this.secureStorage,
    required this.udid,
    this.onStateChanged,
  });

  final String udid;
  final AuthRepository authRepository;
  final FlutterSecureStorage secureStorage;
  final AuthStateChanged<T>? onStateChanged;

  @override
  void notifyListeners() {
    logger.info('AuthController state is ${value.runtimeType}');
    super.notifyListeners();
  }

  static Future<AuthController<T>> init<T extends User>(
    (TokensPair tokens, String number)? data,
    String udid,
    AuthRepository authRepository,
    FlutterSecureStorage secureStorage, {
    AuthStateChanged<T>? onStateChanged,
  }) async {
    AuthState<T>? state;
    TokensPair? tokens = data?.$1;

    if (data != null) {
      tokens = (await authRepository.refreshTokens<T>(data.$1.refreshToken, udid)).unpack();
      if (tokens != null) {
        final profile = (await authRepository.getProfile<T>(tokens.accessToken)).unpack();
        if (profile != null) {
          state = AuthState.authenticated((phoneNumber: data.$2, tokens: tokens, account: profile), profile);
        }
      }
    }

    final controller = AuthController<T>(
      state ?? AuthState.unauthenticated(),
      authRepository: authRepository,
      secureStorage: secureStorage,
      udid: udid,
      onStateChanged: onStateChanged,
    );
    logger.info('AuthController initialized with ${controller.value.runtimeType}');
    if (tokens != null) {
      controller._saveTokens(tokens);
    }
    return controller;
  }

  void setAuth(AuthResult<T> authResult) {
    final state = switch (authResult.account) {
      T user => AuthState<T>.authenticated(authResult, user),
      _ => AuthState<T>.onboarding(authResult),
    };
    _updateState(state);
    _saveTokens(authResult.tokens);
    _savePhoneNumber(authResult.phoneNumber);
  }

  void completeOnboarding(T user) {
    if (value case AuthStateOnboarding state) {
      final $authResult = (phoneNumber: state.authResult.phoneNumber, tokens: state.authResult.tokens, account: user);
      _updateState(AuthState.authenticated($authResult, user));
    } else {
      throw Exception('Can only complete onboarding in onboarding state');
    }
  }

  void logout() {
    blocs.clear();
    _deleteCredentials();
    _updateState(AuthState.unauthenticated());
  }

  AuthResult<T>? get _authResult => switch (value) {
    AuthStateAuthenticated<T>(:final authResult) => authResult,
    AuthStateOnboarding<T>(:final authResult) => authResult,
    _ => null,
  };

  Future<String?> getAccessToken() => Future.value(_authResult?.tokens.accessToken);

  Future<bool> refreshTokens() async {
    final refreshToken = await secureStorage.read(key: 'refreshToken');
    if (refreshToken == null) return false;

    final result = await authRepository.refreshTokens(refreshToken, udid);
    return result.when(
      ok: (tokens) {
        _saveTokens(tokens);
        return true;
      },
      err: (err, st) {
        logger.error('Error refreshing tokens:', err, st);
        return false;
      },
    );
  }

  void _updateState(AuthState<T> state) {
    final $prev = value;
    value = state;
    onStateChanged?.call($prev, state);
  }

  void _saveTokens(TokensPair tokens) {
    secureStorage.write(key: 'token', value: tokens.accessToken);
    secureStorage.write(key: 'refreshToken', value: tokens.refreshToken);
  }

  void _savePhoneNumber(String phoneNumber) {
    secureStorage.write(key: 'phoneNumber', value: phoneNumber);
  }

  void _deleteCredentials() {
    secureStorage.delete(key: 'token');
    secureStorage.delete(key: 'refreshToken');
    secureStorage.delete(key: 'phoneNumber');
  }
}
