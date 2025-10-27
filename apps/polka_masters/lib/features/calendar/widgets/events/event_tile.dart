import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// This will be used in day view
class BookingEventTile extends StatelessWidget {
  const BookingEventTile({
    super.key,
    required this.date,
    required this.events,
    required this.boundary,
    required this.startDuration,
    required this.endDuration,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 24, 2),
  });

  final DateTime date;
  final List<CalendarEventData<Booking>> events;
  final Rect boundary;
  final DateTime startDuration;
  final DateTime endDuration;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (events.isNotEmpty) {
      final event = events[0];

      return RoundedEventTile(
        boundary: boundary,
        borderRadius: BorderRadius.circular(8),
        backgroundBorderWidth: 4,
        title: event.title,
        totalEvents: events.length - 1,
        description: event.description,
        padding: padding,
        backgroundColor: event.backgroundColor,
        margin: EdgeInsets.only(bottom: 3),
        titleStyle: event.titleStyle,
        descriptionStyle: event.descriptionStyle,
        foregroundColor: event.foregroundColor,
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

/// This will be used week and month view
class SmallBookingEventTile extends StatelessWidget {
  const SmallBookingEventTile({
    super.key,
    required this.date,
    required this.events,
    required this.boundary,
    required this.startDuration,
    required this.endDuration,
    this.padding = const EdgeInsets.fromLTRB(4, 4, 0, 2),
  });

  final DateTime date;
  final List<CalendarEventData<Booking>> events;
  final Rect boundary;
  final DateTime startDuration;
  final DateTime endDuration;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (events.isNotEmpty) {
      final event = events[0];

      return RoundedEventTile(
        boundary: boundary,
        borderRadius: BorderRadius.circular(0),
        backgroundBorderWidth: 2,
        title: event.title,
        totalEvents: events.length - 1,
        description: event.description,
        padding: padding,
        backgroundColor: event.backgroundColor,
        margin: EdgeInsets.only(left: 1, bottom: 1),
        titleStyle: event.titleStyle,
        descriptionStyle: event.descriptionStyle,
        foregroundColor: event.foregroundColor,
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
