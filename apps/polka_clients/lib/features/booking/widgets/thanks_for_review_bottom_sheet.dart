import 'package:flutter/material.dart';
import 'package:polka_clients/features/home/controller/home_navigation_cubit.dart';
import 'package:shared/shared.dart';

class ThanksForReviewBottomSheet extends StatelessWidget {
  const ThanksForReviewBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return MbsBase(
      expandContent: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Image.asset(
                'assets/images/master_avatar_default.png',
                package: 'shared',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          AppText('Спасибо за отзыв!', style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          AppText(
            'Твой отклик помогает другим найти своего мастера, а мастеру — расти и становиться лучше. 💛',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          AppTextButton.large(
            text: 'К записям',
            onTap: () {
              context.ext.pop();
              blocs.get<HomeNavigationCubit>(context).openBookings();
            },
          ),
        ],
      ),
    );
  }
}
