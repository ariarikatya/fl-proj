import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

sealed class AboutInfo extends StatelessWidget {
  const AboutInfo._({super.key, required this.master});

  final Master master;

  factory AboutInfo.city({required Master master}) => _AboutCity._(master);
  factory AboutInfo.reviews({required Master master}) => _AboutReviews._(master);
  factory AboutInfo.experience({required Master master, bool short = false}) => _AboutExperience._(master, short);
}

class _AboutExperience extends AboutInfo {
  const _AboutExperience._(Master master, this.short) : super._(master: master);

  final bool short;

  @override
  Widget build(BuildContext context) {
    return _AboutInfo(
      emoji: AppEmojis.scissors,
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          children: [
            if (!short) TextSpan(text: 'опыт: '),
            TextSpan(
              text: master.experience,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutReviews extends AboutInfo {
  const _AboutReviews._(Master master) : super._(master: master);

  @override
  Widget build(BuildContext context) {
    final label = master.reviewsCount == 0 ? 'Нет отзывов' : master.reviewsCount.pluralMasculine('отзыв');
    return AppText(
      '⭐ ${master.ratingFixed} ($label)',
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _AboutCity extends AboutInfo {
  const _AboutCity._(Master master) : super._(master: master);

  @override
  Widget build(BuildContext context) {
    return _AboutInfo(emoji: AppEmojis.lollipop, text: master.city);
  }
}

class _AboutInfo extends StatelessWidget {
  const _AboutInfo({required this.emoji, this.text, this.child});

  final AppEmojis emoji;
  final String? text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        emoji.icon(size: Size(14, 14)),
        SizedBox(width: 4),
        child ?? AppText(text ?? '', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
