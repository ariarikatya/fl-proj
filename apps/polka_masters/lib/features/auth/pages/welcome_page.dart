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
          SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                AppText('Добро пожаловать\nв POLKA!', style: AppTextStyles.headingLarge),
                AppText(
                  'Находи клиентов, управляй расписанием,\nСоздавай бьюти-услуги',
                  style: AppTextStyles.bodyLarge.copyWith(color: context.ext.theme.textSecondary),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: AppTextButton.large(
              text: 'Начать',
              onTap: () async {
                final result = await context.ext.push(
                  AuthFlow(
                    role: AuthRole.master,
                    authRepository: Dependencies().authRepository,
                    udid: Dependencies().udid,
                  ),
                );
                if (result is AuthResult<Master> && context.mounted) {
                  AuthenticationScope.of(context).setAuth(result);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
