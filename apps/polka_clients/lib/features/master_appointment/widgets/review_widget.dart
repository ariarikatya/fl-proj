import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class ReviewWidget extends StatelessWidget {
  const ReviewWidget({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // padding: EdgeInsets.all(16),
      // decoration: BoxDecoration(color: AppColors.backgroundHover, borderRadius: BorderRadius.circular(24)),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              AppAvatar(avatarUrl: review.clientAvatarUrl),
              Expanded(child: AppText(review.clientName, style: AppTextStyles.bodyMedium)),
            ],
          ),
          AppText(review.comment, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
          AppText('⭐ ${review.rating.toString()}', style: AppTextStyles.bodyMedium),
          if (review.photos.isNotEmpty)
            Row(
              spacing: 8,
              children: review.photos
                  .take(2)
                  .map((e) => Flexible(child: ImageClipped(imageUrl: e, height: 180)))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
