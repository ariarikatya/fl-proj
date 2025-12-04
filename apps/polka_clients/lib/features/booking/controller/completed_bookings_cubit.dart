import 'package:polka_clients/features/booking/controller/bookings_cubit.dart';
import 'package:shared/shared.dart';

class CompletedBookingsCubit extends BookingsCubit {
  CompletedBookingsCubit({required super.repo, required super.websockets});

  @override
  Future<Result<List<Booking>>> loadItems(int page, int limit) =>
      repo.getCompletedBookings(limit: limit, offset: (page - 1) * limit);

  void markAsReviewed(int bookingId) => reset();
}
