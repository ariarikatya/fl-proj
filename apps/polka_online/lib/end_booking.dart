import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:intl/intl.dart';
import 'menu.dart';
import 'final.dart';
import 'widgets/widgets.dart';
import 'widgets/page_layout_helpers.dart';
import 'widgets/app_utils.dart';
import 'dependencies.dart';

class EndBookingPage extends StatefulWidget {
  final MasterInfo masterInfo;
  final AvailableSlot selectedSlot;
  final Service service;
  final String? phoneNumber;

  const EndBookingPage({
    super.key,
    required this.masterInfo,
    required this.selectedSlot,
    required this.service,
    this.phoneNumber,
  });

  @override
  State<EndBookingPage> createState() => _EndBookingPageState();
}

class _EndBookingPageState extends State<EndBookingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    logger.debug(
      'Initializing EndBookingPage - master: ${widget.masterInfo.master.fullName}, service: ${widget.service.title}, slot: ${widget.selectedSlot.datetime}, phoneNumber: ${widget.phoneNumber}',
    );
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    logger.debug('Disposing EndBookingPage');
    super.dispose();
  }

  void _goBack() {
    logger.debug('Navigating back from EndBookingPage');
    Navigator.pop(context);
  }

  Future<void> _submitBooking() async {
    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();

    if (name.isEmpty) {
      logger.warning('Booking submission failed - name is empty');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите имя')));
      return;
    }

    setState(() => _isSubmitting = true);

    final masterId = widget.masterInfo.master.id;
    final serviceId = widget.service.id;
    final slotId = widget.selectedSlot.id;

    logger.info(
      '[EndBookingPage] Submitting booking - name: $name, masterId: $masterId, serviceId: $serviceId, slotId: $slotId, serviceName: ${widget.service.title}, datetime: ${widget.selectedSlot.datetime}, comment: ${comment.isNotEmpty ? comment : "empty"}',
    );

    try {
      final bookingsRepo = Dependencies.instance.bookingsRepository;
      final result = await bookingsRepo.makeAppointment(
        masterId: masterId,
        serviceId: serviceId,
        slotId: slotId,
        clientName: name,
        clientNotes: comment.isNotEmpty ? comment : null,
      );

      if (!mounted) return;

      result.when(
        ok: (appointmentId) {
          logger.info(
            '[EndBookingPage] Booking submitted successfully - appointmentId: $appointmentId',
          );

          final selectedTime = DateFormat(
            'HH:mm',
          ).format(widget.selectedSlot.datetime);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FinalPage(
                masterId: masterId.toString(),
                service: widget.service,
                selectedDate: widget.selectedSlot.datetime.dateOnly,
                selectedTime: selectedTime,
                name: name,
                comment: comment,
                phoneNumber: widget.phoneNumber ?? '',
              ),
            ),
          );
        },
        err: (error, stackTrace) {
          logger.error('[EndBookingPage] Booking submission error: $error');
          setState(() => _isSubmitting = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: ${parseError(error, stackTrace)}')),
          );
        },
      );
    } catch (e) {
      logger.error('[EndBookingPage] Unexpected booking error: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Произошла ошибка при записи')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDesktop = LayoutHelper.isDesktopLayout(width);
    final showImage = LayoutHelper.shouldShowImage(width, isDesktop);
    final imageWidth = LayoutHelper.calculateImageWidth(
      screenWidth: width,
      showImage: showImage,
    );

    logger.debug(
      'Building EndBookingPage - width: $width, height: $height, isDesktop: $isDesktop, showImage: $showImage, imageWidth: $imageWidth, nameLength: ${_nameController.text.length}, commentLength: ${_commentController.text.length}, isSubmitting: $_isSubmitting',
    );

    return PageScaffold(
      isDesktop: isDesktop,
      showImage: showImage,
      onMenuTap: () {
        logger.debug('Opening menu page from EndBookingPage');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MenuPage()),
        );
      },
      onDownloadTap: () {
        logger.debug('Opening store from EndBookingPage header');
        StoreUtils.openStore();
      },
      breadcrumbStep: 3,
      onBackTap: _goBack,
      mobileBottomButton: AppTextButton.large(
        text: _isSubmitting ? 'Отправка...' : 'Записаться к мастеру',
        enabled: _nameController.text.trim().isNotEmpty && !_isSubmitting,
        onTap: () {
          logger.debug('Booking button tapped in mobile EndBookingPage');
          _submitBooking();
        },
      ),
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
    final master = widget.masterInfo.master;

    logger.debug(
      'Building desktop content for EndBookingPage - master: ${master.fullName}, avatarUrl: ${master.avatarUrl}',
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
        logger.debug('Opening store from EndBookingPage image overlay');
        StoreUtils.openStore();
      },
      leftContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Давайте познакомимся!', style: AppTextStyles.headingLarge),
          const SizedBox(height: 16),
          Text(
            'Оставьте Ваше имя и комментарий, чтобы мы могли добавить Вас в расписание к мастеру',
            style: AppTextStyles.bodyMedium500.copyWith(
              color: AppColors.iconsDefault,
            ),
          ),
          const SizedBox(height: 24),
          AppTextFormField(
            controller: _nameController,
            labelText: 'Ваше имя и фамилия',
          ),
          const SizedBox(height: 16),
          AppTextFormField(
            controller: _commentController,
            labelText: 'Комментарий, например, аллергия на коллаген',
            maxLines: 4,
          ),
          const SizedBox(height: 32),
          if (_isSubmitting)
            const Center(child: CircularProgressIndicator())
          else
            AppTextButton.large(
              text: 'Записаться к мастеру',
              enabled: _nameController.text.trim().isNotEmpty,
              onTap: () {
                logger.debug('Booking button tapped in desktop EndBookingPage');
                _submitBooking();
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
    logger.debug('Building mobile content for EndBookingPage');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Давайте познакомимся!', style: AppTextStyles.headingLarge),
        const SizedBox(height: 16),
        Text(
          'Оставьте Ваше имя и комментарий, чтобы мы могли добавить Вас в расписание к мастеру',
          style: AppTextStyles.bodyMedium500.copyWith(
            color: AppColors.iconsDefault,
          ),
        ),
        const SizedBox(height: 24),
        AppTextFormField(
          controller: _nameController,
          labelText: 'Ваше имя и фамилия',
        ),
        const SizedBox(height: 16),
        AppTextFormField(
          controller: _commentController,
          labelText: 'Комментарий, например, аллергия на коллаген',
          maxLines: 4,
        ),
        if (_isSubmitting) ...[
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
