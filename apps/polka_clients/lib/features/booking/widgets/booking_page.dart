import 'package:flutter/material.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/booking/booking_utils.dart';
import 'package:polka_clients/features/booking/controller/bookings_cubit.dart';
import 'package:polka_clients/features/master_appointment/widgets/about_info.dart';
import 'package:polka_clients/features/master_appointment/widgets/master_appointment_info.dart';
import 'package:shared/shared.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      future: () => Dependencies().clientRepository.getMasterInfo(booking.masterId),
      builder: (data) => BookingView(
        booking: booking,
        master: data.master,
        service: data.services.firstWhere((e) => e.id == booking.serviceId),
      ),
    );
  }
}

class BookingView extends StatelessWidget {
  const BookingView({super.key, required this.booking, required this.master, required this.service});

  final Booking booking;
  final Master master;
  final Service service;

  void _bookAgain(BuildContext context) {
    blocs.get<BookingsCubit>(context).startAppointmentFlow(context, master, service);
  }

  void _cancelAppointment(BuildContext context) async {
    final cancel = await showConfirmBottomSheet(
      context: context,
      title: 'Ты уверена, что хочешь отменить запись?',
      acceptText: 'Да',
      declineText: 'Нет',
    );
    if (context.mounted && cancel == true) {
      final changed = await blocs.get<BookingsCubit>(context).cancelAppointment(context, booking.id);
      if (context.mounted && changed) context.ext.pop();
    }
  }

  void _changeAppointmentTime(BuildContext context) async {
    final changed = await blocs.get<BookingsCubit>(context).changeAppointmentTime(context, booking);
    if (context.mounted && changed) context.ext.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: CustomAppBar(title: 'Твоя услуга'),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(master: master, title: service.title, price: service.price, status: booking.status),
            if (booking.status == BookingStatus.completed)
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: booking.reviewSent
                    ? AppTextButtonSecondary.large(text: 'Отзыв отправлен', onTap: () {}, enabled: false)
                    : AppTextButtonSecondary.large(text: 'Оставить отзыв', onTap: () => leaveReview(context, booking)),
              ),
            Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: AppColors.backgroundHover, width: 1)),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  AppText('Когда:', style: AppTextStyles.headingSmall),
                  AppText(
                    booking.datetime.formatFull(),
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                  ),
                  if (booking.status == BookingStatus.confirmed)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: AppTextButtonSecondary.large(
                        text: 'Добавить в календарь',
                        onTap: () => addCalendarEvent(booking),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    AppText('Где:', style: AppTextStyles.headingSmall),
                    AppText(
                      service.location.label,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    AppText(
                      master.address,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    AppTextButtonSecondary.large(
                      text: 'Показать на карте',
                      onTap: () => showOnMap(context, master.latitude, master.longitude, service.title),
                    ),
                  ],
                ),
              ),
            ),
            if (master.workplace.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: AppText('Рабочее место', style: AppTextStyles.headingSmall),
              ),
              ImageScroll(imageUrls: master.workplace),
              SizedBox(height: 16),
            ],
            Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.backgroundHover, width: 1)),
              ),
              child: Column(
                spacing: 8,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8,
                    children: [
                      Flexible(child: AppText('Связаться с мастером:', style: AppTextStyles.headingSmall)),
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
                          onTap: () => openChat(context, master.id, master.fullName, master.avatarUrl),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            MasterAppointmentInfo(master: master),
            SizedBox(height: 16),
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
            SizedBox(height: 16),
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
      padding: EdgeInsetsGeometry.fromLTRB(24, 16, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          BlotAvatar(avatarUrl: master.avatarUrl),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '${master.firstName} ${master.lastName}',
                  style: AppTextStyles.headingSmall.copyWith(height: 1),
                ),
                SizedBox(height: 4),
                AppText(master.profession, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    AboutInfo.reviews(master: master),
                    AboutInfo.experience(master: master, short: true),
                  ],
                ),
                SizedBox(height: 16),
                AppText(title),
                SizedBox(height: 4),
                AppText('₽$price', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
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

  Color get color => switch (status) {
    BookingStatus.pending => AppColors.accent,
    BookingStatus.confirmed => AppColors.success,
    BookingStatus.canceled => AppColors.error,
    BookingStatus.rejected => AppColors.error,
    BookingStatus.completed => AppColors.textPrimary,
  };

  Color get bgColor => switch (status) {
    BookingStatus.pending => AppColors.accentLight,
    BookingStatus.confirmed => AppColors.successLight,
    BookingStatus.canceled => AppColors.accentLight,
    BookingStatus.rejected => AppColors.accentLight,
    BookingStatus.completed => AppColors.backgroundHover,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(100),
      ),
      child: AppText(status.label, style: AppTextStyles.bodyMedium.copyWith(color: color)),
    );
  }
}
