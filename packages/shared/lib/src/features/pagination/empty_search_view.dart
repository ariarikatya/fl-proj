import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class EmptySearchView extends StatelessWidget {
  const EmptySearchView({super.key, required this.onResetFilters});

  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'По твоему запросу ничего не найдено.',
              textAlign: TextAlign.center,
              style: AppTextStyles.headingSmall,
            ),
            SizedBox(height: 8),
            AppText(
              'Попробуй перенастроить фильтры или сменить ключевое слово',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
            if (onResetFilters != null) ...[
              SizedBox(height: 16),
              AppTextButton.small(text: ' Сбросить фильтры ', onTap: onResetFilters!),
            ],
          ],
        ),
      ),
    );
  }
}
