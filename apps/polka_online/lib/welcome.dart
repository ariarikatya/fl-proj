import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'menu.dart';

class WelcomePage extends StatelessWidget {
  final String masterId;
  final String masterFullName;
  final String masterSpecialization;
  final double masterRating;
  final int masterExperience;
  final int masterReviews;

  const WelcomePage({
    super.key,
    this.masterId = '1',
    this.masterFullName = 'Мария Абрамова',
    this.masterSpecialization = 'Стилист по волосам',
    this.masterRating = 4.9,
    this.masterExperience = 4,
    this.masterReviews = 134,
  });

  String get masterFirstName => masterFullName.split(' ')[0];

  String get masterFirstNameDative {
    final name = masterFirstName;
    if (name.endsWith('я')) {
      return name.substring(0, name.length - 1) + 'е';
    }
    return name;
  }

  String getYearsText(int years) {
    if (years % 10 == 1 && years % 100 != 11) {
      return '$years год';
    } else if ([2, 3, 4].contains(years % 10) &&
        ![12, 13, 14].contains(years % 100)) {
      return '$years года';
    } else {
      return '$years лет';
    }
  }

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

  void _openBooking() async {
    final webUrl = 'https://polka.app/masters/$masterId';
    try {
      await launchUrl(Uri.parse(webUrl));
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    // Учитываем горизонтальный планшет
    final isDesktop = width >= 1024 || (width >= 768 && width > height);
    final isTabletOrMobile = !isDesktop;
    // Показываем картинку только если достаточно места (больше 900px в ширину)
    final showImage = width >= 900;

    return Scaffold(
      backgroundColor: isDesktop
          ? const Color(0xFFFFF9FC)
          : AppColors.backgroundDefault,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'assets/images/polka_logo.svg',
                      width: 89,
                      height: 32,
                    ),
                    if (isTabletOrMobile)
                      IconButton(
                        icon: const Icon(Icons.menu, size: 24),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MenuPage(),
                            ),
                          );
                        },
                      )
                    else
                      GestureDetector(
                        onTap: () => _openStore(context),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.black,
                          ),
                          child: Text(
                            'Скачать POLKA',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          if (isDesktop)
            Positioned(
              top: 80,
              left: 24,
              child: Row(
                children: [
                  Text('Авторизация', style: AppTextStyles.bodyLarge),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textPlaceholder,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Выбор услуги',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textPlaceholder,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Выбор времени',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textPlaceholder,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Персональные данные',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              top: isDesktop ? 140.0 : 100.0,
              bottom: 24.0,
            ),
            child: SingleChildScrollView(
              child: SafeArea(
                child: isDesktop
                    ? _buildDesktopLayout(context, showImage)
                    : _buildMobileLayout(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool showImage) {
    final height = MediaQuery.of(context).size.height;
    final availableHeight = height - 140 - 70; // вычитаем отступ сверху и снизу

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Общий контейнер для первых двух столбиков
        Expanded(
          flex: showImage ? 3 : 1,
          child: Container(
            height: availableHeight,
            decoration: BoxDecoration(
              color: AppColors.backgroundSubtle,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.fromLTRB(64, 64, 40, 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Первый столбик - приветствие
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Рады вас видеть!',
                        style: AppTextStyles.headingLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Чтобы записаться к мастеру и выбрать услугу,\nпожалуйста, нажмите "Записаться"',
                        style: AppTextStyles.bodyMedium500.copyWith(
                          color: AppColors.iconsDefault,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 280,
                        child: ElevatedButton(
                          onPressed: _openBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Записаться к $masterFirstNameDative',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                // Второй столбик - карточка мастера
                _buildDesktopMasterCard(context),
              ],
            ),
          ),
        ),
        if (showImage) ...[
          const SizedBox(width: 40),
          // Третий столбик - картинка
          Expanded(
            flex: 2,
            child: SizedBox(
              height: availableHeight,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/welcome_illustration.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 40,
                    right: 40,
                    child: Text(
                      'Установи POLKA\nи найди своего\nмастера',
                      style: AppTextStyles.headingMedium,
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: GestureDetector(
                      onTap: () => _openStore(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black,
                        ),
                        child: Text(
                          'Скачать POLKA',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Рады вас видеть!', style: AppTextStyles.headingLarge),
        const SizedBox(height: 16),
        Text(
          'Чтобы записаться к мастеру и выбрать услугу,\nпожалуйста, нажмите "Записаться"',
          style: AppTextStyles.bodyMedium500.copyWith(
            color: AppColors.iconsDefault,
          ),
        ),
        const SizedBox(height: 32),
        _buildMobileMasterCard(context),
      ],
    );
  }

  Widget _buildDesktopMasterCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDefault,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.backgroundSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/pink_splash.svg',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                    ClipOval(
                      child: Image.asset(
                        'assets/images/master_photo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(masterFullName, style: AppTextStyles.headingMedium),
                const SizedBox(height: 4),
                Text(masterSpecialization, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildStatItem('$masterRating ★', 'Рейтинг'),
              _buildStatItem(getYearsText(masterExperience), 'Опыта'),
              _buildStatItem(masterReviews.toString(), 'Отзыва'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      height: 81,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: AppTextStyles.bodyLarge),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildMobileMasterCard(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: AppColors.backgroundDefault,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
                SvgPicture.asset(
                  'assets/images/pink_splash.svg',
                  width: 112,
                  height: 112,
                  fit: BoxFit.contain,
                ),
                ClipOval(
                  child: Image.asset(
                    'assets/images/master_photo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              masterFullName,
              style: AppTextStyles.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              masterSpecialization,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildStatVertical('$masterRating', '★★★★★')),
                _buildDivider(),
                Expanded(
                  child: _buildStatVertical(
                    getYearsText(masterExperience),
                    'Опыта',
                  ),
                ),
                _buildDivider(),
                Expanded(
                  child: _buildStatVertical(masterReviews.toString(), 'Отзыва'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Записаться к $masterFirstNameDative',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatVertical(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: const Color.fromRGBO(128, 128, 128, 0.2),
    );
  }
}
