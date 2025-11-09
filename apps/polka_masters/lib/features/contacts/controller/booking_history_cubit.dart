import 'package:polka_masters/features/calendar/data/bookings_repo.dart';
import 'package:shared/shared.dart';

class BookingHistoryCubit extends PaginationCubit<Booking> {
  BookingHistoryCubit(this.contactId, this.bookingsRepo);

  final BookingsRepository bookingsRepo;
  final int contactId;

  @override
  Future<Result<List<Booking>>> loadItems(int page, int limit) =>
      bookingsRepo.getBookingsHistory(contactId, page: page, limit: limit);
}
