import 'package:flutter/material.dart';
import 'package:shared/src/models/auth_result.dart';
import 'package:shared/src/data/repositories/auth_repository.dart';

import 'presentation/code_verification_page.dart';
import 'presentation/phone_number_page.dart';

abstract class AuthRoute {
  static const phoneNumber = '/phone-number';
  static const codeVerification = '/code-verification';
}

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key, required this.role, required this.udid, required this.authRepository});

  final AuthRole role;
  final String udid;
  final AuthRepository authRepository;

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  void _onCodeSended(String phoneNumber) {
    _navigatorKey.currentState?.pushNamed(AuthRoute.codeVerification, arguments: phoneNumber);
  }

  void _onCodeVerified(AuthResult result) {
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        final page = switch (settings.name) {
          AuthRoute.phoneNumber || Navigator.defaultRouteName => PhoneNumberPage(
            onCodeSended: _onCodeSended,
            sendCode: widget.authRepository.sendCode,
          ),
          AuthRoute.codeVerification => PhoneVerificationCodePage(
            phoneNumber: settings.arguments as String,
            onCodeVerified: _onCodeVerified,
            repository: widget.authRepository,
            udid: widget.udid,
            role: widget.role,
          ),
          _ => throw Exception('Unknown route: ${settings.name}'),
        };
        return MaterialPageRoute(builder: (context) => page, settings: settings);
      },
    );
  }
}
