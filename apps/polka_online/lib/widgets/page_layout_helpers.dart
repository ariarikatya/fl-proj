import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'widgets.dart';

// ============================================================
// 🔹 Помощники для вычисления размеров
// ============================================================
class LayoutHelper {
  static double calculateImageWidth({required double screenWidth, required bool showImage}) {
    double imageWidth = kWelcomeImageMaxWidth;
    if (showImage) {
      final fullContent = kMainContainerMaxWidth + kContainerImageGap + kWelcomeImageMaxWidth;
      if (screenWidth < fullContent) {
        final denom = (kWelcomeImageMaxWidth - 50);
        final t = denom > 0
            ? ((screenWidth - (kMainContainerMaxWidth + kContainerImageGap) - 50) / denom).clamp(0.0, 1.0)
            : 1.0;
        imageWidth = 50 + (kWelcomeImageMaxWidth - 50) * t;
      }
    }
    return imageWidth;
  }

  static bool shouldShowImage(double screenWidth, bool isDesktop) {
    return isDesktop && screenWidth >= 1120;
  }

  static bool isDesktopLayout(double screenWidth) {
    return screenWidth >= 800;
  }

  static double getAvailableHeight(double screenHeight) {
    return screenHeight - 88 - 88 - 70;
  }
}

// ============================================================
// 🔹 Обертка для Desktop Layout
// ============================================================
class DesktopPageLayout extends StatelessWidget {
  final Widget leftContent;
  final Widget? rightCard;
  final double screenWidth;
  final double screenHeight;
  final bool showImage;
  final double imageWidth;
  final VoidCallback onDownloadTap;
  final String? imageOverlayText;
  final bool showImageOverlay;

  const DesktopPageLayout({
    super.key,
    required this.leftContent,
    this.rightCard,
    required this.screenWidth,
    required this.screenHeight,
    required this.showImage,
    required this.imageWidth,
    required this.onDownloadTap,
    this.imageOverlayText,
    this.showImageOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final availableHeight = LayoutHelper.getAvailableHeight(screenHeight);

    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMainContainerMaxWidth),
              child: Container(
                constraints: BoxConstraints(minHeight: availableHeight),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSubtle,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.backgroundHover, width: 1),
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
                padding: const EdgeInsets.only(left: 64, top: 64, bottom: 64, right: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: screenWidth >= 1400 ? 420 : (screenWidth >= 1200 ? 400 : 360),
                          maxWidth: 640,
                        ),
                        child: leftContent,
                      ),
                    ),
                    if (rightCard != null) ...[
                      const SizedBox(width: kContainerImageGap),
                      ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: rightCard!),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (showImage) ...[
            const SizedBox(width: kContainerImageGap),
            SideImage(
              imageWidth: imageWidth,
              availableHeight: availableHeight,
              onDownloadTap: onDownloadTap,
              overlayText: imageOverlayText,
              showOverlayText: showImageOverlay,
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// 🔹 Обертка для всей страницы
// ============================================================
class PageScaffold extends StatelessWidget {
  final Widget child;
  final bool isDesktop;
  final bool showImage;
  final VoidCallback onMenuTap;
  final VoidCallback onDownloadTap;
  final int? breadcrumbStep;
  final Widget? mobileBottomButton;
  final VoidCallback? onBackTap;

  const PageScaffold({
    super.key,
    required this.child,
    required this.isDesktop,
    required this.showImage,
    required this.onMenuTap,
    required this.onDownloadTap,
    this.breadcrumbStep,
    this.mobileBottomButton,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      body: Column(
        children: [
          TopAppBar(isDesktop: isDesktop, showImage: showImage, onMenuTap: onMenuTap, onDownloadTap: onDownloadTap),
          if (!isDesktop && onBackTap != null) MobileProgressBar(onBackTap: onBackTap!),
          Expanded(
            child: Container(
              color: isDesktop ? AppColors.backgroundOnline : AppColors.backgroundDefault,
              child: Stack(
                children: [
                  if (isDesktop && breadcrumbStep != null)
                    Breadcrumbs(showImage: showImage, activeStep: breadcrumbStep!),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      top: isDesktop ? 88.0 : 16.0,
                      bottom: isDesktop ? 24.0 : 0.0,
                    ),
                    child: child,
                  ),
                ],
              ),
            ),
          ),
          if (!isDesktop && mobileBottomButton != null)
            Padding(padding: const EdgeInsets.all(16.0), child: mobileBottomButton!),
        ],
      ),
    );
  }
}

// ============================================================
// 🔹 Утилиты для форматирования
// ============================================================
class StringUtils {
  static String getYearsText(String experience) {
    final years = int.tryParse(experience.split(' ').first) ?? 0;
    if (years % 10 == 1 && years % 100 != 11) {
      return '$years год';
    } else if ([2, 3, 4].contains(years % 10) && ![12, 13, 14].contains(years % 100)) {
      return '$years года';
    } else {
      return '$years лет';
    }
  }

  static String getMasterFirstNameDative(String firstName) {
    if (firstName.endsWith('я')) {
      return '${firstName.substring(0, firstName.length - 1)}е';
    }
    return firstName;
  }
}
