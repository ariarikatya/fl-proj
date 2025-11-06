import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'menu.dart';
import 'final.dart';
import 'package:flutter/foundation.dart';

const double kWelcomeImageMaxWidth = 430;
const double kMainContainerMaxWidth = 938;
const double kContainerImageGap = 40;

class EndBookingPage extends StatefulWidget {
  final MasterInfo masterInfo;
  final AvailableSlot selectedSlot;
  final Service service;
  final String? phoneNumber;

  const EndBookingPage({
    super.key,
    required this.masterInfo,
    required this.selectedSlot,
    required this.service,
    this.phoneNumber,
  });

  @override
  State<EndBookingPage> createState() => _EndBookingPageState();
}

class _EndBookingPageState extends State<EndBookingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _goBack() {
    Navigator.pop(context);
  }

  // бар в мобилке
  Widget _buildMobileProgressBar() {
    return Container(
      height: 48,
      color: AppColors.backgroundDefault,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBack,
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

  MasterInfo get masterInfo => widget.masterInfo;
  AvailableSlot get selectedSlot => widget.selectedSlot;
  Service get service => widget.service;

  String get masterFirstName => masterInfo.master.firstName;
  String get masterFullName => masterInfo.master.fullName;
  String get masterSpecialization => masterInfo.master.profession;
  double get masterRating => masterInfo.master.rating;
  String get masterExperience => masterInfo.master.experience;
  int get masterReviews => masterInfo.master.reviewsCount;
  String get masterAvatarUrl => masterInfo.master.avatarUrl;

  String getYearsText(String experience) {
    final years = int.tryParse(experience.split(' ').first) ?? 0;
    if (years % 10 == 1 && years % 100 != 11) {
      return '$years год';
    }
    if ([2, 3, 4].contains(years % 10) && ![12, 13, 14].contains(years % 100)) {
      return '$years года';
    }
    return '$years лет';
  }

  Future<void> openStore() async {
    String url;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      url = 'https://apps.apple.com/app/polka-beauty-marketplace';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      url = 'https://apps.apple.com/app/id6740820071';
    } else {
      url =
          'https://play.google.com/store/apps/details?id=com.mads.polkabeautymarketplace&hl=ru';
    }

    final uri = Uri.parse(url);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // ignore: empty_catches
      }
    } catch (e) {
      // ignore: empty_catches
    }
  }

  void _submitBooking() {
    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();
    final selectedTime = DateFormat('HH:mm').format(selectedSlot.datetime);

    if (name.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinalPage(
            masterId: masterInfo.master.id.toString(),
            service: service,
            selectedDate: selectedSlot.date,
            selectedTime: selectedTime,
            name: name,
            comment: comment,
            phoneNumber: widget.phoneNumber ?? '',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите имя')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 750;
    final showImage = isDesktop && width >= 1120;

    double imageWidth = kWelcomeImageMaxWidth;
    if (showImage) {
      final fullContent =
          kMainContainerMaxWidth + kContainerImageGap + kWelcomeImageMaxWidth;
      if (width < fullContent) {
        final denom = (kWelcomeImageMaxWidth - 50);
        final t = denom > 0
            ? ((width - (kMainContainerMaxWidth + kContainerImageGap) - 50) /
                      denom)
                  .clamp(0.0, 1.0)
            : 1.0;
        imageWidth = 50 + (kWelcomeImageMaxWidth - 50) * t;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      body: Column(
        children: [
          Container(
            height: 88,
            color: AppColors.backgroundDefault,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
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
                            icon: AppIcons.menu.icon(
                              context,
                              size: 24,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MenuPage(),
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: openStore,
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
          ),

          // бар для мобилки
          if (!isDesktop) _buildMobileProgressBar(),

          Expanded(
            child: Container(
              color: isDesktop
                  ? AppColors.backgroundOnline
                  : AppColors.backgroundDefault,
              child: Stack(
                children: [
                  if (isDesktop)
                    Positioned(
                      top: 28,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final contentWidth = showImage
                                ? kMainContainerMaxWidth +
                                      kContainerImageGap +
                                      kWelcomeImageMaxWidth
                                : kMainContainerMaxWidth;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: contentWidth.clamp(
                                      0.0,
                                      constraints.maxWidth,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Авторизация',
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: AppColors.textPlaceholder,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      AppIcons.chevronForward.icon(
                                        context,
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
                                      AppIcons.chevronForward.icon(
                                        context,
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
                                      AppIcons.chevronForward.icon(
                                        context,
                                        size: 16,
                                        color: AppColors.textPlaceholder,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Персональные данные',
                                        style: AppTextStyles.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                  Padding(
                    padding: EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      top: isDesktop ? 88.0 : 16.0,
                      bottom: 24.0,
                    ),
                    child: SingleChildScrollView(
                      child: SafeArea(
                        top: false,
                        child: isDesktop
                            ? _buildDesktopLayout(
                                context,
                                showImage,
                                imageWidth,
                              )
                            : _buildMobileContent(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!isDesktop)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppTextButton.large(
                text: 'Записаться к мастеру',
                enabled: _nameController.text.trim().isNotEmpty,
                onTap: _submitBooking,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    bool showImage,
    double imageWidth,
  ) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final availableHeight = height - 88 - 88 - 70;

    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: kMainContainerMaxWidth,
              ),
              child: Container(
                constraints: BoxConstraints(minHeight: availableHeight),
                decoration: BoxDecoration(
                  color: AppColors.backgroundOnlineMain,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.backgroundOnlineMain,
                    width: 1,
                  ),
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
                padding: const EdgeInsets.only(
                  left: 64,
                  top: 64,
                  bottom: 64,
                  right: 40,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: width >= 1400
                              ? 420
                              : (width >= 1200 ? 400 : 360),
                          maxWidth: 640,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Давайте познакомимся!',
                              style: AppTextStyles.headingLarge,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Оставьте Ваше имя и комментарий, чтобы мы могли добавить Вас в расписание к мастеру',
                              style: AppTextStyles.bodyMedium500.copyWith(
                                color: AppColors.iconsDefault,
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppTextFormField(
                              controller: _nameController,
                              labelText: 'Ваше имя и фамилия',
                            ),
                            const SizedBox(height: 16),
                            AppTextFormField(
                              controller: _commentController,
                              labelText:
                                  'Комментарий, например, аллергия на коллаген',
                              maxLines: 4,
                            ),
                            const SizedBox(height: 32),
                            AppTextButton.large(
                              text: 'Записаться к мастеру',
                              enabled: _nameController.text.trim().isNotEmpty,
                              onTap: _submitBooking,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: kContainerImageGap),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _buildDesktopMasterCard(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showImage) ...[
            const SizedBox(width: kContainerImageGap),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: imageWidth),
              child: SizedBox(
                height: availableHeight,
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopMasterCard(BuildContext context) {
    return Container(
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
          padding: const EdgeInsets.only(
            left: 24,
            top: 24,
            bottom: 24,
            right: 24,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(child: _buildMasterLeftColumn(context)),
              const SizedBox(width: 20),
              _buildMasterRightColumn(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasterLeftColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/pink_splash.svg',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
            ),
            ClipOval(
              child: masterAvatarUrl.isNotEmpty
                  ? Image.network(
                      masterAvatarUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/master_photo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          masterFullName,
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        Text(
          masterSpecialization,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMasterRightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatItem(
          context,
          masterRating.toStringAsFixed(1),
          'Рейтинг',
          showStar: true,
        ),
        Container(height: 1, width: 100, color: AppColors.backgroundHover),
        _buildStatItem(context, getYearsText(masterExperience), 'Опыта'),
        Container(height: 1, width: 100, color: AppColors.backgroundHover),
        _buildStatItem(context, masterReviews.toString(), 'Отзыва'),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label, {
    bool showStar = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
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

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Давайте познакомимся!', style: AppTextStyles.headingLarge),
        const SizedBox(height: 16),
        Text(
          'Оставьте Ваше имя и комментарий, чтобы мы могли добавить Вас в расписание к мастеру',
          style: AppTextStyles.bodyMedium500.copyWith(
            color: AppColors.iconsDefault,
          ),
        ),
        const SizedBox(height: 24),
        AppTextFormField(
          controller: _nameController,
          labelText: 'Ваше имя и фамилия',
        ),
        const SizedBox(height: 16),
        AppTextFormField(
          controller: _commentController,
          labelText: 'Комментарий, например, аллергия на коллаген',
          maxLines: 4,
        ),
      ],
    );
  }
}
