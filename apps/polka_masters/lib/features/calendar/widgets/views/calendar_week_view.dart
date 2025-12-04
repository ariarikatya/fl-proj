import 'package:calendar_view/calendar_view.dart';
import 'package:polka_masters/features/calendar/widgets/create_booking_button.dart';
import 'package:polka_masters/features/calendar/widgets/events/event_tile.dart';
import 'package:polka_masters/features/calendar/widgets/mbs/booking_info_mbs.dart';
import 'package:polka_masters/features/calendar/widgets/notification_builder.dart';
import 'package:polka_masters/features/calendar/widgets/painters/working_hours_line_painter.dart';
import 'package:polka_masters/features/calendar/widgets/week_header_widget.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class CalendarWeekView extends StatefulWidget {
  const CalendarWeekView({super.key});

  @override
  State<CalendarWeekView> createState() => _CalendarWeekViewState();
}

class _CalendarWeekViewState extends State<CalendarWeekView> {
  @override
  Widget build(BuildContext context) {
    final offset = (DateTime.now().hour - 1.5) * CalendarScope.heigthPerMinuteRatio * 60;
    final scope = context.read<CalendarScope>();

    return Stack(
      children: [
        WeekView<Booking>(
          initialDay: scope.date,
          controller: scope.eventController,
          onPageChange: (date, __) => scope.setDate(date),
          key: scope.weekViewKey,
          safeAreaOption: const SafeAreaOption(bottom: false),
          weekDayBuilder: WeekHeaderWidget.new,
          weekPageHeaderBuilder: (_, _) => const SizedBox.shrink(),
          weekNumberBuilder: (_) => Material(color: context.ext.colors.white[100]),
          backgroundColor: context.ext.colors.white[100],
          heightPerMinute: CalendarScope.heigthPerMinuteRatio,
          eventTileBuilder: (date, events, boundary, startDuration, endDuration) => GestureDetector(
            onTap: () {
              if (events.firstOrNull?.event case Booking booking) {
                showBookingInfoMbs(context: context, booking: booking);
              }
            },
            onLongPress: devMode
                ? () {
                    if (events.firstOrNull?.event case Booking booking) showDebugModel(context, booking);
                  }
                : null,
            child: SmallBookingEventTile(
              date: date,
              events: events,
              boundary: boundary,
              startDuration: startDuration,
              endDuration: endDuration,
            ),
          ),
          timeLineBuilder: (date) => DefaultTimeLineMark(
            date: date,
            timeStringBuilder: (date, {secondaryDate}) => date.formatTimeOnly(),
            markingStyle: AppTextStyles.bodySmall.copyWith(color: context.ext.colors.black[300]),
          ),
          hourIndicatorSettings: HourIndicatorSettings(height: 1, color: context.ext.colors.black[100], offset: 5),
          hourLinePainter: scheduleHourLinePainter(),
          liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
            color: context.ext.colors.black[900],
            bulletRadius: 0,
            height: 1.5,
          ),
          scrollOffset: offset,
          keepScrollOffset: true,
          onDateTap: (date) {
            scope.setViewMode(CalendarViewMode.day);
            scope.setDate(date);
          },
          notificationBuilder: calendarNotificationBuilder,
        ),
        const Align(alignment: Alignment.bottomCenter, child: CreateBookingButton()),
      ],
    );
  }
}
