import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/repos/master_repository.dart';
import 'package:shared/shared.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key, required this.repo});

  final MasterRepository repo;

  @override
  Widget build(BuildContext context) {
    return LoadDataPage(
      onErrorBehavior: OnErrorBehavior.showErrorPage,
      future: () => Dependencies().masterRepository.getAllBookings(),
      builder: (bookings) => _AppointmentsView(bookings: bookings, repo: repo),
    );
  }
}

class _AppointmentsView extends StatefulWidget {
  const _AppointmentsView({required this.bookings, required this.repo});

  final List<Booking> bookings;
  final MasterRepository repo;

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
      appBar: CustomAppBar(title: 'Твои записи'),
      child: RefreshIndicator(
        onRefresh: _updateBookings,
        color: AppColors.accent,
        backgroundColor: AppColors.accentLight,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: bookings.length,
          separatorBuilder: (context, index) => SizedBox(height: 16),
          itemBuilder: (context, index) => Column(
            spacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.backgroundHover, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    AppAvatar(avatarUrl: bookings[index].masterAvatarUrl),
                    AppText(bookings[index].serviceName, style: AppTextStyles.bodyMedium),
                    AppText(bookings[index].datetime.toLocal().formatFull(), style: AppTextStyles.bodyMedium),
                    AppText(
                      bookings[index].status.label,
                      style: AppTextStyles.bodyMedium.copyWith(color: bookings[index].status.color),
                    ),
                    Row(
                      spacing: 8,
                      children: [
                        if (bookings[index].status == BookingStatus.pending) ...[
                          Flexible(
                            child: AppTextButton.small(
                              text: 'Confirm',
                              onTap: () => widget.repo
                                  .confirmBooking(bookings[index].id)
                                  .then(
                                    (r) => r.when(
                                      ok: (data) => _updateBookingStatus(index, BookingStatus.confirmed),
                                      err: handleError,
                                    ),
                                  ),
                            ),
                          ),
                          Flexible(
                            child: AppTextButton.small(
                              text: 'Reject',
                              onTap: () => widget.repo
                                  .rejectBooking(bookings[index].id)
                                  .then(
                                    (r) => r.when(
                                      ok: (data) => _updateBookingStatus(index, BookingStatus.rejected),
                                      err: handleError,
                                    ),
                                  ),
                            ),
                          ),
                        ],

                        if (bookings[index].status == BookingStatus.confirmed) ...[
                          Flexible(
                            child: AppTextButton.small(
                              text: 'Complete',
                              onTap: () => widget.repo
                                  .completeBooking(bookings[index].id)
                                  .then(
                                    (r) => r.when(
                                      ok: (data) => _updateBookingStatus(index, BookingStatus.completed),
                                      err: handleError,
                                    ),
                                  ),
                            ),
                          ),
                          Flexible(
                            child: AppTextButton.small(
                              text: 'Cancel',
                              onTap: () => widget.repo
                                  .cancelBooking(bookings[index].id)
                                  .then(
                                    (r) => r.when(
                                      ok: (data) => _updateBookingStatus(index, BookingStatus.canceled),
                                      err: handleError,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
