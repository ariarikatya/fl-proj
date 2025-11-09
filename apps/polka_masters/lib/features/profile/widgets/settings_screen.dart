import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _launchLink(String link) => launchUrl(Uri.parse(link));

  void _maybeDeleteProfile(BuildContext context) async {
    final delete = await showConfirmBottomSheet(
      context: context,
      title: 'Ты уверена, что хочешь удалить профиль?',
      description:
          'Это действие нельзя будет отменить. Все твои данные, настройки и история будут безвозвратно удалены.',
      acceptText: 'Да, удалить',
      declineText: 'Нет, я передумала',
    );
    if (delete == true && context.mounted) {
      await AuthenticationScope.of(context).authRepository.deleteAccount();
      if (context.mounted) AuthenticationScope.of(context).logout();
    }
  }

  void _maybeLogout(BuildContext context) async {
    final delete = await showConfirmBottomSheet(
      context: context,
      title: 'Ты уверена, что хочешь выйти из профиля?',
      acceptText: 'Да, выйти',
      declineText: 'Нет, я передумала',
    );
    if (delete == true && context.mounted) {
      AuthenticationScope.of(context).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Настройки'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ProfileButton(
            icon: AppIcons.lock,
            title: 'Политика конфиденциальности',
            onTap: () => _launchLink(AppDocLinks.privacyPolicy),
          ),
          ProfileButton(
            icon: AppIcons.file,
            title: 'Пользовательское соглашение',
            onTap: () => _launchLink(AppDocLinks.termsOfUse),
          ),
          ProfileButton(
            icon: AppIcons.alertCircle,
            title: 'Условия использования',
            onTap: () => _launchLink(AppDocLinks.licenseAgreement),
          ),
          if (devMode) ...[
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 24),
              child: AppText('Themes (dev only)', style: AppTextStyles.headingSmall),
            ),
            const SizedBox(height: 8),
            for (var MapEntry(:key, :value) in AppThemeWidget.of(context).themes.entries)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Row(
                  children: [
                    AppText(key),
                    const Spacer(),
                    AppSwitch(
                      value: context.ext.theme == value,
                      onChanged: (v) {
                        if (v) AppThemeWidget.of(context).changeTheme(value);
                      },
                    ),
                  ],
                ),
              ),
          ],
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: AppTextButtonDangerous.large(text: 'Удалить профиль', onTap: () => _maybeDeleteProfile(context)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Center(
              child: AppLinkButton(text: 'Выйти', onTap: () => _maybeLogout(context)),
            ),
          ),
        ],
      ),
    );
  }
}
