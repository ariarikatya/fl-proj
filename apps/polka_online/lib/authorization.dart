import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'menu.dart';
import 'dependencies.dart';
import 'phone_code.dart';
import 'widgets/widgets.dart';
import 'widgets/page_layout_helpers.dart';
import 'widgets/app_utils.dart';

class AuthorizationPage extends StatefulWidget {
  final String? masterId;

  const AuthorizationPage({super.key, this.masterId});

  @override
  State<AuthorizationPage> createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  MasterInfo? _masterInfo;
  bool _isLoading = true;
  String? _error;
  late String _masterId;
  final _phoneNotifier = ValueNotifier<String>('');
  bool _isSendingCode = false;

  @override
  void initState() {
    super.initState();
    _masterId = widget.masterId ?? Dependencies.getMasterIdFromUrl() ?? '1';
    logger.info('[AuthorizationPage] Initializing with masterId: $_masterId');
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

    try {
      final repository = Dependencies.instance.masterRepository;
      final masterId = int.tryParse(_masterId);

      if (masterId == null) {
        throw Exception('Неверный ID мастера: $_masterId');
      }

      final result = await repository.getMasterInfo(masterId);

      result.when(
        ok: (data) {
          if (mounted) {
            setState(() {
              _masterInfo = data;
              _isLoading = false;
            });
            logger.info(
              '[AuthorizationPage] Master info loaded: ${data.master.fullName}',
            );
          }
        },
        err: (error, stackTrace) {
          logger.error('[AuthorizationPage] Error loading master info: $error');
          if (mounted) {
            setState(() {
              _error = _formatError(error, stackTrace);
              _isLoading = false;
            });
          }
        },
      );
    } catch (e, st) {
      logger.error('[AuthorizationPage] Unexpected error: $e', e, st);
      if (mounted) {
        setState(() {
          _error = _formatError(e, st);
          _isLoading = false;
        });
      }
    }
  }

  String _formatError(Object error, StackTrace? stackTrace) {
    final errorMsg = parseError(error, stackTrace);

    if (errorMsg.contains('connection') || errorMsg.contains('network')) {
      return 'Не удалось подключиться к серверу.\nПроверьте подключение к интернету.';
    }
    if (errorMsg.contains('timeout')) {
      return 'Превышено время ожидания.\nПопробуйте ещё раз.';
    }
    if (errorMsg.contains('404')) {
      return 'Мастер не найден.\nПроверьте правильность ссылки.';
    }

    return errorMsg;
  }

  Future<void> openStore() => StoreUtils.openStore();

  Future<void> _sendCode() async {
    if (_phoneNotifier.value.length != 10) {
      logger.warning(
        '[AuthorizationPage] Invalid phone length: ${_phoneNotifier.value}',
      );
      showErrorSnackbar('Введите корректный номер телефона');
      return;
    }

    final phoneNumber = '7${_phoneNotifier.value}';
    logger.info('[AuthorizationPage] Sending code to: $phoneNumber');

    setState(() => _isSendingCode = true);

    try {
      final authRepository = Dependencies.instance.authRepository;
      final result = await authRepository.sendCode(phoneNumber);

      setState(() => _isSendingCode = false);

      result.when(
        ok: (_) {
          logger.info('[AuthorizationPage] Code sent successfully');
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhoneCodePage(
                  phoneNumber: phoneNumber,
                  masterId: _masterId,
                ),
              ),
            );
          }
        },
        err: (error, stackTrace) {
          logger.error('[AuthorizationPage] Error sending code: $error');
          showErrorSnackbar(parseError(error, stackTrace));
        },
      );
    } catch (e, st) {
      logger.error(
        '[AuthorizationPage] Unexpected error sending code: $e',
        e,
        st,
      );
      setState(() => _isSendingCode = false);
      showErrorSnackbar('Произошла ошибка при отправке кода');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null || _masterInfo == null) {
      logger.error('[AuthorizationPage] Showing error state: $_error');
      return ErrorStateWidget(error: _error, onRetry: _loadMasterInfo);
    }

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
      onDownloadTap: openStore,
      breadcrumbStep: 0,
      child: isDesktop
          ? SingleChildScrollView(
              child: SafeArea(
                top: false,
                child: _buildDesktopContent(
                  width: width,
                  height: height,
                  showImage: showImage,
                  imageWidth: imageWidth,
                ),
              ),
            )
          : _buildMobileContent(),
    );
  }

  Widget _buildDesktopContent({
    required double width,
    required double height,
    required bool showImage,
    required double imageWidth,
  }) {
    final master = _masterInfo!.master;

    return DesktopPageLayout(
      screenWidth: width,
      screenHeight: height,
      showImage: showImage,
      imageWidth: imageWidth,
      onDownloadTap: openStore,
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
          AppPhoneTextField(notifier: _phoneNotifier),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: _phoneNotifier,
            builder: (context, value, child) {
              return AppTextButton.large(
                text: _isSendingCode ? 'Отправка...' : 'Получить код',
                enabled: value.length == 10 && !_isSendingCode,
                onTap: _sendCode,
              );
            },
          ),
        ],
      ),
      rightCard: DesktopMasterCard(
        fullName: master.fullName,
        specialization: master.profession,
        avatarUrl: master.avatarUrl,
        rating: master.rating,
        experience: master.experience,
        reviews: master.reviewsCount,
      ),
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
        AppPhoneTextField(notifier: _phoneNotifier),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ValueListenableBuilder(
            valueListenable: _phoneNotifier,
            builder: (context, value, child) {
              return AppTextButton.large(
                text: _isSendingCode ? 'Отправка...' : 'Получить код',
                enabled: value.length == 10 && !_isSendingCode,
                onTap: _sendCode,
              );
            },
          ),
        ),
      ],
    );
  }
}
