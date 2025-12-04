import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';
import 'menu.dart';
import 'dependencies.dart';
import 'widgets/widgets.dart';
import 'widgets/page_layout_helpers.dart';
import 'widgets/app_utils.dart';

class FinalPage extends StatefulWidget {
  final String masterId;
  final Service? service;
  final DateTime selectedDate;
  final String selectedTime;
  final String name;
  final String comment;
  final String phoneNumber;

  const FinalPage({
    super.key,
    required this.masterId,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
    required this.name,
    required this.comment,
    required this.phoneNumber,
  });

  @override
  State<FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> {
  MasterInfo? _masterInfo;
  bool _isLoading = true;
  String? _error;
  late String _masterId;

  @override
  void initState() {
    super.initState();
    _masterId = widget.masterId;
    logger.debug(
      'Initializing FinalPage - masterId: $_masterId, service: ${widget.service?.title}, date: ${widget.selectedDate}, time: ${widget.selectedTime}, name: ${widget.name}, phoneNumber: ${widget.phoneNumber}',
    );
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
        logger.debug('Master info loaded successfully for FinalPage - master: ${data.master.fullName}');
      },
      err: (error, stackTrace) {
        logger.error('Error loading master info for FinalPage masterId $_masterId: $error');
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  String _formatDateTime() {
    final dateFormat = DateFormat('d MMMM, HH:mm', 'ru');
    final dateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      int.parse(widget.selectedTime.split(':')[0]),
      int.parse(widget.selectedTime.split(':')[1]),
    );
    final formatted = dateFormat.format(dateTime);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  void _goBack() {
    logger.debug('Navigating back from FinalPage');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget();
    if (_error != null || _masterInfo == null) {
      logger.error('Error displaying FinalPage: $_error');
      return ErrorStateWidget(error: _error, onRetry: _loadMasterInfo);
    }

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = width >= 950;
    final showImage = LayoutHelper.shouldShowImage(width, isDesktop);
    final imageWidth = LayoutHelper.calculateImageWidth(screenWidth: width, showImage: showImage);

    logger.debug(
      'Building FinalPage - width: $width, height: $height, isDesktop: $isDesktop, showImage: $showImage, imageWidth: $imageWidth',
    );

    return PageScaffold(
      isDesktop: isDesktop,
      showImage: showImage,
      onMenuTap: () {
        logger.debug('Opening menu page from FinalPage');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuPage()));
      },
      onDownloadTap: () {
        logger.debug('Opening store from FinalPage header');
        StoreUtils.openStore();
      },
      breadcrumbStep: 3,
      onBackTap: _goBack,
      mobileBottomButton: AppTextButton.large(
        text: 'Скачать POLKA',
        enabled: true,
        onTap: () {
          logger.debug('Download POLKA button tapped in mobile FinalPage');
          StoreUtils.openStore();
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
    logger.debug('Building desktop content for FinalPage');

    return DesktopPageLayout(
      screenWidth: width,
      screenHeight: height,
      showImage: showImage,
      imageWidth: imageWidth,
      onDownloadTap: () {
        logger.debug('Opening store from FinalPage image overlay');
        StoreUtils.openStore();
      },
      leftContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Отлично! Вы записаны', style: AppTextStyles.headingLarge),
          const SizedBox(height: 16),
          Text(
            'А еще проще записаться через наше приложение, установите POLKA',
            style: AppTextStyles.bodyMedium500.copyWith(color: polkaThemeExtension.black[700]),
          ),
          const SizedBox(height: 32),
          AppTextButton.large(
            text: 'Установить POLKA',
            enabled: true,
            onTap: () {
              logger.debug('Install POLKA button tapped in desktop FinalPage');
              StoreUtils.openStore();
            },
          ),
        ],
      ),
      rightCard: _buildMasterCard(context, isDesktop: true),
    );
  }

  Widget _buildMobileContent() {
    logger.debug('Building mobile content for FinalPage');

    return SingleChildScrollView(
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Отлично! Вы записаны', style: AppTextStyles.headingLarge),
            const SizedBox(height: 16),
            Text(
              'А еще проще записаться через наше приложение, установите POLKA',
              style: AppTextStyles.bodyMedium500.copyWith(color: polkaThemeExtension.black[700]),
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildMasterCard(context, isDesktop: false),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterCard(BuildContext context, {required bool isDesktop}) {
    final master = _masterInfo!.master;
    final service = widget.service;

    logger.debug('Building master card for FinalPage - master: ${master.fullName}, service: ${service?.title}');

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: polkaThemeExtension.white[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: polkaThemeExtension.white[100], width: 1),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildMasterInfoColumn(context, master: master, isDesktop: isDesktop),
                  ),
                  const SizedBox(width: 20),
                  _buildStatsColumn(context, master: master),
                ],
              )
            else
              _buildMasterInfoColumn(context, master: master, isDesktop: isDesktop),
            const SizedBox(height: 24),
            if (service != null) _buildServiceInfo(context, service, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterInfoColumn(BuildContext context, {required Master master, required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        MasterAvatar(avatarUrl: master.avatarUrl, size: 100, splashSize: 140),
        const SizedBox(height: 20),
        Text(
          master.fullName,
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        Text(
          master.profession,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildStatsColumn(BuildContext context, {required Master master}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatItem(context, master.rating.toStringAsFixed(1), 'Рейтинг', showStar: true),
        _buildStatItem(context, FormatUtils.getYearsText(master.experience), 'Опыта'),
        _buildStatItem(context, master.reviewsCount.toString(), 'Отзыва'),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, {bool showStar = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(value, style: AppTextStyles.bodyLarge),
              if (showStar) ...[const SizedBox(width: 4), AppIcons.star.icon(context, size: 16)],
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildServiceInfo(BuildContext context, Service service, bool isDesktop) {
    final serviceName = FormatUtils.truncate(service.title, 30);
    final serviceDuration = service.duration.toDurationStringShort();
    final servicePrice = service.price;
    final formattedDateTime = _formatDateTime();

    logger.debug(
      'Building service info for FinalPage - service: $serviceName, duration: $serviceDuration, price: $servicePrice, dateTime: $formattedDateTime',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Строка с информацией об услуге
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80, // Фиксированная ширина для меток
                child: Text(
                  'Услуга',
                  style: (isDesktop ? AppTextStyles.bodyLarge : AppTextStyles.bodyMedium).copyWith(
                    color: polkaThemeExtension.black[700],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                // Занимает всё оставшееся пространство
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      serviceName,
                      style: isDesktop ? AppTextStyles.bodyLarge : AppTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        AppIcons.clock.icon(context, size: 16, color: polkaThemeExtension.black[700]),
                        const SizedBox(width: 4),
                        Text(
                          ' $serviceDuration  |  ₽ $servicePrice',
                          style: (isDesktop ? AppTextStyles.bodyMedium500 : AppTextStyles.bodySmall).copyWith(
                            color: polkaThemeExtension.black[700],
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Строка с датой
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80, // Такая же фиксированная ширина
                child: Text(
                  'Дата',
                  style: (isDesktop ? AppTextStyles.bodyLarge : AppTextStyles.bodyMedium).copyWith(
                    color: polkaThemeExtension.black[700],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                // Занимает всё оставшееся пространство
                child: Text(
                  formattedDateTime,
                  style: (isDesktop ? AppTextStyles.bodyLarge : AppTextStyles.bodyMedium).copyWith(
                    fontWeight: FontWeight.w700,
                    color: polkaThemeExtension.black[900],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
