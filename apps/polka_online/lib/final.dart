import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'menu.dart';
import 'dependencies.dart';
import 'phone_code.dart';

// Максимальная ширина для welcome-иллюстрации во всех вьюх
const double kWelcomeImageMaxWidth = 430;
const double kMainContainerMaxWidth = 938;
const double kContainerImageGap = 40;

class FinalPage extends StatefulWidget {
  final String? masterId;

  const FinalPage({super.key, this.masterId});

  @override
  State<FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> {
  MasterInfo? _masterInfo;
  bool _isLoading = true;
  String? _error;
  late String _masterId;
  final _phoneNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    _masterId = widget.masterId ?? '1';
    _loadMasterInfo();
  }

  @override
  void dispose() {
    _phoneNotifier.dispose();
    super.dispose();
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
        setState(() {
          _masterInfo = data;
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

  void _openStore(BuildContext context) async {
    final url = Theme.of(context).platform == TargetPlatform.iOS
        ? 'https://apps.apple.com/app/polka-beauty-marketplace'
        : 'https://play.google.com/store/apps/details?id=com.mads.polkabeautymarketplace&hl=ru';
    try {
      await launchUrl(Uri.parse(url));
    } catch (e) {
      // ignore
    }
  }

  void _getCode() {
    if (_phoneNotifier.value.length == 10) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PhoneCodePage(phoneNumber: '7${_phoneNotifier.value}'),
        ),
      );
    }
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
    final isDesktop = width >= 750;
    final showImage = isDesktop && width >= 1120;

    // Рассчитываем ширину картинки
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
          // Верхняя панель
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
                            icon: const Icon(Icons.menu, size: 24),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MenuPage(),
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () => _openStore(context),
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

          Expanded(
            child: Container(
              color: isDesktop
                  ? AppColors.backgroundOnline
                  : AppColors.backgroundDefault,
              child: Stack(
                children: [
                  // Хлебные крошки
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
                            : _buildMobileLayout(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // Desktop layout
  // ================================

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
                  color: AppColors.backgroundSubtle,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.backgroundDefault,
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
                    // Left column - форма авторизации
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
                              'Отлично! Вы записаны',
                              style: AppTextStyles.headingLarge,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'А еще проще записаться через наше приложение, установите POLKA',
                              style: AppTextStyles.bodyMedium500.copyWith(
                                color: AppColors.iconsDefault,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Кнопка получить код - теперь на всю ширину поля
                            ValueListenableBuilder(
                              valueListenable: _phoneNotifier,
                              builder: (context, value, child) {
                                return AppTextButton.large(
                                  text: 'Установить POLKA',
                                  enabled: value.length == 10,
                                  onTap: _getCode,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: kContainerImageGap),

                    // Right column: master card
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: _buildDesktopMasterCard(context),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Illustration
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
                        onTap: () => _openStore(context),
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

  Widget _buildDesktopMasterCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      decoration: BoxDecoration(
        color: AppColors.backgroundOnline2,
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
          style: AppTextStyles.headingMedium,
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

  // ================================
  // Mobile layout
  // ================================

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Отлично! Вы записаны', style: AppTextStyles.headingLarge),
        const SizedBox(height: 16),
        Text(
          'А еще проще записаться через наше приложение, установите POLKA',
          style: AppTextStyles.bodyMedium500.copyWith(
            color: AppColors.iconsDefault,
          ),
        ),
        const SizedBox(height: 32),

        // Кнопка получить код
        SizedBox(
          width: double.infinity,
          child: ValueListenableBuilder(
            valueListenable: _phoneNotifier,
            builder: (context, value, child) {
              return AppTextButton.large(
                text: 'Установить POLKA',
                enabled: value.length == 10,
                onTap: _getCode,
              );
            },
          ),
        ),
      ],
    );
  }
}
