import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        emptyBuilder: (_) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: AppText('У тебя пока нет новых заявок', style: AppTextStyles.headingSmall),
          ),
        ),
        itemBuilder: (context, index, item) => PendingBookingCard(
          info: item,
          onAccept: () => context.read<PendingBookingsCubit>().confirmBooking(item.booking.id),
          onReject: () => context.read<PendingBookingsCubit>().rejectBooking(item.booking.id),
        ),
      ),
    );
  }
}
