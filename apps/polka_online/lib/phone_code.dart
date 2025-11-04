import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared/shared.dart';
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dependencies.dart';
import 'menu.dart';
import 'service.dart';

const double kWelcomeImageMaxWidth = 430;
const double kMainContainerMaxWidth = 938;
const double kContainerImageGap = 40;

class PhoneCodePage extends StatefulWidget {
  final String phoneNumber;

  const PhoneCodePage({super.key, required this.phoneNumber});

  @override
  State<PhoneCodePage> createState() => _PhoneCodePageState();
}

class _PhoneCodePageState extends State<PhoneCodePage> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorText;
  MasterInfo? _masterInfo;
  bool _isLoading = true;

  // Таймер для повторной отправки кода
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _loadMasterInfo();
    _startResendTimer(); // Запускаем таймер при открытии страницы
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 30;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String get _formattedCountdown {
    final minutes = _resendCountdown ~/ 60;
    final seconds = _resendCountdown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadMasterInfo() async {
    setState(() {
      _isLoading = true;
    });

    final repository = Dependencies.instance.masterRepository;
    final result = await repository.getMasterInfo(1);

    result.when(
      ok: (data) {
        setState(() {
          _masterInfo = data;
          _isLoading = false;
        });
      },
      err: (error, stackTrace) {
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  String get masterFullName => _masterInfo?.master.fullName ?? '';
  String get masterSpecialization => _masterInfo?.master.profession ?? '';
  double get masterRating => _masterInfo?.master.rating ?? 0.0;
  String get masterExperience => _masterInfo?.master.experience ?? '';
  int get masterReviews => _masterInfo?.master.reviewsCount ?? 0;
  String get masterAvatarUrl => _masterInfo?.master.avatarUrl ?? '';

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

  String get formattedPhoneNumber {
    if (widget.phoneNumber.length >= 11) {
      final code = widget.phoneNumber.substring(1, 4);
      final part1 = widget.phoneNumber.substring(4, 7);
      final part2 = widget.phoneNumber.substring(7, 9);
      final part3 = widget.phoneNumber.substring(9);
      return '+7 ($code) $part1-$part2-$part3';
    }
    return widget.phoneNumber;
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

  Future<void> _verifyCode(String code) async {
    if (code.length != 4) return;

    // Специальный код для входа без проверки
    if (code == '0942') {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ServicePage()),
        );
      }
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    final authRepository = Dependencies.instance.authRepository;
    final result = await authRepository.verifyCode<Client>(
      widget.phoneNumber,
      code,
      'web_simulator_udid',
    );

    result.when(
      ok: (authResult) {
        logger.info('code verified successfully');

        if (mounted) {
          setState(() => _isVerifying = false);

          // Переход на ServicePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ServicePage()),
          );
        }
      },
      err: (error, stackTrace) {
        logger.error('code verification error', error, stackTrace);

        if (mounted) {
          setState(() {
            _isVerifying = false;
            _errorText = parseError(error, stackTrace);
          });
        }
      },
    );
  }

  Future<void> _resendCode() async {
    if (_isResending || _resendCountdown > 0) return;

    setState(() {
      _isResending = true;
      _errorText = null;
    });

    logger.debug('resending code to ${widget.phoneNumber}');

    final authRepository = Dependencies.instance.authRepository;
    final result = await authRepository.sendCode(widget.phoneNumber);

    result.when(
      ok: (_) {
        logger.info('code resent successfully');

        _pinController.clear();
        _focusNode.requestFocus();
        _startResendTimer(); // Перезапускаем таймер

        if (mounted) {
          setState(() => _isResending = false);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Код отправлен повторно'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      err: (error, stackTrace) {
        logger.error('resend code error', error, stackTrace);

        if (mounted) {
          setState(() {
            _isResending = false;
            _errorText = parseError(error, stackTrace);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(parseError(error, stackTrace)),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
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
                                        style: AppTextStyles.bodyLarge,
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

  Widget _buildPinInput() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: AppTextStyles.headingMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundOnlineMain,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.backgroundOnlineMain),
      ),
    );

    return Column(
      children: [
        Center(
          child: Pinput(
            controller: _pinController,
            focusNode: _focusNode,
            length: 4,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration!.copyWith(
                border: Border.all(color: AppColors.accent, width: 2),
              ),
            ),
            errorPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration!.copyWith(
                border: Border.all(color: AppColors.error, width: 2),
              ),
            ),
            onChanged: (value) => setState(() {}),
            onCompleted: (value) {
              // В мобильной версии автоматически отправляем код при заполнении
              if (MediaQuery.of(context).size.width < 750) {
                _verifyCode(value);
              }
            },
            autofocus: true,
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],
        if (_isVerifying) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ],
    );
  }

  Widget _buildResendButton() {
    if (_isResending) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_resendCountdown > 0) {
      return Text(
        'Отправить повторно через $_formattedCountdown',
        style: AppTextStyles.bodyLarge.copyWith(
          decoration: TextDecoration.underline,
        ),
      );
    }

    return GestureDetector(
      onTap: _resendCode,
      child: Text(
        'Не пришел код?',
        style: AppTextStyles.bodyLarge.copyWith(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildResendButtonMobile() {
    if (_isResending) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_resendCountdown > 0) {
      return Text(
        'Отправить повторно через $_formattedCountdown',
        style: AppTextStyles.bodyLarge.copyWith(
          decoration: TextDecoration.underline,
        ),
        textAlign: TextAlign.center,
      );
    }

    return GestureDetector(
      onTap: _resendCode,
      child: Text(
        'Отправить код',
        style: AppTextStyles.bodyLarge.copyWith(
          decoration: TextDecoration.underline,
        ),
        textAlign: TextAlign.center,
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
                              'Введите номер телефона',
                              style: AppTextStyles.headingLarge,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'И мы пришлем на него код, чтобы Вы могли авторизоваться и записаться на услугу',
                              style: AppTextStyles.bodyMedium500.copyWith(
                                color: AppColors.iconsDefault,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildPinInput(),
                            const SizedBox(height: 16),
                            // Показываем кнопку только если код заполнен и нет верификации
                            if (_pinController.text.length == 4 &&
                                !_isVerifying)
                              SizedBox(
                                width: double.infinity,
                                child: AppTextButton.large(
                                  text: 'Отправить',
                                  onTap: () => _verifyCode(_pinController.text),
                                ),
                              ),
                            const SizedBox(height: 24),
                            Center(child: _buildResendButton()),
                            const SizedBox(height: 16),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppIcons.support.icon(context, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Нужна помощь? (Чат поддержки)',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Введите номер телефона', style: AppTextStyles.headingLarge),
        const SizedBox(height: 16),
        Text(
          'И мы пришлем на него код, чтобы Вы могли авторизоваться и записаться на услугу',
          style: AppTextStyles.bodyMedium500.copyWith(
            color: AppColors.iconsDefault,
          ),
        ),
        const SizedBox(height: 32),
        _buildPinInput(),
        const SizedBox(height: 24),
        Center(child: _buildResendButtonMobile()),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcons.support.icon(context, size: 16),
              const SizedBox(width: 4),
              Text(
                'Нужна помощь? (Чат поддержки)',
                style: AppTextStyles.bodyLarge.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
