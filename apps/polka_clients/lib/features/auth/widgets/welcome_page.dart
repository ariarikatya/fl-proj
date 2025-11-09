import 'package:shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:polka_clients/dependencies.dart';

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
                  'Здесь ты найдешь своего мастера\nза пять минут',
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
                final result = await context.ext.push(
                  AuthFlow(
                    role: AuthRole.client,
                    authRepository: Dependencies().authRepository,
                    udid: Dependencies().udid,
                  ),
                );
                if (result is AuthResult<Client> && context.mounted) {
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
