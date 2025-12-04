import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/calendar/widgets/pick_service_page.dart';
import 'package:polka_masters/features/calendar/widgets/service_card.dart';
import 'package:polka_masters/features/contacts/widgets/contact_card.dart';
import 'package:shared/shared.dart';

Future<Booking?> showBookingInfoMbs({required BuildContext context, required Booking booking}) {
  // if (booking.isTimeBlock) return Future.value(null);
  return showModalBottomSheet<Booking?>(
    context: context,
    backgroundColor: context.ext.colors.white[100],
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => booking.isTimeBlock ? _TimeBlockInfoMbs(timeblock: booking) : _View(booking: booking),
  );
}

class _View extends StatelessWidget {
  const _View({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return LoadDataMbs(
      future: () => Dependencies().bookingsRepository.getBookingInfo(booking.id),
      builder: (data) => _BookingInfoMbs(info: data),
    );
  }
}

class _BookingInfoMbs extends StatefulWidget {
  const _BookingInfoMbs({required this.info});

  final BookingInfo info;

  @override
  State<_BookingInfoMbs> createState() => _BookingInfoMbsState();
}

class _BookingInfoMbsState extends State<_BookingInfoMbs> {
  late Service _service = widget.info.service;
  late Duration _startTime = widget.info.booking.startTime;
  late Duration _endTime = widget.info.booking.startTime + widget.info.booking.duration;

  void _changeService() async {
    final service = await context.ext.push<Service>(const PickServicePage());
    if (service != null) {
      setState(() => _service = service);
    }
  }

  void _setStartTime(Duration duration) => setState(() {
    _startTime = duration;
    _endTime = _startTime + (_service.duration);
  });

  void _setEndTime(Duration duration) => setState(() => _endTime = duration);

  bool get canEdit => [BookingStatus.pending, BookingStatus.confirmed].contains(widget.info.booking.status);

  bool get hasChanges =>
      _service != widget.info.service ||
      _startTime != widget.info.booking.startTime ||
      _endTime != widget.info.booking.endTime;

  Future<void> _saveChanges() async {
    if (!hasChanges) return;

    final newServiceId = _service != widget.info.service ? _service.id : null;

    (await Dependencies().bookingsRepository.updateBooking(
      bookingId: widget.info.booking.id,
      serviceId: newServiceId,
      startTime: _startTime,
      endTime: _endTime,
    )).unpack(); // Events update via socket messages
    if (mounted) context.ext.pop();
  }

  Future<void> _maybeDeleteBooking() async {
    final delete = await showConfirmBottomSheet(
      context: context,
      title: 'Ты уверена, что хочешь отменить запись?',
      description: 'Мы пришлем уведомление клиенту об отмене в приложении',
      acceptText: 'Да, отменить запись',
      declineText: 'Нет, оставить запись',
    );
    if (delete == true) {
      await _deleteBooking();
    }
  }

  Future<void> _deleteBooking() async {
    (await switch (widget.info.booking.status) {
      BookingStatus.pending => Dependencies().bookingsRepository.rejectBooking(widget.info.booking.id),
      _ => Dependencies().bookingsRepository.cancelBooking(widget.info.booking.id),
    }).unpack(); // Events update via socket messages
    if (mounted) context.ext.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          'Запись на ${widget.info.booking.date.format('d MMMM, E')}',
          textAlign: TextAlign.start,
          style: AppTextStyles.headingLarge,
        ),
        const SizedBox(height: 24),
        const AppText('Кто записан на услугу?', style: AppTextStyles.headingSmall),
        const SizedBox(height: 16),
        switch (widget.info) {
          BookingInfo(contact: Contact contact) => ContactCard(contact: contact),
        },
        if (widget.info.client != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: AppTextButtonSecondary.large(
                    text: 'Чат',
                    onTap: () => ChatsUtils().openChat(
                      context,
                      widget.info.client?.id ?? widget.info.contact.id,
                      widget.info.client?.fullName ?? widget.info.contact.name,
                      widget.info.client?.avatarUrl ?? widget.info.contact.avatarUrl,
                      withClient: true,
                    ),
                  ),
                ),
                Expanded(
                  child: AppTextButtonSecondary.large(
                    text: 'Позвонить',
                    onTap: () {
                      ChatsUtils().callNumber(
                        Dependencies().masterRepository.getClientPhone(
                          widget.info.client?.id ?? widget.info.contact.id,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText('Какая услуга?', style: AppTextStyles.headingSmall),
            if (canEdit) AppLinkButton(text: 'Изменить', onTap: _changeService),
          ],
        ),
        const SizedBox(height: 16),
        ServiceCard(_service),
        const SizedBox(height: 16),
        const AppText('Когда?', style: AppTextStyles.headingSmall),
        if (canEdit) ...[
          const SizedBox(height: 8),
          AppText(
            'Ты можешь изменить время услуги, а мы сообщим клиенту в приложении',
            style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.colors.black[700]),
          ),
        ],
        const SizedBox(height: 16),
        IgnorePointer(
          ignoring: !canEdit,
          child: FromToDurationPicker(
            startTime: _startTime,
            endTime: _endTime,
            onStartTimeChanged: _setStartTime,
            onEndTimeChanged: _setEndTime,
          ),
        ),
        const SizedBox(height: 24),
        if (canEdit) ...[
          AppTextButton.large(text: 'Сохранить изменения', onTap: _saveChanges, enabled: hasChanges),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: AppLinkButton(text: 'Отменить запись', onTap: _maybeDeleteBooking),
            ),
          ),
        ],
      ],
    );
  }
}

class _TimeBlockInfoMbs extends StatefulWidget {
  const _TimeBlockInfoMbs({required this.timeblock});

  final Booking timeblock;

  @override
  State<_TimeBlockInfoMbs> createState() => _TimeBlockInfoMbsState();
}

class _TimeBlockInfoMbsState extends State<_TimeBlockInfoMbs> {
  Future<void> _maybeDeleteTimeBlock() async {
    final delete = await showConfirmBottomSheet(
      context: context,
      title: 'Ты уверена, что хочешь отменить перерыв?',
      acceptText: 'Да, отменить перерыв',
      declineText: 'Нет, оставить',
    );
    if (delete == true) {
      await _deleteTimeBlock();
    }
  }

  Future<void> _deleteTimeBlock() async {
    (await Dependencies().schedulesRepo.unblockTime(
      date: widget.timeblock.date,
      startTime: widget.timeblock.startTime,
      endTime: widget.timeblock.endTime,
    )).unpack(); // Events update via socket messages
    if (mounted) context.ext.pop();
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.ext.textTheme;
    final colors = context.ext.colors;

    return MbsBase(
      expandContent: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            'Перерыв, ${widget.timeblock.date.format('d MMMM, E')}',
            textAlign: TextAlign.start,
            style: styles.headlineMedium,
          ),
          const SizedBox(height: 40),
          AppText('Время перерыва', style: styles.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          AppText(
            'Мы не будем показывать занятое время твоим клиентам',
            style: styles.bodyMedium?.copyWith(color: colors.black[700]),
          ),
          const SizedBox(height: 20),
          IgnorePointer(
            ignoring: true,
            child: FromToDurationPicker(
              startTime: widget.timeblock.startTime,
              endTime: widget.timeblock.endTime,
              onStartTimeChanged: (_) {},
              onEndTimeChanged: (_) {},
            ),
          ),
          const SizedBox(height: 24),
          AppTextButtonSecondary.large(text: 'Отменить перерыв', onTap: _maybeDeleteTimeBlock),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
