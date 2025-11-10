import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared/shared.dart';

// ============================================================
// 🔹 Общие константы
// ============================================================
const double kWelcomeImageMaxWidth = 430;
const double kMainContainerMaxWidth = 938;
const double kContainerImageGap = 40;

// ============================================================
// 🔹 Верхний бар с логотипом
// ============================================================
class TopAppBar extends StatelessWidget {
  final bool isDesktop;
  final bool showImage;
  final VoidCallback onMenuTap;
  final VoidCallback onDownloadTap;

  const TopAppBar({
    super.key,
    required this.isDesktop,
    required this.showImage,
    required this.onMenuTap,
    required this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      color: AppColors.backgroundDefault,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: showImage
                    ? kMainContainerMaxWidth +
                          kContainerImageGap +
                          kWelcomeImageMaxWidth
                    : kMainContainerMaxWidth,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    'assets/images/polka_logo.svg',
                    width: 89,
                    height: 32,
                  ),
                  if (!isDesktop)
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: context.ext.theme.iconsDefault,
                      ),
                      onPressed: onMenuTap,
                    )
                  else
                    GestureDetector(
                      onTap: onDownloadTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.black,
                        ),
                        child: Text(
                          'Скачать POLKA',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 🔹 Breadcrumbs (хлебные крошки)
// ============================================================
class Breadcrumbs extends StatelessWidget {
  final bool showImage;
  final int activeStep;

  const Breadcrumbs({
    super.key,
    required this.showImage,
    required this.activeStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Авторизация',
      'Выбор услуги',
      'Выбор времени',
      'Персональные данные',
    ];

    final contentWidth = showImage
        ? kMainContainerMaxWidth + kContainerImageGap + kWelcomeImageMaxWidth
        : kMainContainerMaxWidth;

    return Positioned(
      top: 28,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: contentWidth.clamp(0.0, constraints.maxWidth),
                  ),
                  child: Row(
                    children: [
                      for (int i = 0; i < steps.length; i++) ...[
                        if (i > 0) ...[
                          const SizedBox(width: 4),
                          AppIcons.chevronForward.icon(
                            context,
                            size: 16,
                            color: AppColors.textPlaceholder,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          steps[i],
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: i == activeStep
                                ? AppColors.textPrimary
                                : AppColors.textPlaceholder,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// 🔹 Мобильный прогресс-бар
// ============================================================
class MobileProgressBar extends StatelessWidget {
  final VoidCallback onBackTap;

  const MobileProgressBar({super.key, required this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.backgroundDefault,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackTap,
            child: AppIcons.chevronBack.icon(
              context,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 27),
          Container(
            width: 40,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1000),
              color: AppColors.accentLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 🔹 Карточка мастера (Desktop)
// ============================================================
class DesktopMasterCard extends StatelessWidget {
  final String fullName;
  final String specialization;
  final String avatarUrl;
  final double rating;
  final String experience;
  final int reviews;

  const DesktopMasterCard({
    super.key,
    required this.fullName,
    required this.specialization,
    required this.avatarUrl,
    required this.rating,
    required this.experience,
    required this.reviews,
  });

  String getYearsText(String experience) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      decoration: BoxDecoration(
        color: AppColors.backgroundDefault,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.backgroundDefault, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 4,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            offset: const Offset(0, 16),
            blurRadius: 32,
            spreadRadius: -4,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: _MasterInfoColumn(
                  fullName: fullName,
                  specialization: specialization,
                  avatarUrl: avatarUrl,
                ),
              ),
              const SizedBox(width: 20),
              _MasterStatsColumn(
                rating: rating,
                experience: getYearsText(experience),
                reviews: reviews,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 🔹 Мобильная карточка мастера
// ============================================================
class MobileMasterCard extends StatelessWidget {
  final String fullName;
  final String specialization;
  final String avatarUrl;
  final double rating;
  final String experience;
  final int reviews;
  final Widget? actionButton;

  const MobileMasterCard({
    super.key,
    required this.fullName,
    required this.specialization,
    required this.avatarUrl,
    required this.rating,
    required this.experience,
    required this.reviews,
    this.actionButton,
  });

  String getYearsText(String experience) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: AppColors.backgroundDefault,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AppIcons.blotBigAlt.icon(
                  context,
                  size: 112,
                  color: context.ext.theme.accentLight,
                ),
                AppAvatar(avatarUrl: avatarUrl, size: 80),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              fullName,
              style: AppTextStyles.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              specialization,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _StatItemVertical(
                    value: rating.toStringAsFixed(1),
                    label: 'Рейтинг',
                    showStar: true,
                  ),
                ),
                Expanded(
                  child: _StatItemVertical(
                    value: getYearsText(experience),
                    label: 'Опыта',
                  ),
                ),
                Expanded(
                  child: _StatItemVertical(
                    value: reviews.toString(),
                    label: 'Отзыва',
                  ),
                ),
              ],
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 🔹 Аватар мастера с розовым фоном
// ============================================================
class MasterAvatar extends StatelessWidget {
  final String avatarUrl;
  final double size;
  final double splashSize;

  const MasterAvatar({
    super.key,
    required this.avatarUrl,
    this.size = 100,
    this.splashSize = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AppIcons.blotBigAlt.icon(
          context,
          size: splashSize,
          color: context.ext.theme.accentLight,
        ),
        AppAvatar(avatarUrl: avatarUrl, size: size),
      ],
    );
  }
}

// ============================================================
// 🔹 Боковое изображение с кнопкой
// ============================================================
class SideImage extends StatelessWidget {
  final double imageWidth;
  final double availableHeight;
  final VoidCallback onDownloadTap;
  final String? overlayText;
  final bool showOverlayText;

  const SideImage({
    super.key,
    required this.imageWidth,
    required this.availableHeight,
    required this.onDownloadTap,
    this.overlayText,
    this.showOverlayText = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: imageWidth),
      child: SizedBox(
        height: availableHeight,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0C0C0D0D).withValues(alpha: 0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: const Color(0x0C0C0D0D).withValues(alpha: 0.10),
                    offset: const Offset(0, 16),
                    blurRadius: 32,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/welcome_illustration.png',
                  fit: BoxFit.cover,
                  width: imageWidth,
                  height: availableHeight,
                ),
              ),
            ),
            if (showOverlayText && overlayText != null)
              Positioned(
                top: 40,
                left: 24,
                right: 24,
                child: Text(
                  overlayText!,
                  style: imageWidth >= kWelcomeImageMaxWidth
                      ? AppTextStyles.heading
                      : AppTextStyles.headingLarge,
                ),
              ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: onDownloadTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.backgroundDefault,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x0C0C0D0D).withValues(alpha: 0.05),
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: const Color(0x0C0C0D0D).withValues(alpha: 0.10),
                        offset: const Offset(0, 16),
                        blurRadius: 32,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Text(
                    'Скачать POLKA',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 🔹 Приватные виджеты
// ============================================================
class _MasterInfoColumn extends StatelessWidget {
  final String fullName;
  final String specialization;
  final String avatarUrl;

  const _MasterInfoColumn({
    required this.fullName,
    required this.specialization,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AppIcons.blotBigAlt.icon(
              context,
              size: 140,
              color: context.ext.theme.accentLight,
            ),
            AppAvatar(avatarUrl: avatarUrl, size: 100),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          fullName,
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        Text(
          specialization,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _MasterStatsColumn extends StatelessWidget {
  final double rating;
  final String experience;
  final int reviews;

  const _MasterStatsColumn({
    required this.rating,
    required this.experience,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatItem(
          value: rating.toStringAsFixed(1),
          label: 'Рейтинг',
          showStar: true,
        ),
        const SizedBox(height: 16),
        _StatItem(value: experience, label: 'Опыта'),
        const SizedBox(height: 16),
        _StatItem(value: reviews.toString(), label: 'Отзыва'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool showStar;

  const _StatItem({
    required this.value,
    required this.label,
    this.showStar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(value, style: AppTextStyles.bodyLarge),
              if (showStar) ...[
                const SizedBox(width: 4),
                AppIcons.star.icon(context, size: 16),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _StatItemVertical extends StatelessWidget {
  final String value;
  final String label;
  final bool showStar;

  const _StatItemVertical({
    required this.value,
    required this.label,
    this.showStar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: AppTextStyles.bodyLarge),
            if (showStar) ...[
              const SizedBox(width: 4),
              AppIcons.star.icon(context, size: 16),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
