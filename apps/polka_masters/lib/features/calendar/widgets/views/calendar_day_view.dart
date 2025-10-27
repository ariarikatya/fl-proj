import 'package:calendar_view/calendar_view.dart' hide WeekDays;
import 'package:flutter/material.dart';
import 'package:polka_masters/features/calendar/widgets/events/event_tile.dart';
import 'package:polka_masters/features/calendar/widgets/mbs/book_client_mbs.dart';
import 'package:polka_masters/features/calendar/widgets/mbs/booking_info_mbs.dart';
import 'package:polka_masters/features/calendar/widgets/painters/schedule_day_hour_line_painter.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class CalendarDayView extends StatelessWidget {
  const CalendarDayView({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = context.read<CalendarScope>();
    final scheduleDay = MasterScope.of(context).schedule.days[WeekDays.fromDateTime(scope.date)];
    final offset = (DateTime.now().hour - 1.5) * CalendarScope.heigthPerMinuteRatio * 60;

    return Stack(
      children: [
        DayView<Booking>(
          initialDay: scope.date,
          onPageChange: (date, __) => scope.setDate(date),
          key: scope.dayViewKey,
          keepScrollOffset: true,
          safeAreaOption: SafeAreaOption(bottom: false),
          dayTitleBuilder: (date) => _DayTitleBuilder(date),
          backgroundColor: context.ext.theme.backgroundDefault,
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
            markingStyle: AppTextStyles.bodySmall.copyWith(color: context.ext.theme.textPlaceholder),
          ),
          onEventLongTap: devMode
              ? (events, date) {
                  if (events.firstOrNull?.event case Booking booking) showDebugModel(context, booking);
                }
              : null,
          verticalLineOffset: 0,
          hourIndicatorSettings: HourIndicatorSettings(
            height: 1,
            color: context.ext.theme.backgroundDisabled,
            offset: 5,
          ),
          hourLinePainter: scheduleDayHourLinePainter(context, scheduleDay),
          liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
            color: context.ext.theme.textPrimary,
            bulletRadius: 0,
            height: 1.5,
          ),
          scrollOffset: offset,
          onDateTap: (date) => showBookClientMbs(context: context, start: date),
          onEventTap: (events, date) {
            if (events.firstOrNull?.event case Booking booking) {
              showBookingInfoMbs(context: context, booking: booking);
            }
          },
        ),
        Align(alignment: Alignment.bottomCenter, child: _CreateBookingButton()),
      ],
    );
  }
}

class _CreateBookingButton extends StatelessWidget {
  const _CreateBookingButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showBookClientMbs(context: context, start: DateTime.now().withoutMinutes),
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.fromLTRB(8, 12, 16, 12),
        decoration: BoxDecoration(color: context.ext.theme.buttonPrimary, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            AppIcons.add.icon(context, color: context.ext.theme.backgroundDefault),
            AppText('Создать  запись', color: context.ext.theme.backgroundDefault),
          ],
        ),
      ),
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
        color: context.ext.theme.backgroundSubtle,
        border: Border(bottom: BorderSide(color: context.ext.theme.backgroundDisabled)),
      ),
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            WeekDays.values[date.weekday - 1].short,
            style: AppTextStyles.bodyMedium500.copyWith(
              color: isToday ? context.ext.theme.textPrimary : context.ext.theme.textPlaceholder,
              height: 1,
            ),
          ),
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: isToday
                ? BoxDecoration(color: context.ext.theme.accent, borderRadius: BorderRadius.circular(6))
                : null,
            child: AppText(
              '${date.day}',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isToday ? context.ext.theme.backgroundDefault : context.ext.theme.textPlaceholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
