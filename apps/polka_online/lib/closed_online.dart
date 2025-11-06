import 'package:flutter/material.dart';
import 'package:polka_online/authorization.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'menu.dart';
import 'dependencies.dart';
import 'widgets/widgets.dart';
import 'widgets/page_layout_helpers.dart';

class ClosedPage extends StatefulWidget {
  final String? masterId;

  const ClosedPage({super.key, this.masterId});

  @override
  State<ClosedPage> createState() => _ClosedPageState();
}

class _ClosedPageState extends State<ClosedPage> {
  MasterInfo? _masterInfo;
  bool _isLoading = true;
  String? _error;
  late String _masterId;

  @override
  void initState() {
    super.initState();
    _masterId = widget.masterId ?? '1';
    logger.debug('Initializing ClosedPage - masterId: $_masterId');
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
        setState(() {
          _masterInfo = data;
          _isLoading = false;
        });
        logger.debug(
          'Master info loaded successfully for masterId: $_masterId',
        );
      },
      err: (error, stackTrace) {
        logger.error(
          'Error loading master info for masterId $_masterId: $error',
        );
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
    );
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
        logger.warning('Не удалось открыть магазин: $url');
      } else {
        logger.debug('Store opened successfully: $url');
      }
    } catch (e) {
      logger.error('Ошибка при открытии магазина: $e');
    }
  }

  void _openBooking() {
    logger.debug('Navigating to AuthorizationPage from ClosedPage');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AuthorizationPage()),
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
      logger.error('Error displaying ClosedPage: $_error');
      return _buildErrorState();
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
      'Building ClosedPage - width: $width, height: $height, isDesktop: $isDesktop, showImage: $showImage, imageWidth: $imageWidth',
    );

    return PageScaffold(
      isDesktop: isDesktop,
      showImage: showImage,
      onMenuTap: () {
        logger.debug('Opening menu page from ClosedPage');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MenuPage()),
        );
      },
      onDownloadTap: () {
        logger.debug('Opening store from ClosedPage header');
        openStore();
      },
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

    logger.debug(
      'Building desktop content for ClosedPage - master: ${master.fullName}, avatarUrl: ${master.avatarUrl}',
    );

    if (master.avatarUrl.isEmpty) {
      logger.warning(
        'Master avatar URL is empty for master: ${master.fullName}',
      );
    }

    return DesktopPageLayout(
      screenWidth: width,
      screenHeight: height,
      showImage: showImage,
      imageWidth: imageWidth,
      onDownloadTap: () {
        logger.debug('Opening store from ClosedPage image overlay');
        openStore();
      },
      imageOverlayText: 'Установи POLKA\nи найди своего\nмастера',
      showImageOverlay: true,
      leftContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'У мастера установлена закрытая запись',
            style: AppTextStyles.headingLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Вас нет в клиентской базе мастера, поэтому запись недоступна. Если это не так, то, пожалуйста, попросите мастера добавить вас в клиентскую базу в приложении POLKA',
            style: AppTextStyles.bodyMedium500.copyWith(
              color: AppColors.iconsDefault,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 280,
            child: AppTextButton.large(
              text: 'Скачать POLKA',
              onTap: () {
                logger.debug('Download POLKA button tapped in ClosedPage');
                _openBooking();
              },
            ),
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
    final master = _masterInfo!.master;

    logger.debug(
      'Building mobile content for ClosedPage - master: ${master.fullName}, avatarUrl: ${master.avatarUrl}',
    );

    if (master.avatarUrl.isEmpty) {
      logger.warning(
        'Master avatar URL is empty for mobile view - master: ${master.fullName}',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'У мастера установлена закрытая запись',
          style: AppTextStyles.headingLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Вас нет в клиентской базе мастера, поэтому запись недоступна. Если это не так, то, пожалуйста, попросите мастера добавить вас в клиентскую базу в приложении POLKA',
          style: AppTextStyles.bodyMedium500.copyWith(
            color: AppColors.iconsDefault,
          ),
        ),
        const SizedBox(height: 32),
        MobileMasterCard(
          fullName: master.fullName,
          specialization: master.profession,
          avatarUrl: master.avatarUrl,
          rating: master.rating,
          experience: master.experience,
          reviews: master.reviewsCount,
          actionButton: SizedBox(
            width: double.infinity,
            child: AppTextButton.large(
              text: 'Скачать POLKA',
              onTap: () {
                logger.debug(
                  'Download POLKA button tapped in mobile ClosedPage',
                );
                _openBooking();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
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
                onPressed: () {
                  logger.debug('Retry loading master info in ClosedPage');
                  _loadMasterInfo();
                },
                child: const Text('Попробовать снова'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
