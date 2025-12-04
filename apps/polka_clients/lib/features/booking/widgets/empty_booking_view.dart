import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class EmptyBookingView extends StatelessWidget {
  const EmptyBookingView({super.key, required this.action});

  final VoidCallback? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText('Пока у тебя нет посещений.', textAlign: TextAlign.center, style: AppTextStyles.headingSmall),
            const SizedBox(height: 8),
            AppText(
              'Посмотри в нашем бьюти-каталоге',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(color: context.ext.colors.black[700]),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              AppTextButton.small(text: 'Найти бьюти-услугу', onTap: action!),
            ],
          ],
        ),
      ),
    );
  }
}
