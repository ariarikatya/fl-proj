import 'package:polka_masters/features/calendar/data/bookings_repo.dart';
import 'package:shared/shared.dart';

class ScheduledTomorrowBookingsCubit extends PaginationCubit<BookingInfo> with SocketListenerMixin {
  ScheduledTomorrowBookingsCubit(this.repo, this.websockets) {
    listenSockets(websockets);
  }

  final BookingsRepository repo;
  final WebSocketService websockets;

  @override
  Future<void> close() {
    unsubscribeSockets(websockets);
    return super.close();
  }

  @override
  Future<Result<List<BookingInfo>>> loadItems(int page, int limit) =>
      repo.getScheduledTomorrowBookingsInfo(page: page, limit: limit);

  void cancelBooking(int bookingId) async {
    final result = await repo.cancelBooking(bookingId);
    result.when(ok: (_) => showInfoSnackbar('Заявка отменена'), err: handleError);
  }

  @override
  void onSocketsMessage(json) {
    if (json case <String, Object?>{'type': 'appointment_update', 'update_type': String _}) {
      reset();
    }
  }

  @override
  void onSocketsReconnect() {}
}
