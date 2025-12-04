import 'package:flutter/material.dart';
import 'package:shared/shared.dart' hide launchUrl;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'menu.dart';
import 'dependencies.dart';
import 'slots.dart';
import 'welcome.dart';
import 'widgets/widgets.dart';
import 'widgets/page_layout_helpers.dart';

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
    logger.debug('Initializing ServicePage - masterId: $_masterId, phoneNumber: ${widget.phoneNumber}');
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
        // Добавляем моковые сервисы
        final mockServices = [
          Service(
            id: 1,
            category: ServiceCategories.nailService,
            title: 'Маникюр классический без педикюра',
            duration: const Duration(minutes: 60),
            resultPhotos: [],
            price: 1200,
            cost: null,
          ),
          Service(
            id: 2,
            category: ServiceCategories.nailService,
            title: 'Педикюр Spa',
            duration: const Duration(minutes: 90),
            resultPhotos: [],
            price: 2000,
            cost: null,
          ),
          Service(
            id: 3,
            category: ServiceCategories.other,
            title: 'Массаж спины',
            duration: const Duration(minutes: 45),
            resultPhotos: [],
            price: 1500,
            cost: null,
          ),
        ];
        _masterInfo = data.copyWith(services: () => mockServices);
        setState(() {
          _isLoading = false;
        });
        logger.debug(
          'Master info loaded successfully for masterId: $_masterId, services count: ${mockServices.length}',
        );
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

  void _selectTime() {
    if (_selectedService != null) {
      logger.debug(
        'Navigating to SlotsPage - service: ${_selectedService!.title}, masterId: ${_masterInfo!.master.id}, phoneNumber: ${widget.phoneNumber}',
      );
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
    } else {
      logger.warning('Select time called but no service selected');
    }
  }

  void _goBack() {
    logger.debug('Navigating back to WelcomePage from ServicePage');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomePage()));
  }

  void _onServiceSelected(Service service) {
    logger.debug(
      'Service selected: ${service.title}, price: ${service.price}, duration: ${service.duration.inMinutes}min',
    );
    setState(() => _selectedService = service);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: polkaThemeExtension.white[100],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _masterInfo == null) {
      logger.error('Error displaying ServicePage: $_error');
      return Scaffold(
        backgroundColor: polkaThemeExtension.white[100],
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
                ElevatedButton(
                  onPressed: () {
                    logger.debug('Retry loading master info in ServicePage');
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

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = LayoutHelper.isDesktopLayout(width);
    final showImage = LayoutHelper.shouldShowImage(width, isDesktop);
    final imageWidth = LayoutHelper.calculateImageWidth(screenWidth: width, showImage: showImage);

    logger.debug(
      'Building ServicePage - width: $width, height: $height, isDesktop: $isDesktop, showImage: $showImage, imageWidth: $imageWidth, selectedService: ${_selectedService?.title}',
    );

    return PageScaffold(
      isDesktop: isDesktop,
      showImage: showImage,
      onMenuTap: () {
        logger.debug('Opening menu page from ServicePage');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuPage()));
      },
      onDownloadTap: () {
        logger.debug('Opening store from ServicePage header');
        openStore();
      },
      breadcrumbStep: 1,
      onBackTap: _goBack,
      mobileBottomButton: AppTextButton.large(
        text: 'Далее',
        enabled: _selectedService != null,
        onTap: () {
          logger.debug('Next button tapped in mobile ServicePage');
          _selectTime();
        },
      ),
      child: isDesktop
          ? SingleChildScrollView(
              child: SafeArea(
                top: false,
                child: _buildDesktopContent(width: width, height: height, showImage: showImage, imageWidth: imageWidth),
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
    final services = _masterInfo!.services;

    logger.debug(
      'Building desktop content for ServicePage - master: ${master.fullName}, services count: ${services.length}, avatarUrl: ${master.avatarUrl}',
    );

    if (master.avatarUrl.isEmpty) {
      logger.warning('Master avatar URL is empty for master: ${master.fullName}');
    }

    return DesktopPageLayout(
      screenWidth: width,
      screenHeight: height,
      showImage: showImage,
      imageWidth: imageWidth,
      onDownloadTap: () {
        logger.debug('Opening store from ServicePage image overlay');
        openStore();
      },
      leftContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Выберите услугу', style: AppTextStyles.headingLarge),
          const SizedBox(height: 16),
          Text(
            'Здесь представлены все услуги мастера, выберите услугу и нажмите "Далее"',
            style: AppTextStyles.bodyMedium500.copyWith(color: polkaThemeExtension.black[700]),
          ),
          const SizedBox(height: 32),
          ...services.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ServiceCard(
                service: service,
                isSelected: _selectedService == service,
                onTap: () => _onServiceSelected(service),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppTextButton.large(
            text: 'Далее',
            enabled: _selectedService != null,
            onTap: () {
              logger.debug('Next button tapped in desktop ServicePage');
              _selectTime();
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
    final services = _masterInfo!.services;
    final master = _masterInfo!.master;

    logger.debug(
      'Building mobile content for ServicePage - master: ${master.fullName}, services count: ${services.length}',
    );

    if (services.isEmpty) {
      logger.warning('No services available for master: ${master.fullName}');
    }

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
                  style: AppTextStyles.bodyMedium500.copyWith(color: polkaThemeExtension.black[700]),
                ),
                const SizedBox(height: 32),
                if (services.isNotEmpty)
                  ...services.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ServiceCard(
                        service: service,
                        isSelected: _selectedService == service,
                        onTap: () => _onServiceSelected(service),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: polkaThemeExtension.white[300],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'У мастера пока нет доступных услуг',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Карточка услуги
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.isSelected, required this.onTap});

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
          color: isSelected ? polkaThemeExtension.pink[100] : polkaThemeExtension.white[300],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? polkaThemeExtension.pink[500] : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title, style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppIcons.clock.icon(context, size: 16, color: polkaThemeExtension.black[700]),
                      const SizedBox(width: 4),
                      Text(
                        service.duration.toDurationStringShort(),
                        style: AppTextStyles.bodyLarge500.copyWith(color: polkaThemeExtension.black[700]),
                      ),
                      const SizedBox(width: 16),
                      Text('|', style: AppTextStyles.bodyLarge500.copyWith(color: polkaThemeExtension.black[700])),
                      const SizedBox(width: 16),
                      Text(
                        '₽${service.price}',
                        style: AppTextStyles.bodyLarge500.copyWith(color: polkaThemeExtension.black[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // isSelected
            //     ? AppIcons.radioChecked.icon(context, size: 24, color: polkaThemeExtension.pink[500])
            //     : AppIcons.radioUnchecked.icon(context, size: 24, color: polkaThemeExtension.borderDefault),
          ],
        ),
      ),
    );
  }
}
