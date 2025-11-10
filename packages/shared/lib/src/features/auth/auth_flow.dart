import 'package:flutter/material.dart';
import 'package:shared/src/extensions/context.dart';
import 'package:shared/src/models/auth_result.dart';
import 'package:shared/src/models/user.dart';
import 'package:shared/src/result.dart';

import 'presentation/code_verification_page.dart';
import 'presentation/phone_number_page.dart';

class AuthFlow<T extends User> extends StatefulWidget {
  const AuthFlow({super.key, required this.sendCode, required this.verifyCode, required this.onSuccess});

  final Future<Result<bool>> Function(String phone) sendCode;
  final Future<Result<AuthResult<T>>> Function(String phone, String code) verifyCode;
  final void Function(AuthResult<T> result) onSuccess;

  @override
  State<AuthFlow<T>> createState() => _AuthFlowState<T>();
}

class _AuthFlowState<T extends User> extends State<AuthFlow<T>> {
  void _onCodeSended(String phoneNumber) {
    context.ext.replace(
      PhoneVerificationCodePage<T>(
        phoneNumber: phoneNumber,
        onCodeVerified: widget.onSuccess,
        sendCode: widget.sendCode,
        verifyCode: widget.verifyCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PhoneNumberPage(onCodeSended: _onCodeSended, sendCode: widget.sendCode);
  }
}
