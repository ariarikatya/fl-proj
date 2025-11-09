import 'package:flutter/material.dart';
import 'package:polka_masters/features/contacts/controller/pending_bookings_cubit.dart';
import 'package:polka_masters/features/contacts/widgets/pending_booking_card.dart';
import 'package:shared/shared.dart';

class PendingBookingsScreen extends StatelessWidget {
  const PendingBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      safeAreaBuilder: (child) => SafeArea(bottom: false, child: child),
      child: PaginationBuilder<PendingBookingsCubit, BookingInfo>(
        cubit: blocs.get<PendingBookingsCubit>(context),
        emptyBuilder: (_) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: AppText('У тебя пока нет новых заявок', style: AppTextStyles.headingSmall),
          ),
        ),
        itemBuilder: (context, index, item) => PendingBookingCard(
          info: item,
          onAccept: () => blocs.get<PendingBookingsCubit>(context).confirmBooking(item.booking.id),
          onReject: () => blocs.get<PendingBookingsCubit>(context).rejectBooking(item.booking.id),
        ),
      ),
    );
  }
}
