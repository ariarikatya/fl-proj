// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../calendar_event_data.dart';
import '../constants.dart';
import '../enumerations.dart';
import '../extensions.dart';
import '../typedefs.dart';
import 'components.dart';

/// This will be used in day and week view
class DefaultPressDetector extends StatelessWidget {
  /// default press detector builder used in week and day view
  const DefaultPressDetector({
    required this.date,
    required this.height,
    required this.width,
    required this.heightPerMinute,
    required this.minuteSlotSize,
    this.onDateTap,
    this.onDateLongPress,
    this.startHour = 0,
  });

  final DateTime date;
  final double height;
  final double width;
  final double heightPerMinute;
  final MinuteSlotSize minuteSlotSize;
  final DateTapCallback? onDateTap;
  final DatePressCallback? onDateLongPress;
  final int startHour;

  @override
  Widget build(BuildContext context) {
    final heightPerSlot = minuteSlotSize.minutes * heightPerMinute;
    final slots = (Constants.hoursADay * 60) ~/ minuteSlotSize.minutes;

    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          for (int i = 0; i < slots; i++)
            Positioned(
              top: heightPerSlot * i,
              left: 0,
              right: 0,
              bottom: height - (heightPerSlot * (i + 1)),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPress: () => onDateLongPress?.call(getSlotDateTime(i)),
                onTap: () => onDateTap?.call(getSlotDateTime(i)),
                child: SizedBox(width: width, height: heightPerSlot),
              ),
            ),
        ],
      ),
    );
  }

  DateTime getSlotDateTime(int slot) =>
      DateTime(date.year, date.month, date.day, 0, (minuteSlotSize.minutes * slot) + (startHour * 60));
}

/// This will be used in day view
class DefaultEventTile<T> extends StatelessWidget {
  const DefaultEventTile({
    required this.date,
    required this.events,
    required this.boundary,
    required this.startDuration,
    required this.endDuration,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 24, 2),
  });

  final DateTime date;
  final List<CalendarEventData<T>> events;
  final Rect boundary;
  final DateTime startDuration;
  final DateTime endDuration;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (events.isNotEmpty) {
      print(boundary.height);
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
class SmallEventTile<T> extends StatelessWidget {
  const SmallEventTile({
    required this.date,
    required this.events,
    required this.boundary,
    required this.startDuration,
    required this.endDuration,
    this.padding = const EdgeInsets.fromLTRB(4, 4, 0, 2),
  });

  final DateTime date;
  final List<CalendarEventData<T>> events;
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
