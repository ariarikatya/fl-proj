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
        logger.error('Ошибка загрузки информации о мастере: $error');
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  Future<void> openStore() => StoreUtils.openStore();

  void _getCode() {
    if (_phoneNotifier.value.length == 10) {
      final phoneNumber = '7${_phoneNotifier.value}';
      logger.debug('Sending to PhoneCodePage - phone: $phoneNumber');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PhoneCodePage(phoneNumber: phoneNumber, masterId: _masterId),
        ),
      );
    } else {
      logger.warning(
        'Некорректная длина номера телефона: ${_phoneNotifier.value}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null || _masterInfo == null) {
      logger.error('Ошибка отображения страницы авторизации: $_error');
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

    logger.debug(
      'Building AuthorizationPage - width: $width, isDesktop: $isDesktop, showImage: $showImage, imageWidth: $imageWidth',
    );

    return PageScaffold(
      isDesktop: isDesktop,
      showImage: showImage,
      onMenuTap: () {
        logger.debug('Opening menu page');
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
                text: 'Получить код',
                enabled: value.length == 10,
                onTap: _getCode,
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
                text: 'Получить код',
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
