import 'package:polka_clients/features/booking/controller/bookings_cubit.dart';
import 'package:shared/shared.dart';

class UpcomingBookingsCubit extends BookingsCubit {
  UpcomingBookingsCubit({required super.repo, required super.websockets});

  @override
  Future<Result<List<Booking>>> loadItems(int page, int limit) =>
      repo.getUpcomingBookings(limit: limit, offset: (page - 1) * limit);
}
