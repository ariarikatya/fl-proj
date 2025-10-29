import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/calendar/widgets/pick_service_page.dart';
import 'package:polka_masters/features/calendar/widgets/service_card.dart';
import 'package:polka_masters/features/contacts/widgets/contact_card.dart';
import 'package:shared/shared.dart';

Future<Booking?> showBookingInfoMbs({required BuildContext context, required Booking booking}) {
  if (booking.isTimeBlock) return Future.value(null);
  return showModalBottomSheet<Booking?>(
    context: context,
    backgroundColor: context.ext.theme.backgroundDefault,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _View(booking: booking),
  );
}

class _View extends StatelessWidget {
  const _View({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return LoadDataMbs(
      future: () => Dependencies().bookingsRepository.getBookingInfo(booking.id),
      // future: () => Future.delayed(Duration(seconds: 1), () => Result.ok(_mockInfo(booking))),
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
    final service = await context.ext.push<Service>(PickServicePage());
    if (service != null) {
      setState(() => _service = service);
    }
  }

  void _setStartTime(Duration duration) => setState(() => _startTime = duration);
  void _setEndTime(Duration duration) => setState(() => _endTime = duration);

  bool get hasChanges =>
      _service != widget.info.service ||
      _startTime != widget.info.booking.startTime ||
      _endTime != widget.info.booking.endTime;

  Future<void> _saveChanges() async {
    if (!hasChanges) return;

    final newServiceId = _service != widget.info.service ? _service.id : null;
    final newStartTime = _startTime != widget.info.booking.startTime ? _startTime : null;
    final newEndTime = _endTime != widget.info.booking.endTime ? _endTime : null;

    await Dependencies().bookingsRepository.updateBooking(
      bookingId: widget.info.booking.id,
      serviceId: newServiceId,
      startTime: newStartTime,
      endTime: newEndTime,
    ); // Events update via socket messages
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
    await switch (widget.info.booking.status) {
      BookingStatus.pending => Dependencies().bookingsRepository.rejectBooking(widget.info.booking.id),
      _ => Dependencies().bookingsRepository.cancelBooking(widget.info.booking.id),
    }; // Events update via socket messages
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
        AppText('Кто записан на услугу?', style: AppTextStyles.headingSmall),
        const SizedBox(height: 16),
        switch (widget.info) {
          BookingInfo(contact: Contact contact) => ContactCard(contact: contact),
          BookingInfo(client: Client client) => ContactCard(
            contact: Contact(
              id: client.id,
              name: client.fullName,
              number: widget.info.contact?.number ?? '',
              avatarUrl: client.avatarUrl,
            ),
          ),
          _ => ContactCard(
            contact: Contact(id: 0, name: 'Неизвестный клиент', number: '', avatarUrl: null),
          ),
        },
        if (widget.info.client != null || widget.info.contact != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: AppTextButtonSecondary.large(
                    text: 'Чат',
                    onTap: () => ChatsUtils().openChat(
                      context,
                      widget.info.client?.id ?? widget.info.contact!.id,
                      widget.info.client?.fullName ?? widget.info.contact?.name ?? 'Неизвестный клиент',
                      widget.info.client?.avatarUrl ?? widget.info.contact?.avatarUrl,
                      withClient: false,
                    ),
                  ),
                ),
                Expanded(
                  child: AppTextButtonSecondary.large(
                    text: 'Позвонить',
                    onTap: () {
                      ChatsUtils().callNumber(
                        Dependencies().masterRepository.getClientPhone(
                          widget.info.client?.id ?? widget.info.contact!.id,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText('Какая услуга?', style: AppTextStyles.headingSmall),
            AppLinkButton(text: 'Изменить', onTap: _changeService),
          ],
        ),
        const SizedBox(height: 16),
        ServiceCard(_service),
        const SizedBox(height: 16),
        AppText('Когда?', style: AppTextStyles.headingSmall),
        const SizedBox(height: 8),
        AppText(
          'Ты можешь изменить время услуги, а мы сообщим клиенту в приложении',
          style: AppTextStyles.bodyMedium500.copyWith(color: context.ext.theme.textSecondary),
        ),
        const SizedBox(height: 16),
        FromToDurationPicker(
          startTime: _startTime,
          endTime: _endTime,
          onStartTimeChanged: _setStartTime,
          onEndTimeChanged: _setEndTime,
        ),
        SizedBox(height: 24),
        AppTextButton.large(text: 'Сохранить изменения', onTap: _saveChanges, enabled: hasChanges),
        Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: AppLinkButton(text: 'Отменить запись', onTap: _maybeDeleteBooking),
          ),
        ),
      ],
    );
  }
}
