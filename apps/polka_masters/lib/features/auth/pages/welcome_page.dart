import 'package:shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                const AppText('Добро пожаловать\nв POLKA!', style: AppTextStyles.headingLarge),
                AppText(
                  'Находи клиентов, управляй расписанием,\nСоздавай бьюти-услуги',
                  style: AppTextStyles.bodyLarge.copyWith(color: context.ext.theme.textSecondary),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: AppTextButton.large(
              text: 'Начать',
              onTap: () async {
                final deps = Dependencies();
                context.ext.push(
                  AuthFlow<Master>(
                    sendCode: (phone) => deps.authRepository.sendCode(phone),
                    verifyCode: (phone, code) => deps.authRepository.verifyCode<Master>(phone, code, deps.udid),
                    onSuccess: (result) {
                      AuthenticationScope.of(context).setAuth(result);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
