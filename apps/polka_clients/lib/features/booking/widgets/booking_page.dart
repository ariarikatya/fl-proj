import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/booking/booking_utils.dart';
import 'package:polka_clients/features/booking/controller/old_bookings_cubit.dart';
import 'package:polka_clients/features/master_appointment/widgets/master_appointment_info.dart';
import 'package:shared/shared.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      future: () => Dependencies().bookingsRepo.getBookingInfo(booking.id),
      builder: (data) => BookingView(booking: booking, master: data.master, service: data.service),
    );
  }
}

class BookingView extends StatelessWidget {
  const BookingView({super.key, required this.booking, required this.master, required this.service});

  final Booking booking;
  final Master master;
  final Service service;

  void _bookAgain(BuildContext context) {
    context.read<OldBookingsCubit>().startAppointmentFlow(context, master, service);
  }

  void _cancelAppointment(BuildContext context) async {
    final cancel = await showConfirmBottomSheet(
      context: context,
      title: 'Ты уверена, что хочешь отменить запись?',
      acceptText: 'Да',
      declineText: 'Нет',
    );
    if (context.mounted && cancel == true) {
      final changed = await context.read<OldBookingsCubit>().cancelAppointment(context, booking.id);
      if (context.mounted && changed) context.ext.pop();
    }
  }

  void _changeAppointmentTime(BuildContext context) async {
    final changed = await context.read<OldBookingsCubit>().changeAppointmentTime(context, booking);
    if (context.mounted && changed) context.ext.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Твоя услуга'),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(master: master, title: service.title, price: service.price, status: booking.status),
            if (booking.status == BookingStatus.completed)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: booking.reviewSent
                    ? AppTextButtonSecondary.large(text: 'Отзыв отправлен', onTap: () {}, enabled: false)
                    : AppTextButtonSecondary.large(text: 'Оставить отзыв', onTap: () => leaveReview(context, booking)),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: context.ext.colors.white[300], width: 1)),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  const AppText('Когда:', style: AppTextStyles.headingSmall),
                  AppText(
                    booking.datetime.formatFull(),
                    style: AppTextStyles.bodyLarge.copyWith(color: context.ext.colors.black[700]),
                  ),
                  if (booking.status == BookingStatus.confirmed)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: AppTextButtonSecondary.large(
                        text: 'Добавить в календарь',
                        onTap: () => addCalendarEvent(booking),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    const AppText('Где:', style: AppTextStyles.headingSmall),
                    AppText(
                      master.location.label,
                      style: AppTextStyles.bodyLarge.copyWith(color: context.ext.colors.black[700]),
                      textAlign: TextAlign.center,
                    ),
                    AppText(
                      master.address,
                      style: AppTextStyles.bodyLarge.copyWith(color: context.ext.colors.black[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    AppTextButtonSecondary.large(
                      text: 'Показать на карте',
                      onTap: () => showOnExternalMap(context, master.latitude, master.longitude, service.title),
                    ),
                  ],
                ),
              ),
            ),
            if (master.workplace.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: AppText('Рабочее место', style: AppTextStyles.headingSmall),
              ),
              ImageScroll(imageUrls: master.workplace),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.ext.colors.white[300], width: 1)),
              ),
              child: Column(
                spacing: 8,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8,
                    children: [
                      const Flexible(child: AppText('Связаться с мастером:', style: AppTextStyles.headingSmall)),
                      BlotAvatar(avatarUrl: master.avatarUrl, size: 60),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8,
                    children: [
                      if (booking.status == BookingStatus.confirmed)
                        Flexible(
                          child: AppTextButtonSecondary.large(text: 'Позвонить', onTap: () => callMaster(master.id)),
                        ),
                      Flexible(
                        child: AppTextButtonSecondary.large(
                          text: 'Чат',
                          onTap: () => ChatsUtils().openChat(
                            context,
                            master.id,
                            master.fullName,
                            master.avatarUrl,
                            withClient: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            MasterAppointmentInfo(master: master),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: switch (booking.status) {
                BookingStatus.pending || BookingStatus.confirmed => Column(
                  spacing: 12,
                  children: [
                    AppTextButtonSecondary.large(
                      text: 'Изменить время записи',
                      onTap: () => _changeAppointmentTime(context),
                    ),
                    AppLinkButton(text: 'Отменить', onTap: () => _cancelAppointment(context)),
                  ],
                ),
                _ => AppTextButton.large(text: 'Записаться снова', onTap: () => _bookAgain(context)),
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.master, required this.title, required this.price, required this.status});

  final Master master;
  final String title;
  final int price;
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.fromLTRB(24, 16, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BlotAvatar(avatarUrl: master.avatarUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '${master.firstName} ${master.lastName}',
                  style: AppTextStyles.headingSmall.copyWith(height: 1),
                ),
                const SizedBox(height: 4),
                AppText(
                  master.profession,
                  style: AppTextStyles.bodyMedium.copyWith(color: context.ext.colors.black[700]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    AboutInfo.reviews(master: master),
                    AboutInfo.experience(master: master, short: true),
                  ],
                ),
                const SizedBox(height: 16),
                AppText(title),
                const SizedBox(height: 4),
                AppText('₽$price', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _BookingStatusBadge(status: status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingStatusBadge extends StatelessWidget {
  const _BookingStatusBadge({required this.status});

  final BookingStatus status;

  Color colorOf(BuildContext context) => switch (status) {
    BookingStatus.pending => context.ext.colors.pink[500],
    BookingStatus.confirmed => context.ext.colors.success,
    BookingStatus.canceled => context.ext.colors.error,
    BookingStatus.rejected => context.ext.colors.error,
    BookingStatus.completed => context.ext.colors.black[900],
  };

  Color bgColorOf(BuildContext context) => switch (status) {
    BookingStatus.pending => context.ext.colors.pink[100],
    BookingStatus.confirmed => context.ext.colors.white[200],
    BookingStatus.canceled => context.ext.colors.pink[100],
    BookingStatus.rejected => context.ext.colors.pink[100],
    BookingStatus.completed => context.ext.colors.white[300],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: bgColorOf(context),
        border: Border.all(color: colorOf(context)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: AppText(status.label, style: AppTextStyles.bodyMedium.copyWith(color: colorOf(context))),
    );
  }
}
