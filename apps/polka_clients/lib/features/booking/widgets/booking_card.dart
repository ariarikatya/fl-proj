import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/features/booking/widgets/booking_page.dart';
import 'package:polka_clients/features/booking/booking_utils.dart';
import 'package:polka_clients/features/booking/controller/old_bookings_cubit.dart';
import 'package:shared/shared.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final isNew = context.read<OldBookingsCubit>().newBookingId == booking.id;

    final timeLabel =
        '${booking.date.formatShort()} • ${booking.startTime.toTimeString()}-${booking.endTime.toTimeString()}';

    Widget child = Padding(
      padding: const EdgeInsetsGeometry.all(24),
      child: Row(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ImageClipped(width: 104, height: 136, borderRadius: 18, imageUrl: booking.serviceImageUrl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: AppText(booking.serviceName, style: AppTextStyles.bodyLarge)),
                    if (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending)
                      _AddToCalendarBtn(booking),
                  ],
                ),
                Row(
                  spacing: 4,
                  children: [
                    AppAvatar(avatarUrl: booking.masterAvatarUrl ?? '', size: 24, shadow: false),
                    Flexible(
                      child: AppText(
                        booking.masterName,
                        style: AppTextStyles.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 4,
                  children: [
                    FIcons.clock.icon(context, size: 16),
                    Flexible(child: AppText(timeLabel.capitalized, style: AppTextStyles.bodyMedium)),
                  ],
                ),
                AppText('₽${booking.price}', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                AppText(
                  booking.status.label,
                  style: AppTextStyles.bodyMedium.copyWith(color: booking.status.colorOf(context)),
                ),
                _buttonsForStatus(context, booking.status),
              ],
            ),
          ),
        ],
      ),
    );

    if (isNew) {
      child = TweenAnimationBuilder(
        key: ValueKey(booking),
        tween: Tween(begin: .4, end: .0),
        duration: const Duration(milliseconds: 2000),
        child: child,
        onEnd: () => context.read<OldBookingsCubit>().markAsRead(),
        builder: (context, value, child) {
          return ColoredBox(
            color: context.ext.colors.pink[500].withValues(alpha: value),
            child: child,
          );
        },
      );
    }

    return DebugWidget(
      model: booking,
      child: GestureDetector(
        child: Material(color: Colors.transparent, child: child),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookingPage(booking: booking))),
      ),
    );
  }

  Widget _buttonsForStatus(BuildContext context, BookingStatus status) {
    return switch (status) {
      BookingStatus.confirmed => Row(
        spacing: 4,
        children: [
          Expanded(
            child: AppTextButtonSecondary.medium(text: 'Позвонить', onTap: () => callMaster(booking.masterId)),
          ),
          Expanded(
            child: AppTextButtonSecondary.medium(
              text: 'Чат',
              onTap: () => ChatsUtils().openChat(
                context,
                booking.masterId,
                booking.masterName,
                booking.masterAvatarUrl,
                withClient: false,
              ),
            ),
          ),
        ],
      ),
      BookingStatus.pending => AppTextButtonSecondary.medium(
        text: 'Чат',
        onTap: () => ChatsUtils().openChat(
          context,
          booking.masterId,
          booking.masterName,
          booking.masterAvatarUrl,
          withClient: false,
        ),
      ),
      BookingStatus.completed =>
        booking.reviewSent
            ? AppTextButtonSecondary.medium(text: 'Отзыв отправлен', onTap: () {}, enabled: false)
            : AppTextButtonSecondary.medium(text: 'Оставить отзыв', onTap: () => leaveReview(context, booking)),
      _ => const SizedBox.shrink(),
    };
  }
}

class _AddToCalendarBtn extends StatelessWidget {
  const _AddToCalendarBtn(this.booking);

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      borderRadius: BorderRadius.circular(16),
      elevation: 5,
      offset: const Offset(0, 24),
      menuPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: context.ext.colors.white[100],
      onSelected: (value) {
        if (value == 'calendar') addCalendarEvent(booking);
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'calendar',
          child: Row(
            spacing: 8,
            children: [
              FIcons.calendar.icon(context, size: 24, color: context.ext.colors.pink[500]),
              const AppText('Добавить в календарь', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
      child: Padding(padding: const EdgeInsets.all(4), child: FIcons.more_vertical.icon(context, size: 24)),
    );
  }
}
