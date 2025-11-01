import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorizationPage extends StatelessWidget {
  const AuthorizationPage({super.key});

  void _openStore(BuildContext context) async {
    final url = Theme.of(context).platform == TargetPlatform.iOS
        ? 'https://apps.apple.com/app/polka-beauty-marketplace'
        : 'https://play.google.com/store/apps/details?id=com.mads.polkabeautymarketplace&hl=ru';
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOnline,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/images/polka_logo.svg',
                        width: 89,
                        height: 32,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Steps list
                  Text('Шаг 1', style: AppTextStyles.headingLarge),
                  const SizedBox(height: 8),
                  Text('Выберите услугу', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 32),
                  Text('Шаг 2', style: AppTextStyles.headingLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Выберите дату и время',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  Text('Шаг 3', style: AppTextStyles.headingLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Заполните личные данные',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          // Button at bottom with SafeArea
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openStore(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Скачать POLKA',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
