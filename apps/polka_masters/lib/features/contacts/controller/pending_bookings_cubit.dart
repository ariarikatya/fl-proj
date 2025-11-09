import 'package:polka_masters/features/calendar/data/bookings_repo.dart';
import 'package:shared/shared.dart';

class PendingBookingsCubit extends PaginationCubit<BookingInfo> with SocketListenerMixin {
  PendingBookingsCubit(this.repo, this.websockets) {
    listenSockets(websockets);
    load();
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
      repo.getPendingBookingsInfo(page: page, limit: limit);

  void confirmBooking(int bookingId) async {
    final result = await repo.confirmBooking(bookingId);
    result.when(ok: (_) => showSuccessSnackbar('Заявка принята'), err: handleError);
  }

  void rejectBooking(int bookingId) async {
    final result = await repo.rejectBooking(bookingId);
    result.when(ok: (_) => showInfoSnackbar('Заявка отклонена'), err: handleError);
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
