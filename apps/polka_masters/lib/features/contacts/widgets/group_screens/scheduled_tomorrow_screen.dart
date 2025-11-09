import 'package:flutter/material.dart';
import 'package:polka_masters/dependencies.dart';
import 'package:polka_masters/features/contacts/controller/scheduled_tomorrow_bookings_cubit.dart';
import 'package:polka_masters/features/contacts/data/utils.dart';
import 'package:polka_masters/features/contacts/widgets/pending_booking_card.dart';
import 'package:shared/shared.dart';

class ScheduledTomorrowScreen extends StatefulWidget {
  const ScheduledTomorrowScreen({super.key});

  @override
  State<ScheduledTomorrowScreen> createState() => _ScheduledTomorrowScreenState();
}

class _ScheduledTomorrowScreenState extends State<ScheduledTomorrowScreen> {
  late final _cubit = ScheduledTomorrowBookingsCubit(
    Dependencies().bookingsRepository,
    Dependencies().webSocketService,
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const group = ContactGroup.scheduledTomorrow;
    return AppPage(
      appBar: CustomAppBar(title: '${group.blob} ${group.labelSingleVariant}'),
      safeAreaBuilder: (child) => SafeArea(bottom: false, child: child),
      child: PaginationBuilder<ScheduledTomorrowBookingsCubit, BookingInfo>(
        cubit: _cubit,
        emptyBuilder: (_) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: AppText('У тебя нет записей на завтра', style: AppTextStyles.headingSmall),
          ),
        ),
        itemBuilder: (context, index, item) => PendingBookingCard(
          info: item,
          onAccept: () => remindContact(context, item.contact),
          onReject: () => _cubit.cancelBooking(item.booking.id),
          acceptLabel: 'Напомнить',
          rejectLabel: 'Отменить',
        ),
      ),
    );
  }
}
