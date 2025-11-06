import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

// ============================================================
// 🔹 Утилиты для работы со сторами
// ============================================================
class StoreUtils {
  /// Открывает магазин приложений в зависимости от платформы
  static Future<void> openStore() async {
    final url = _getStoreUrl();
    final uri = Uri.parse(url);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        logger.warning('Не удалось открыть магазин: $url');
      } else {
        logger.debug('Store opened successfully: $url');
      }
    } catch (e) {
      logger.error('Ошибка при открытии магазина: $e');
    }
  }

  static String _getStoreUrl() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'https://apps.apple.com/app/polka-beauty-marketplace';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'https://apps.apple.com/app/id6740820071';
    } else {
      return 'https://play.google.com/store/apps/details?id=com.mads.polkabeautymarketplace&hl=ru';
    }
  }
}

// ============================================================
// 🔹 Общие утилиты для форматирования
// ============================================================
class FormatUtils {
  /// Форматирует опыт работы в русском языке
  static String getYearsText(String experience) {
    final years = int.tryParse(experience.split(' ').first) ?? 0;
    if (years % 10 == 1 && years % 100 != 11) {
      return '$years год';
    } else if ([2, 3, 4].contains(years % 10) &&
        ![12, 13, 14].contains(years % 100)) {
      return '$years года';
    } else {
      return '$years лет';
    }
  }

  /// Преобразует имя в дательный падеж (для женских имен на -я)
  static String toNameDative(String firstName) {
    if (firstName.endsWith('я')) {
      return '${firstName.substring(0, firstName.length - 1)}е';
    }
    return firstName;
  }

  /// Обрезает строку до указанной длины с добавлением ...
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

// ============================================================
// 🔹 Виджет обработки ошибок
// ============================================================

class ErrorStateWidget extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const ErrorStateWidget({super.key, this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ошибка загрузки данных',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 16),
              Text(
                error ?? 'Неизвестная ошибка',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Попробовать снова'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 🔹 Виджет загрузки
// ============================================================
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
