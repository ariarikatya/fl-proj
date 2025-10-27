import 'package:flutter/material.dart';
import 'package:polka_clients/app_links.dart';
import 'package:polka_clients/features/profile/widgets/profile_button.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _launchLink(String link) => launchUrl(Uri.parse(link));

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: 'Настройки'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          ProfileButton(
            icon: AppIcons.lock,
            title: 'Политика конфиденциальности',
            onTap: () => _launchLink(AppLinks.privacyPolicy),
          ),
          ProfileButton(
            icon: AppIcons.file,
            title: 'Пользовательское соглашение',
            onTap: () => _launchLink(AppLinks.userAgreement),
          ),
          ProfileButton(
            icon: AppIcons.alertCircle,
            title: 'Условия пользования',
            onTap: () => _launchLink(AppLinks.termsOfUse),
          ),
          if (devMode) ...[
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.only(left: 24),
              child: AppText('Themes', style: AppTextStyles.headingSmall),
            ),
            SizedBox(height: 8),
            for (var MapEntry(:key, :value) in AppThemeWidget.of(context).themes.entries)
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Row(
                  children: [
                    AppText(key),
                    Spacer(),
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
        ],
      ),
    );
  }
}
