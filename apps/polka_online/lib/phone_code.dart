import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared/shared.dart';
import 'package:pinput/pinput.dart';
import 'dependencies.dart';

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

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get formattedPhoneNumber {
    // Форматируем номер телефона: +7 (XXX) XXX-XX-XX
    if (widget.phoneNumber.length >= 11) {
      final code = widget.phoneNumber.substring(1, 4);
      final part1 = widget.phoneNumber.substring(4, 7);
      final part2 = widget.phoneNumber.substring(7, 9);
      final part3 = widget.phoneNumber.substring(9);
      return '+7 ($code) $part1-$part2-$part3';
    }
    return widget.phoneNumber;
  }

  Future<void> _verifyCode(String code) async {
    if (code.length != 4) return;

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    // Проверяем код через API
    final authRepository = Dependencies.instance.authRepository;
    final result = await authRepository.verifyCode(
      widget.phoneNumber,
      code,
      'web_simulator_udid', // Для веб-симулятора используем фиксированный UDID
    );

    result.when(
      ok: (authResult) {
        // Код верный - переходим на следующий экран
        print('Код подтвержден: $code');
        print('Номер телефона: ${widget.phoneNumber}');
        print('Auth result: $authResult');

        if (mounted) {
          setState(() => _isVerifying = false);

          // Показываем успех
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Код подтвержден! Добро пожаловать в POLKA'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );

          // TODO: Переход на следующий экран после успешной авторизации
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextPage()));
        }
      },
      err: (error, stackTrace) {
        // Ошибка проверки кода
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
    if (_isResending) return;

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

        // Очищаем поле ввода
        _pinController.clear();
        _focusNode.requestFocus();

        if (mounted) {
          setState(() => _isResending = false);

          // Показываем сообщение пользователю
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

          // Показываем ошибку
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
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 24),
                          onPressed: () => Navigator.pop(context),
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
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
      ),
    );

    return Column(
      children: [
        Pinput(
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
          onCompleted: _verifyCode,
          autofocus: true,
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
        ],
        if (_isVerifying) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 64,
                  vertical: 64,
                ),
                child: Center(
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
                          'Введите код из СМС',
                          style: AppTextStyles.headingLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Мы отправили код на номер $formattedPhoneNumber',
                          style: AppTextStyles.bodyMedium500.copyWith(
                            color: AppColors.iconsDefault,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildPinInput(),
                        const SizedBox(height: 24),
                        Center(
                          child: _isResending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : AppLinkButton(
                                  text: 'Отправить код повторно',
                                  onTap: _resendCode,
                                ),
                        ),
                      ],
                    ),
                  ),
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
                child: Container(
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
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Введите код из СМС', style: AppTextStyles.headingLarge),
        const SizedBox(height: 16),
        Text(
          'Мы отправили код на номер $formattedPhoneNumber',
          style: AppTextStyles.bodyMedium500.copyWith(
            color: AppColors.iconsDefault,
          ),
        ),
        const SizedBox(height: 32),
        _buildPinInput(),
        const SizedBox(height: 24),
        Center(
          child: _isResending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : AppLinkButton(
                  text: 'Отправить код повторно',
                  onTap: _resendCode,
                ),
        ),
      ],
    );
  }
}
