import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_masters/features/calendar/data/bookings_repo.dart';
import 'package:shared/shared.dart';

typedef Events = Map<DateTime, List<Booking>>;

class EventsCubit extends Cubit<Events> with SocketListenerMixin {
  EventsCubit({required this.context, required this.repo, required this.websockets, required this.controller})
    : super({}) {
    reloadEvents(); // TODO: HOW is this method gets called on every socket update???
    listenSockets(websockets);
  }

  final BuildContext context;
  final BookingsRepository repo;
  final WebSocketService websockets;
  final EventController<Booking> controller;

  @override
  void onSocketsMessage(json) {
    if (json case <String, Object?>{
      'type': 'appointment_update',
      'update_type': String updateType,
      'data': Map<String, Object?> data,
    }) {
      final booking = Booking.fromJson(data);
      var _ = switch (updateType) {
        'created' => addEvent(booking),
        'changed' => updateEvent(booking.id, booking),
        'deleted' => removeEvent(booking.id),
        _ => logger.error('unknown booking update type: $updateType'),
      };
      logger.debug('$updateType booking: ${booking.toJson()}');
    }
  }

  @override
  void onSocketsReconnect() {}

  @override
  Future<void> close() {
    unsubscribeSockets(websockets);
    return super.close();
  }

  Future<void> addEvent(Booking newEvent) async {
    logger.debug('adding event ${newEvent.id}');
    final colors = _getEventColors(newEvent);
    controller.add(_createEvent(newEvent, colors.bgcolor, colors.fgcolor));
  }

  Future<void> updateEvent(int bookingId, Booking event) async {
    logger.debug('updating event $bookingId');
    final colors = _getEventColors(event);
    final oldEvent = controller.allEvents.firstWhere((e) => e.event?.id == bookingId);
    controller.update(oldEvent, _createEvent(event, colors.bgcolor, colors.fgcolor));
  }

  Future<void> removeEvent(int bookingId) async {
    logger.debug('removing event $bookingId');
    controller.removeWhere((e) => e.event?.id == bookingId);
  }

  Future<void> reloadEvents() async {
    final result = await repo.getAllBookings();

    if (result.unpack() case List<Booking> data) {
      controller.removeAll(controller.allEvents);
      for (var e in data) {
        if (const [BookingStatus.pending, BookingStatus.confirmed, BookingStatus.completed].contains(e.status)) {
          final colors = _getEventColors(e);
          controller.add(_createEvent(e, colors.bgcolor, colors.fgcolor));
        }
      }
    }
  }

  CalendarEventData<Booking> _createEvent(Booking event, Color bgcolor, Color fgcolor) {
    return CalendarEventData(
      title: event.isTimeBlock ? 'Перерыв' : event.clientName,
      date: event.date,
      startTime: event.date.add(event.startTime),
      endTime: event.date.add(event.endTime),
      backgroundColor: bgcolor,
      foregroundColor: fgcolor,
      description: event.serviceName,
      titleStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: context.ext.colors.black[900]),
      descriptionStyle: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w700,
        color: context.ext.colors.black[700],
      ),
      event: event,
    );
  }

  ({Color bgcolor, Color fgcolor}) _getEventColors(Booking booking) => switch (booking) {
    Booking() when booking.isTimeBlock => ((
      bgcolor: context.ext.colors.black[700],
      fgcolor: context.ext.colors.white[200],
    )),
    _ => switch (booking.status) {
      BookingStatus.confirmed => (bgcolor: context.ext.colors.pink[500], fgcolor: context.ext.colors.pink[100]),
      BookingStatus.completed => (bgcolor: context.ext.colors.pink[500], fgcolor: context.ext.colors.pink[100]),
      _ => (bgcolor: context.ext.colors.black[900], fgcolor: context.ext.colors.white[300]),
    },
  };
}
