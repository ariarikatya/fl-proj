import 'package:polka_clients/features/booking/data/bookings_repo.dart';
import 'package:shared/shared.dart';

abstract class BookingsCubit extends PaginationCubit<Booking> with SocketListenerMixin {
  BookingsCubit({required this.repo, required this.websockets}) {
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
  void onSocketsMessage(json) {
    if (json case <String, Object?>{'type': 'appointment_update', 'update_type': String _}) {
      reset();
    }
  }

  @override
  void onSocketsReconnect() => reset();
}
