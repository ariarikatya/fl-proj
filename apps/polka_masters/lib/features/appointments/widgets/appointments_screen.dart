import 'package:flutter/material.dart';
import 'package:polka_masters/features/calendar/data/bookings_repo.dart';
import 'package:shared/shared.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key, required this.repo});

  final BookingsRepository repo;

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      onErrorBehavior: OnErrorBehavior.showErrorPage,
      future: () => repo.getAllBookings(),
      builder: (bookings) => _AppointmentsView(bookings: bookings, repo: repo),
    );
  }
}

class _AppointmentsView extends StatefulWidget {
  const _AppointmentsView({required this.bookings, required this.repo});

  final List<Booking> bookings;
  final BookingsRepository repo;

  @override
  State<_AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends State<_AppointmentsView> {
  late List<Booking> bookings = List.from(widget.bookings);

  @override
  void didChangeDependencies() {
    bookings = List.from(widget.bookings);
    super.didChangeDependencies();
  }

  void _updateBookingStatus(int index, BookingStatus status) {
    setState(() {
      bookings[index] = bookings[index].copyWith(status: () => status);
    });
  }

  Future<void> _updateBookings() async {
    final $bookings = (await widget.repo.getAllBookings()).unpack();
    if ($bookings != null) bookings = $bookings;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      appBar: const CustomAppBar(title: 'Твои записи'),
      child: RefreshIndicator(
        onRefresh: _updateBookings,
        color: context.ext.colors.pink[500],
        backgroundColor: context.ext.colors.pink[100],
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: bookings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _AppointmentCard(
              booking: bookings[index],
              repo: widget.repo,
              onUpdateStatus: (status) => _updateBookingStatus(index, status),
            );
          },
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.booking, required this.repo, required this.onUpdateStatus});

  final Booking booking;
  final BookingsRepository repo;
  final void Function(BookingStatus status) onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    return DebugWidget(
      model: booking,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: context.ext.colors.white[300], borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            AppAvatar(avatarUrl: booking.masterAvatarUrl),
            AppText(booking.serviceName, style: AppTextStyles.bodyMedium),
            AppText(booking.datetime.toLocal().formatFull(), style: AppTextStyles.bodyMedium),
            AppText(
              booking.status.label,
              style: AppTextStyles.bodyMedium.copyWith(color: booking.status.colorOf(context)),
            ),
            Row(
              spacing: 8,
              children: [
                if (booking.status == BookingStatus.pending) ...[
                  Flexible(
                    child: AppTextButton.small(
                      text: 'Confirm',
                      onTap: () => repo
                          .confirmBooking(booking.id)
                          .then((r) => r.when(ok: (data) => onUpdateStatus(BookingStatus.confirmed), err: handleError)),
                    ),
                  ),
                  Flexible(
                    child: AppTextButton.small(
                      text: 'Reject',
                      onTap: () => repo
                          .rejectBooking(booking.id)
                          .then((r) => r.when(ok: (data) => onUpdateStatus(BookingStatus.rejected), err: handleError)),
                    ),
                  ),
                ],

                if (booking.status == BookingStatus.confirmed) ...[
                  Flexible(
                    child: AppTextButton.small(
                      text: 'Complete',
                      onTap: () => repo
                          .completeBooking(booking.id)
                          .then((r) => r.when(ok: (data) => onUpdateStatus(BookingStatus.completed), err: handleError)),
                    ),
                  ),
                  Flexible(
                    child: AppTextButton.small(
                      text: 'Cancel',
                      onTap: () => repo
                          .cancelBooking(booking.id)
                          .then((r) => r.when(ok: (data) => onUpdateStatus(BookingStatus.canceled), err: handleError)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
