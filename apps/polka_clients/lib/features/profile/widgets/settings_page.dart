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
        ],
      ),
    );
  }
}
