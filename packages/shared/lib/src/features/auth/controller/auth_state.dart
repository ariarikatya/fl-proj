import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

sealed class AuthState<T extends User> {
  const AuthState._();
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated._;
  const factory AuthState.onboarding(AuthResult<T> authResult) = AuthStateOnboarding._;
  factory AuthState.authenticated(AuthResult<T> authResult, T user) = AuthStateAuthenticated._;
}

final class AuthStateUnauthenticated<T extends User> extends AuthState<T> {
  const AuthStateUnauthenticated._() : super._();
}

final class AuthStateOnboarding<T extends User> extends AuthState<T> {
  const AuthStateOnboarding._(this.authResult) : super._();
  final AuthResult<T> authResult;
}

final class AuthStateAuthenticated<T extends User> extends AuthState<T> {
  AuthStateAuthenticated._(this.authResult, T user) : user = ValueNotifier(user), super._();
  final AuthResult<T> authResult;
  final ValueNotifier<T> user;
}
