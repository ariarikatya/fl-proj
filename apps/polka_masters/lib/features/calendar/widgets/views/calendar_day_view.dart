import 'package:calendar_view/calendar_view.dart' hide WeekDays;
import 'package:flutter/material.dart';
import 'package:polka_masters/features/calendar/widgets/create_booking_button.dart';
import 'package:polka_masters/features/calendar/widgets/events/event_tile.dart';
import 'package:polka_masters/features/calendar/widgets/mbs/book_client_mbs.dart';
import 'package:polka_masters/features/calendar/widgets/mbs/booking_info_mbs.dart';
import 'package:polka_masters/features/calendar/widgets/notification_builder.dart';
import 'package:polka_masters/features/calendar/widgets/painters/schedule_day_hour_line_painter.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class CalendarDayView extends StatelessWidget {
  const CalendarDayView({super.key});

  Future<void> _bookClientOnHour(BuildContext context, DateTime date) async {
    final start = await DateTimePickerMBS.pickDuration(
      context,
      initValue: Duration(hours: date.hour),
      title: 'Выбери начало записи',
      canEditHours: false,
    );
    if (start != null && context.mounted) {
      await showBookClientMbs(context: context, start: date.dateOnly.add(start), canEditStartTime: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = context.watch<CalendarScope>();
    final offset = (DateTime.now().hour - 1.5) * CalendarScope.heigthPerMinuteRatio * 60;

    return Stack(
      children: [
        DayView<Booking>(
          initialDay: scope.date,
          controller: scope.eventController,
          onPageChange: (date, __) => scope.setDate(date),
          key: scope.dayViewKey,
          keepScrollOffset: true,
          safeAreaOption: const SafeAreaOption(bottom: false),
          dayTitleBuilder: (date) => _DayTitleBuilder(date),
          backgroundColor: context.ext.colors.white[100],
          eventTileBuilder: (date, events, boundary, startDuration, endDuration) => BookingEventTile(
            date: date,
            events: events,
            boundary: boundary,
            startDuration: startDuration,
            endDuration: endDuration,
          ),
          heightPerMinute: CalendarScope.heigthPerMinuteRatio,
          timeLineBuilder: (date) => DefaultTimeLineMark(
            date: date,
            timeStringBuilder: (date, {secondaryDate}) => date.formatTimeOnly(),
            markingStyle: AppTextStyles.bodySmall.copyWith(color: context.ext.colors.black[300]),
          ),
          onEventLongTap: devMode
              ? (events, date) {
                  if (events.firstOrNull?.event case Booking booking) showDebugModel(context, booking);
                }
              : null,
          verticalLineOffset: 0,
          hourIndicatorSettings: HourIndicatorSettings(height: 1, color: context.ext.colors.black[100], offset: 5),
          hourLinePainter: scheduleDayHourLinePainter(),
          liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
            color: context.ext.colors.black[900],
            bulletRadius: 0,
            height: 1.5,
          ),
          scrollOffset: offset,
          onDateTap: (date) => _bookClientOnHour(context, date),
          onEventTap: (events, date) {
            if (events.firstOrNull?.event case Booking booking) {
              showBookingInfoMbs(context: context, booking: booking);
            }
          },
          notificationBuilder: calendarNotificationBuilder,
        ),
        const Align(alignment: Alignment.bottomCenter, child: CreateBookingButton()),
      ],
    );
  }
}

class _DayTitleBuilder extends StatelessWidget {
  const _DayTitleBuilder(this.date);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.ext.colors.white[100],
        border: Border(bottom: BorderSide(color: context.ext.colors.white[200])),
      ),
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            WeekDays.values[date.weekday - 1].short,
            style: AppTextStyles.bodyMedium500.copyWith(
              color: isToday ? context.ext.colors.black[900] : context.ext.colors.black[300],
              height: 1,
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: isToday
                ? BoxDecoration(color: context.ext.colors.pink[500], borderRadius: BorderRadius.circular(6))
                : null,
            child: AppText(
              '${date.day}',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isToday ? context.ext.colors.white[100] : context.ext.colors.black[300],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
