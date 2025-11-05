import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'menu.dart';
import 'dependencies.dart';
import 'slots.dart';
import 'package:flutter/foundation.dart';
import 'welcome.dart';

const double kWelcomeImageMaxWidth = 430;
const double kMainContainerMaxWidth = 938;
const double kContainerImageGap = 40;
const double kDesktopServiceMasterGap = 64;
const double kDesktopServiceMasterGapMin = 40;

class ServicePage extends StatefulWidget {
  final String? masterId;
  final String? phoneNumber;

  const ServicePage({super.key, this.masterId, this.phoneNumber});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  MasterInfo? _masterInfo;
  bool _isLoading = true;
  String? _error;
  late String _masterId;
  Service? _selectedService;

  @override
  void initState() {
    super.initState();
    _masterId = widget.masterId ?? '1';
    _loadMasterInfo();
  }

  Future<void> _loadMasterInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repository = Dependencies.instance.masterRepository;
    final result = await repository.getMasterInfo(int.parse(_masterId));

    result.when(
      ok: (data) {
        final mockServices = [
          Service(
            id: 1,
            category: ServiceCategories.nailService,
            title: 'Маникюр классический',
            duration: const Duration(minutes: 60),
            description: '',
            location: ServiceLocation.studio,
            resultPhotos: [],
            price: 1200,
          ),
          Service(
            id: 2,
            category: ServiceCategories.nailService,
            title: 'Педикюр Spa',
            duration: const Duration(minutes: 90),
            description: '',
            location: ServiceLocation.studio,
            resultPhotos: [],
            price: 2000,
          ),
          Service(
            id: 3,
            category: ServiceCategories.other,
            title: 'Массаж спины',
            duration: const Duration(minutes: 45),
            description: '',
            location: ServiceLocation.studio,
            resultPhotos: [],
            price: 1500,
          ),
        ];
        _masterInfo = data.copyWith(services: () => mockServices);
        setState(() {
          _isLoading = false;
        });
      },
      err: (error, stackTrace) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  String get masterFirstName => _masterInfo?.master.firstName ?? '';
  String get masterFullName => _masterInfo?.master.fullName ?? '';
  String get masterSpecialization => _masterInfo?.master.profession ?? '';
  double get masterRating => _masterInfo?.master.rating ?? 0.0;
  String get masterExperience => _masterInfo?.master.experience ?? '';
  int get masterReviews => _masterInfo?.master.reviewsCount ?? 0;
  String get masterAvatarUrl => _masterInfo?.master.avatarUrl ?? '';

  String get masterFirstNameDative {
    final name = masterFirstName;
    if (name.endsWith('я')) {
      return '${name.substring(0, name.length - 1)}е';
    }
    return name;
  }

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
        // Logger().warning('Не удалось открыть магазин: $url');
      }
    } catch (e) {
      // Logger().error('Ошибка при открытии магазина: $e');
    }
  }

  void _selectTime() {
    if (_selectedService != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlotsPage(
            service: _selectedService!,
            masterId: _masterInfo!.master.id.toString(),
            phoneNumber: widget.phoneNumber,
          ),
        ),
      );
    }
  }

  void _goBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDefault,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _masterInfo == null) {
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
                  _error ?? 'Неизвестная ошибка',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadMasterInfo,
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 790;
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
          // бар с логотипом
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
                            icon: AppIcons.filter.icon(context, size: 24),
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
                                        style: AppTextStyles.bodyLarge,
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
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: AppColors.textPlaceholder,
                                        ),
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
                      bottom: isDesktop ? 24.0 : 0.0,
                    ),
                    child: isDesktop
                        ? SingleChildScrollView(
                            child: SafeArea(
                              top: false,
                              child: _buildDesktopLayout(
                                context,
                                showImage,
                                imageWidth,
                                width,
                              ),
                            ),
                          )
                        : _buildMobileLayout(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Виджет бара для мобилки
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

  Widget _buildDesktopLayout(
    BuildContext context,
    bool showImage,
    double imageWidth,
    double screenWidth,
  ) {
    final height = MediaQuery.of(context).size.height;
    final availableHeight = height - 88 - 88 - 70;

    final double serviceMasterGap = _calculateServiceMasterGap(screenWidth);

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
                          minWidth: screenWidth >= 1400
                              ? 420
                              : (screenWidth >= 1200 ? 400 : 360),
                          maxWidth: 640,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Выберите услугу',
                              style: AppTextStyles.headingLarge,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Здесь представлены все услуги мастера, выберите услугу и нажмите "Далее"',
                              style: AppTextStyles.bodyMedium500.copyWith(
                                color: AppColors.iconsDefault,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ...(_masterInfo?.services.isNotEmpty ?? false
                                    ? _masterInfo!.services
                                    : [
                                        Service(
                                          id: 1,
                                          category:
                                              ServiceCategories.nailService,
                                          title: 'Маникюр классический',
                                          duration: const Duration(minutes: 60),
                                          description: '',
                                          location: ServiceLocation.studio,
                                          resultPhotos: [],
                                          price: 1200,
                                        ),
                                        Service(
                                          id: 2,
                                          category:
                                              ServiceCategories.nailService,
                                          title: 'Педикюр Spa',
                                          duration: const Duration(minutes: 90),
                                          description: '',
                                          location: ServiceLocation.studio,
                                          resultPhotos: [],
                                          price: 2000,
                                        ),
                                        Service(
                                          id: 3,
                                          category: ServiceCategories.other,
                                          title: 'Массаж спины',
                                          duration: const Duration(minutes: 45),
                                          description: '',
                                          location: ServiceLocation.studio,
                                          resultPhotos: [],
                                          price: 1500,
                                        ),
                                      ])
                                .map(
                                  (service) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _ServiceCard(
                                      service: service,
                                      isSelected: _selectedService == service,
                                      onTap: () => setState(
                                        () => _selectedService = service,
                                      ),
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 24),
                            AppTextButton.large(
                              text: 'Далее',
                              enabled: _selectedService != null,
                              onTap: _selectTime,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: serviceMasterGap),
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
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0x0C0C0D0D,
                            ).withValues(alpha: 0.05),
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                            spreadRadius: -4,
                          ),
                          BoxShadow(
                            color: const Color(
                              0x0C0C0D0D,
                            ).withValues(alpha: 0.10),
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
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: GestureDetector(
                        onTap: openStore,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.backgroundDefault,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0x0C0C0D0D,
                                ).withValues(alpha: 0.05),
                                offset: const Offset(0, 4),
                                blurRadius: 4,
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: const Color(
                                  0x0C0C0D0D,
                                ).withValues(alpha: 0.10),
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
            ),
          ],
        ],
      ),
    );
  }

  double _calculateServiceMasterGap(double screenWidth) {
    const double minWidthForMaxGap = 1400;
    const double startReducingWidth = 1200;

    if (screenWidth >= minWidthForMaxGap) {
      return kDesktopServiceMasterGap;
    } else if (screenWidth <= startReducingWidth) {
      return kDesktopServiceMasterGapMin;
    } else {
      final double t =
          (screenWidth - startReducingWidth) /
          (minWidthForMaxGap - startReducingWidth);
      return kDesktopServiceMasterGapMin +
          (kDesktopServiceMasterGap - kDesktopServiceMasterGapMin) * t;
    }
  }

  Widget _buildDesktopMasterCard(BuildContext context) {
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
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/master_photo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
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
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
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

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Выберите услугу', style: AppTextStyles.headingLarge),
                const SizedBox(height: 16),
                Text(
                  'Здесь представлены все услуги мастера, выберите услугу и нажмите "Далее"',
                  style: AppTextStyles.bodyMedium500.copyWith(
                    color: AppColors.iconsDefault,
                  ),
                ),
                const SizedBox(height: 32),

                if (_masterInfo?.services.isNotEmpty ?? false)
                  ..._masterInfo!.services.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ServiceCard(
                        service: service,
                        isSelected: _selectedService == service,
                        onTap: () => setState(() => _selectedService = service),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundHover,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'У мастера пока нет доступных услуг',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: AppTextButton.large(
              text: 'Далее',
              enabled: _selectedService != null,
              onTap: _selectTime,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  final Service service;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentLight : AppColors.backgroundHover,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppIcons.clock.icon(
                        context,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.duration.inMinutes} мин',
                        style: AppTextStyles.bodyLarge500.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '|',
                        style: AppTextStyles.bodyLarge500.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '₽${service.price}',
                        style: AppTextStyles.bodyLarge500.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            isSelected
                ? AppIcons.radioChecked.icon(
                    context,
                    size: 24,
                    color: AppColors.accent,
                  )
                : AppIcons.radioUnchecked.icon(
                    context,
                    size: 24,
                    color: AppColors.borderDefault,
                  ),
          ],
        ),
      ),
    );
  }
}
