import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:pinput/pinput.dart';
import 'dependencies.dart';
import 'menu.dart';
import 'welcome.dart';
import 'widgets/widgets.dart';
import 'widgets/page_layout_helpers.dart';
import 'widgets/app_utils.dart';

class PhoneCodePage extends StatefulWidget {
  final String phoneNumber;
  final String masterId;

  const PhoneCodePage({
    super.key,
    required this.phoneNumber,
    required this.masterId,
  });

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

  Timer? _resendTimer;
  int _resendCountdown = 30;

  @override
  void initState() {
    super.initState();
    logger.info(
      '[PhoneCodePage] Initialized - phone: ${widget.phoneNumber}, masterId: ${widget.masterId}',
    );
    _loadMasterInfo();
    _startResendTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendCountdown = 30);

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
    setState(() => _isLoading = true);

    final repository = Dependencies.instance.masterRepository;
    final result = await repository.getMasterInfo(int.parse(widget.masterId));

    result.when(
      ok: (data) {
        if (mounted) {
          setState(() {
            _masterInfo = data;
            _isLoading = false;
          });
          logger.info('[PhoneCodePage] Master info loaded');
        }
      },
      err: (error, stackTrace) {
        logger.error('[PhoneCodePage] Error loading master: $error');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  Future<void> _checkClientStatusAndNavigate() async {
    logger.info('[PhoneCodePage] Navigating to WelcomePage');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomePage(
            masterId: widget.masterId,
            phoneNumber: widget.phoneNumber,
          ),
        ),
      );
    }
  }

  Future<void> _verifyCode(String code) async {
    if (code.length != 4) return;

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    logger.info('[PhoneCodePage] Verifying code: $code');

    try {
      final authRepository = Dependencies.instance.authRepository;
      final result = await authRepository.verifyCode<Client>(
        widget.phoneNumber,
        code,
        'web_polka_online',
      );

      result.when(
        ok: (authResult) {
          logger.info('[PhoneCodePage] Code verified successfully');
          Dependencies.instance.setTokens(authResult.tokens);

          if (mounted) {
            setState(() => _isVerifying = false);
            _checkClientStatusAndNavigate();
          }
        },
        err: (error, stackTrace) {
          logger.error('[PhoneCodePage] Code verification error: $error');

          if (mounted) {
            setState(() {
              _isVerifying = false;
              _errorText = parseError(error, stackTrace);
            });
          }
        },
      );
    } catch (e, st) {
      logger.error('[PhoneCodePage] Unexpected error: $e', e, st);
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorText = 'Произошла ошибка при проверке кода';
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (_isResending || _resendCountdown > 0) return;

    setState(() {
      _isResending = true;
      _errorText = null;
    });

    logger.info('[PhoneCodePage] Resending code to ${widget.phoneNumber}');

    final authRepository = Dependencies.instance.authRepository;
    final result = await authRepository.sendCode(widget.phoneNumber);

    result.when(
      ok: (_) {
        logger.info('[PhoneCodePage] Code resent successfully');

        _pinController.clear();
        _focusNode.requestFocus();
        _startResendTimer();

        if (mounted) {
          setState(() => _isResending = false);
          showSuccessSnackbar('Код отправлен повторно');
        }
      },
      err: (error, stackTrace) {
        logger.error('[PhoneCodePage] Resend error: $error');

        if (mounted) {
          setState(() {
            _isResending = false;
            _errorText = parseError(error, stackTrace);
          });
          showErrorSnackbar(parseError(error, stackTrace));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget();

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = LayoutHelper.isDesktopLayout(width);
    final showImage = LayoutHelper.shouldShowImage(width, isDesktop);
    final imageWidth = LayoutHelper.calculateImageWidth(
      screenWidth: width,
      showImage: showImage,
    );

    return PageScaffold(
      isDesktop: isDesktop,
      showImage: showImage,
      onMenuTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MenuPage()),
        );
      },
      onDownloadTap: StoreUtils.openStore,
      breadcrumbStep: 0,
      child: SingleChildScrollView(
        child: SafeArea(
          top: false,
          child: isDesktop
              ? _buildDesktopContent(
                  width: width,
                  height: height,
                  showImage: showImage,
                  imageWidth: imageWidth,
                )
              : _buildMobileContent(),
        ),
      ),
    );
  }

  Widget _buildDesktopContent({
    required double width,
    required double height,
    required bool showImage,
    required double imageWidth,
  }) {
    final master = _masterInfo?.master;

    return DesktopPageLayout(
      screenWidth: width,
      screenHeight: height,
      showImage: showImage,
      imageWidth: imageWidth,
      onDownloadTap: StoreUtils.openStore,
      leftContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 16),
          if (_pinController.text.length == 4 && !_isVerifying)
            SizedBox(
              width: double.infinity,
              child: AppTextButton.large(
                text: 'Отправить',
                onTap: () => _verifyCode(_pinController.text),
              ),
            ),
          const SizedBox(height: 24),
          _buildResendButton(),
          const SizedBox(height: 16),
          _buildSupportButton(context),
        ],
      ),
      rightCard: master != null
          ? DesktopMasterCard(
              fullName: master.fullName,
              specialization: master.profession,
              avatarUrl: master.avatarUrl,
              rating: master.rating,
              experience: master.experience,
              reviews: master.reviewsCount,
            )
          : null,
    );
  }

  Widget _buildMobileContent() {
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
        _buildResendButton(),
        const SizedBox(height: 16),
        _buildSupportButton(context),
      ],
    );
  }

  Widget _buildPinInput() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: AppTextStyles.headingMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundHover,
        borderRadius: BorderRadius.circular(14),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.backgroundHover,
        border: Border.all(color: AppColors.accent, width: 1),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.error, width: 1),
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
            focusedPinTheme: focusedPinTheme,
            errorPinTheme: errorPinTheme,
            onChanged: (value) => setState(() {}),
            onCompleted: (value) {
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
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_resendCountdown > 0) {
      return SizedBox(
        width: double.infinity,
        child: Text(
          'Отправить повторно через $_formattedCountdown',
          style: AppTextStyles.bodyLarge.copyWith(
            decoration: TextDecoration.underline,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _resendCode,
        child: Text(
          'Не пришел код?',
          style: AppTextStyles.bodyLarge.copyWith(
            decoration: TextDecoration.underline,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSupportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcons.chat.icon(context, size: 16),
              const SizedBox(width: 4),
              Text(
                'Нужна помощь? ',
                style: AppTextStyles.bodyLarge.copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          Text(
            '(Чат поддержки)',
            style: AppTextStyles.bodyLarge.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
