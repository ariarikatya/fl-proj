import 'package:flutter/material.dart';
import 'package:polka_online/end_booking.dart';
import 'package:shared/shared.dart';
import 'package:intl/intl.dart';
import 'menu.dart';
import 'dependencies.dart';
import 'widgets/widgets.dart';
import 'widgets/page_layout_helpers.dart';
import 'widgets/app_utils.dart';

extension DateTimeIntl on DateTime {
  static final _formatter = DateFormat('d MMMM, HH:mm', 'ru');
  static final _formatterDateOnly = DateFormat('EEEE, d MMMM', 'ru');
  static final _formatterTimeOnly = DateFormat('HH:mm', 'ru');

  String formatFull() => _formatter.format(this);

  String formatDateOnly() {
    final s = _formatterDateOnly.format(this);
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String toTimeString() => _formatterTimeOnly.format(this);
}

class SlotsPage extends StatefulWidget {
  final MasterInfo masterInfo;
  final Service service;
  final String? phoneNumber;

  const SlotsPage({
    super.key,
    required this.masterInfo,
    required this.service,
    this.phoneNumber,
  });

  @override
  State<SlotsPage> createState() => _SlotsPageState();
}

class _SlotsPageState extends State<SlotsPage> {
  List<AvailableSlot>? _slots;
  bool _isLoading = true;
  String? _error;

  AvailableSlot? _selectedSlot;
  Map<DateTime, List<AvailableSlot>> _groupedSlots = {};

  MasterInfo get masterInfo => widget.masterInfo;
  Service get service => widget.service;
  int get masterId => masterInfo.master.id;
  int get serviceId => service.id;

  @override
  void initState() {
    super.initState();
    logger.debug(
      'Initializing SlotsPage - masterId: $masterId, serviceId: $serviceId, serviceName: ${service.title}, phoneNumber: ${widget.phoneNumber}',
    );
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = Dependencies.instance.masterRepository;

      // Загружаем слоты с бэка
      logger.debug(
        '[SlotsPage] Loading slots for masterId: $masterId, serviceId: $serviceId',
      );
      final slotsResult = await repository.getSlots(masterId, serviceId);

      final slots = await slotsResult.when(
        ok: (List<AvailableSlot> slots) => slots,
        err: (error, stackTrace) {
          throw Exception('Failed to load slots: $error');
        },
      );

      logger.info(
        '[SlotsPage] Successfully loaded ${slots.length} slots for service: ${service.title}',
      );

      setState(() {
        _slots = slots;
        _isLoading = false;
      });

      if (slots.isNotEmpty) {
        _groupSlots(slots);
      }
    } catch (e, st) {
      logger.error('[SlotsPage] Error loading slots: $e', e, st);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _groupSlots(List<AvailableSlot> slots) {
    final map = <DateTime, List<AvailableSlot>>{};
    slots.sort((a, b) => a.datetime.compareTo(b.datetime));
    for (var slot in slots) {
      map[slot.datetime.dateOnly] ??= [];
      map[slot.datetime.dateOnly]!.add(slot);
    }
    setState(() => _groupedSlots = map);
    logger.debug(
      'Grouped slots by date: ${map.keys.length} days, total slots: ${slots.length}',
    );
  }

  void _goBack() {
    logger.debug('Navigating back from SlotsPage');
    Navigator.pop(context);
  }

  void _selectSlot() {
    if (_selectedSlot != null) {
      logger.debug(
        'Navigating to EndBookingPage - slotId: ${_selectedSlot!.id}, datetime: ${_selectedSlot!.datetime}, serviceId: $serviceId, serviceName: ${service.title}, masterId: $masterId',
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EndBookingPage(
            masterInfo: masterInfo,
            selectedSlot: _selectedSlot!,
            service: service,
            phoneNumber: widget.phoneNumber,
          ),
        ),
      );
    } else {
      logger.warning('Select slot called but no slot selected');
    }
  }

  void _onSlotSelected(AvailableSlot slot) {
    logger.debug('Slot selected: ${slot.datetime}, id: ${slot.id}');
    setState(() => _selectedSlot = slot);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget();
    if (_error != null) {
      logger.error('Error displaying SlotsPage: $_error');
      return ErrorStateWidget(error: _error, onRetry: _loadSlots);
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
      'Building SlotsPage - width: $width, height: $height, isDesktop: $isDesktop, showImage: $showImage, imageWidth: $imageWidth, selectedSlot: ${_selectedSlot?.datetime}, slotsCount: ${_slots?.length ?? 0}',
    );

    return PageScaffold(
      isDesktop: isDesktop,
      showImage: showImage,
      onMenuTap: () {
        logger.debug('Opening menu page from SlotsPage');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MenuPage()),
        );
      },
      onDownloadTap: () {
        logger.debug('Opening store from SlotsPage header');
        StoreUtils.openStore();
      },
      breadcrumbStep: 2,
      onBackTap: _goBack,
      mobileBottomButton: AppTextButton.large(
        text: _selectedSlot != null ? 'Далее' : 'Выберите слот',
        enabled: _selectedSlot != null,
        onTap: () {
          logger.debug('Next button tapped in mobile SlotsPage');
          _selectSlot();
        },
      ),
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
    final master = masterInfo.master;

    logger.debug(
      'Building desktop content for SlotsPage - master: ${master.fullName}, groupedSlots: ${_groupedSlots.keys.length} days, avatarUrl: ${master.avatarUrl}',
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
        logger.debug('Opening store from SlotsPage image overlay');
        StoreUtils.openStore();
      },
      leftContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Выберите время', style: AppTextStyles.headingLarge),
          const SizedBox(height: 16),
          Text(
            'Жмите на удобный для вас слот у мастера',
            style: AppTextStyles.bodyMedium500.copyWith(
              color: AppColors.iconsDefault,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(child: _buildSlotsPicker()),
          const SizedBox(height: 16),
          AppTextButton.large(
            text: _selectedSlot != null
                ? 'Выбрать ${DateTimeIntl(_selectedSlot!.datetime).formatFull()}'
                : 'Выберите слот',
            enabled: _selectedSlot != null,
            onTap: () {
              logger.debug('Next button tapped in desktop SlotsPage');
              _selectSlot();
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
    logger.debug(
      'Building mobile content for SlotsPage - groupedSlots: ${_groupedSlots.keys.length} days',
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Выберите время', style: AppTextStyles.headingLarge),
                const SizedBox(height: 16),
                Text(
                  'Жмите на удобный для вас слот у мастера',
                  style: AppTextStyles.bodyMedium500.copyWith(
                    color: AppColors.iconsDefault,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSlotsPicker(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotsPicker() {
    if (_groupedSlots.isEmpty) {
      logger.warning('No slots available for booking');
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundHover,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              'Нет доступных слотов для записи',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте выбрать другую услугу или свяжитесь с мастером напрямую',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _groupedSlots.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateTimeIntl(entry.key).formatDateOnly(),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.value.map((slot) {
                    final isSelected = _selectedSlot == slot;
                    final displayTime = slot.datetime;

                    return TimeSlotButton(
                      time: DateTimeIntl(displayTime).toTimeString(),
                      isSelected: isSelected,
                      onTap: () => _onSlotSelected(slot),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Кнопка выбора времени
class TimeSlotButton extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeSlotButton({
    super.key,
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentLight : AppColors.backgroundHover,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            time,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
