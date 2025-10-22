import 'package:flutter/material.dart';
import 'package:shared/src/features/auth/controller/auth_controller.dart';

class AuthenticationScope extends InheritedWidget {
  const AuthenticationScope({super.key, required this.controller, required super.child});

  final AuthController controller;

  static AuthController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthenticationScope>()?.controller;
  }

  static AuthController of(BuildContext context) {
    final scope = AuthenticationScope.maybeOf(context);
    assert(scope != null, 'AuthenticationScope not found above BuildContext');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AuthenticationScope oldWidget) => controller.value != oldWidget.controller.value;
}
