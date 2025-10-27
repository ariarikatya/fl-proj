import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_masters/features/calendar/data/bookings_repo.dart';
import 'package:shared/shared.dart';

typedef Events = Map<DateTime, List<Booking>>;

class EventsCubit extends Cubit<Events> with SocketListenerMixin {
  EventsCubit(this.context, this.repo, this.websockets) : super({}) {
    controller = CalendarControllerProvider.of<Booking>(context).controller;
    reloadEvents();
    listenSockets(websockets);
  }

  final BuildContext context;
  final BookingsRepository repo;
  final WebSocketService websockets;
  late final EventController<Booking> controller;

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
        'deleted' => removeEvent(booking),
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

  Future<void> addEvent(Booking event) async {
    final colors = _getEventColors(event.status);
    controller.add(_createEvent(event, colors.bgcolor, colors.fgcolor));
  }

  Future<void> updateEvent(int bookingId, Booking newEvent) async {
    final colors = _getEventColors(newEvent.status);
    final oldEvent = controller.allEvents.firstWhere((e) => e.event?.id == bookingId);
    controller.update(oldEvent, _createEvent(newEvent, colors.bgcolor, colors.fgcolor));
  }

  Future<void> removeEvent(Booking event) async {
    final colors = _getEventColors(event.status);
    controller.remove(_createEvent(event, colors.bgcolor, colors.fgcolor));
  }

  Future<void> addTimeBlock(DateTime date, Duration startTime, Duration endTime) async {
    controller.add(_createTimeBlock(date, startTime, endTime));
  }

  Future<void> reloadEvents() async {
    final result = await repo.getAllBookings();

    controller.removeAll(controller.allEvents);
    if (result.unpack() case List<Booking> data) {
      for (var e in data) {
        if (const [BookingStatus.pending, BookingStatus.confirmed, BookingStatus.completed].contains(e.status)) {
          final colors = _getEventColors(e.status);
          controller.add(_createEvent(e, colors.bgcolor, colors.fgcolor));
        }
      }
    }
  }

  CalendarEventData<Booking> _createEvent(Booking event, Color bgcolor, Color fgcolor) => CalendarEventData(
    title: event.clientName,
    date: event.date,
    startTime: event.date.add(event.startTime),
    endTime: event.date.add(event.endTime),
    backgroundColor: bgcolor,
    foregroundColor: fgcolor,
    description: event.serviceName,
    titleStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: context.ext.theme.textPrimary),
    descriptionStyle: AppTextStyles.bodySmall.copyWith(
      fontWeight: FontWeight.w700,
      color: context.ext.theme.textSecondary,
    ),
    event: event,
  );

  CalendarEventData<Booking> _createTimeBlock(DateTime date, Duration startTime, Duration endTime) => CalendarEventData(
    title: 'time block',
    date: date,
    startTime: date.add(startTime),
    endTime: date.add(endTime),
    backgroundColor: context.ext.theme.iconsDefault,
    foregroundColor: context.ext.theme.backgroundDisabled,
  );

  ({Color bgcolor, Color fgcolor}) _getEventColors(BookingStatus status) => switch (status) {
    BookingStatus.confirmed => (bgcolor: context.ext.theme.accent, fgcolor: context.ext.theme.accentLight),
    BookingStatus.completed => (bgcolor: context.ext.theme.accent, fgcolor: context.ext.theme.accentLight),
    _ => (bgcolor: context.ext.theme.textPrimary, fgcolor: context.ext.theme.backgroundHover),
  };
}
