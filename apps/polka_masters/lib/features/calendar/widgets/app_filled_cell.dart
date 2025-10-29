import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class AppFilledCell<T extends Object?> extends StatelessWidget {
  /// Date of current cell.
  final DateTime date;

  /// List of events on for current date.
  final List<CalendarEventData<Booking>> events;

  /// Called when user taps on any event tile.
  final TileTapCallback<Booking>? onTileTap;

  /// Called when user long press on any event tile.
  final TileTapCallback<Booking>? onTileLongTap;

  /// Called when user double tap on any event tile.
  final TileTapCallback<Booking>? onTileDoubleTap;

  /// defines that [date] is in current month or not.
  final bool isInMonth;

  final bool isToday;

  /// This class will defines how cell will be displayed.
  /// This widget will display all the events as tile below date title.
  const AppFilledCell({
    super.key,
    required this.date,
    required this.events,
    required this.isToday,
    this.isInMonth = false,
    this.onTileTap,
    this.onTileLongTap,
    this.onTileDoubleTap,
  });

  const AppFilledCell.factory(
    DateTime $date,
    List<CalendarEventData<Booking>> $event,
    bool $isToday,
    bool $isInMonth,
    bool $hideDaysNotInMonth, {
    super.key,
    this.onTileTap,
    this.onTileLongTap,
    this.onTileDoubleTap,
  }) : date = $date,
       events = $event,
       isToday = $isToday,
       isInMonth = $isInMonth;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isInMonth ? context.ext.theme.backgroundDefault : context.ext.theme.backgroundHover;

    Widget dayWidget = Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: isToday
          ? BoxDecoration(color: context.ext.theme.accent, borderRadius: BorderRadius.circular(6))
          : null,
      child: AppText(
        '${date.day}',
        style: AppTextStyles.bodyLarge500.copyWith(
          color: isToday
              ? context.ext.theme.backgroundDefault
              : isInMonth
              ? context.ext.theme.textPrimary
              : context.ext.theme.textPlaceholder,
        ),
      ),
    );

    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          SizedBox(height: 8),
          dayWidget,
          if (events.isNotEmpty)
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 5.0),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [for (var event in events) EventCard(event: event)],

                  //  GestureDetector(
                  //   onTap: () => onTileTap?.call(events[index], date),
                  //   onLongPress: () => onTileLongTap?.call(events[index], date),
                  //   onDoubleTap: () => onTileDoubleTap?.call(events[index], date),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: events[index].event?.status.colorOf(context) ?? events[index].foregroundColor,
                  //     ),
                  //     margin: EdgeInsets.only(left: 1, bottom: 1),
                  //     padding: const EdgeInsets.all(2.0),
                  //     alignment: Alignment.center,
                  //     child: Row(
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             events[index].title,
                  //             overflow: TextOverflow.clip,
                  //             maxLines: 1,
                  //             style:
                  //                 events[index].titleStyle ??
                  //                 TextStyle(color: events[index].foregroundColor, fontSize: 12),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final CalendarEventData<Booking> event;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 1, bottom: 1),
      decoration: BoxDecoration(color: event.backgroundColor),
      child: Container(
        margin: EdgeInsets.only(left: 1),
        padding: EdgeInsets.fromLTRB(4, 4, 0, 4),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(color: event.foregroundColor),
        child: Text(
          event.title,
          style: event.titleStyle?.copyWith(height: 1),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }
}
