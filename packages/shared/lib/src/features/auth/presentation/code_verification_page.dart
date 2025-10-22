import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/models/auth_result.dart';
import 'package:shared/src/models/client.dart';
import 'package:shared/src/models/master/master.dart';
import 'package:shared/src/models/user.dart';
import 'package:shared/src/data/repositories/auth_repository.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/utils.dart';
import 'package:shared/src/widgets/app_link_button.dart';
import 'package:shared/src/widgets/app_page.dart';
import 'package:shared/src/widgets/app_text.dart';

import 'app_pin_form.dart';

class PhoneVerificationCodePage extends StatelessWidget {
  const PhoneVerificationCodePage({
    super.key,
    required this.phoneNumber,
    required this.udid,
    required this.onCodeVerified,
    required this.repository,
    required this.role,
  });

  final String phoneNumber;
  final String udid;
  final void Function(AuthResult) onCodeVerified;
  final AuthRepository repository;
  final AuthRole role;

  Future<String?> _verifyCode(String code) async {
    final Result<AuthResult<User>> result = switch (role) {
      AuthRole.client => await repository.verifyCode<Client>(phoneNumber, code, udid),
      AuthRole.master => await repository.verifyCode<Master>(phoneNumber, code, udid),
    };

    return result.when(
      ok: (data) {
        onCodeVerified(data);
        return null;
      },
      err: (err, st) => parseError(err, st),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 48),
          SizedBox(
            height: 330,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText('Введи код, отправленный на +$phoneNumber', style: AppTextStyles.headingLarge),
                  SizedBox(height: 38),
                  AppPinForm(validateCode: _verifyCode),
                  SizedBox(height: 16),
                  _ResendCodeButton(phoneNumber: phoneNumber, repository: repository),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 24),
            child: AppText(
              'Нужна помощь? (Чат поддержки)',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationThickness: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendCodeButton extends StatefulWidget {
  const _ResendCodeButton({required this.phoneNumber, required this.repository});

  final String phoneNumber;
  final AuthRepository repository;

  @override
  State<_ResendCodeButton> createState() => _ResendCodeButtonState();
}

class _ResendCodeButtonState extends State<_ResendCodeButton> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 60);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendCode() async {
    if (_isLoading || _secondsRemaining > 0) return;

    setState(() => _isLoading = true);

    final result = await widget.repository.sendCode(widget.phoneNumber);

    setState(() => _isLoading = false);

    result.maybeWhen(ok: (_) => _startTimer());
  }

  String get _buttonText {
    if (_secondsRemaining > 0) {
      final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
      final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
      return 'Отправить код повторно через $minutes:$seconds';
    }
    return _timer == null ? 'Не получили код?' : 'Отправить код повторно';
  }

  @override
  Widget build(BuildContext context) {
    return AppLinkButton(text: _buttonText, onTap: _isLoading || _secondsRemaining > 0 ? null : () => _resendCode());
  }
}
