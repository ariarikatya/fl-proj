import 'package:flutter/material.dart';
import 'package:polka_online/service.dart';
import 'package:shared/shared.dart' hide launchUrl;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'menu.dart';
import 'dependencies.dart';
import 'widgets/widgets.dart';
import 'widgets/page_layout_helpers.dart';

class WelcomePage extends StatefulWidget {
  final String? masterId;
  final String? phoneNumber;

  const WelcomePage({super.key, this.masterId, this.phoneNumber});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  MasterInfo? _masterInfo;
  bool _isLoading = true;
  String? _error;
  late String _masterId;

  @override
  void initState() {
    super.initState();
    _masterId = widget.masterId ?? '1';
    logger.debug('Initializing WelcomePage - masterId: $_masterId, phoneNumber: ${widget.phoneNumber}');
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
        logger.debug('Master info loaded successfully for masterId: $_masterId');
      },
      err: (error, stackTrace) {
        logger.error('Error loading master info for masterId $_masterId: $error');
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
      url = 'https://play.google.com/store/apps/details?id=com.mads.polkabeautymarketplace&hl=ru';
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
    logger.debug('Navigating to ServicePage - masterId: $_masterId, phoneNumber: ${widget.phoneNumber}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicePage(masterId: _masterId, phoneNumber: widget.phoneNumber),
      ),
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
      logger.error('Error displaying WelcomePage: $_error');
      return Scaffold(
        backgroundColor: AppColors.backgroundDefault,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ошибка загрузки данных', style: AppTextStyles.headingMedium),
                const SizedBox(height: 16),
                Text(_error ?? 'Неизвестная ошибка', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _loadMasterInfo, child: const Text('Попробовать снова')),
              ],
            ),
          ),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = LayoutHelper.isDesktopLayout(width);
    final showImage = LayoutHelper.shouldShowImage(width, isDesktop);
    final imageWidth = LayoutHelper.calculateImageWidth(screenWidth: width, showImage: showImage);

    logger.debug(
      'Building WelcomePage - width: $width, isDesktop: $isDesktop, showImage: $showImage, imageWidth: $imageWidth',
    );

    return PageScaffold(
      isDesktop: isDesktop,
      showImage: showImage,
      onMenuTap: () {
        logger.debug('Opening menu page from WelcomePage');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuPage()));
      },
      onDownloadTap: () {
        logger.debug('Opening store from desktop WelcomePage');
        openStore();
      },
      breadcrumbStep: 0,
      mobileBottomButton: AppTextButton.large(
        text: 'Записаться к мастеру',
        onTap: () {
          logger.debug('Booking button tapped on mobile');
          _openBooking();
        },
      ),
      child: isDesktop
          ? SingleChildScrollView(
              child: SafeArea(
                top: false,
                child: _buildDesktopContent(width: width, height: height, showImage: showImage, imageWidth: imageWidth),
              ),
            )
          : SingleChildScrollView(child: SafeArea(top: false, child: _buildMobileContent())),
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
      imageOverlayText: 'Установи POLKA\nи найди своего\nмастера',
      showImageOverlay: true,
      leftContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Рады вас видеть!', style: AppTextStyles.headingLarge),
          const SizedBox(height: 16),
          Text(
            'Чтобы записаться к мастеру и выбрать услугу, пожалуйста, нажмите "Записаться"',
            style: AppTextStyles.bodyMedium500.copyWith(color: AppColors.iconsDefault),
          ),
          const SizedBox(height: 32),
          AppTextButton.large(
            text: 'Записаться к мастеру',
            onTap: () {
              logger.debug('Booking button tapped on desktop');
              _openBooking();
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
    final master = _masterInfo!.master;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Рады вас видеть!', style: AppTextStyles.headingLarge),
        const SizedBox(height: 16),
        Text(
          'Чтобы записаться к мастеру и выбрать услугу, пожалуйста, нажмите "Записаться"',
          style: AppTextStyles.bodyMedium500.copyWith(color: AppColors.iconsDefault),
        ),
        const SizedBox(height: 32),
        Center(
          child: MobileMasterCard(
            fullName: master.fullName,
            specialization: master.profession,
            avatarUrl: master.avatarUrl,
            rating: master.rating,
            experience: master.experience,
            reviews: master.reviewsCount,
          ),
        ),
      ],
    );
  }
}
