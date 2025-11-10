import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared/src/app_text_styles.dart';
import 'package:shared/src/features/auth/presentation/support_button.dart';
import 'package:shared/src/models/auth_result.dart';
import 'package:shared/src/models/user.dart';
import 'package:shared/src/result.dart';
import 'package:shared/src/utils.dart';
import 'package:shared/src/widgets/app_link_button.dart';
import 'package:shared/src/widgets/app_page.dart';
import 'package:shared/src/widgets/app_text.dart';

import 'app_pin_form.dart';

class PhoneVerificationCodePage<T extends User> extends StatelessWidget {
  const PhoneVerificationCodePage({
    super.key,
    required this.phoneNumber,
    required this.sendCode,
    required this.verifyCode,
    required this.onCodeVerified,
  });

  final String phoneNumber;
  final Future<Result<bool>> Function(String phone) sendCode;
  final Future<Result<AuthResult<T>>> Function(String phone, String code) verifyCode;
  final void Function(AuthResult<T> authResult) onCodeVerified;

  Future<String?> _verifyCode(String code) async {
    return (await verifyCode(phoneNumber, code)).when(
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
                  _ResendCodeButton(phoneNumber: phoneNumber, sendCode: sendCode),
                ],
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 24), child: SupportButton()),
        ],
      ),
    );
  }
}

class _ResendCodeButton extends StatefulWidget {
  const _ResendCodeButton({required this.phoneNumber, required this.sendCode});

  final String phoneNumber;
  final Future<Result<bool>> Function(String phone) sendCode;

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

    final result = await widget.sendCode(widget.phoneNumber);

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
