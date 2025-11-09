import 'package:calendar_view/calendar_view.dart';
import 'package:polka_masters/features/calendar/widgets/events/event_tile.dart';
import 'package:polka_masters/features/calendar/widgets/mbs/booking_info_mbs.dart';
import 'package:polka_masters/features/calendar/widgets/painters/schedule_hour_line_painter.dart';
import 'package:polka_masters/features/calendar/widgets/week_header_widget.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:polka_masters/scopes/master_scope.dart';
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

    return WeekView<Booking>(
      initialDay: scope.date,
      onPageChange: (date, __) => scope.setDate(date),
      key: scope.weekViewKey,
      safeAreaOption: const SafeAreaOption(bottom: false),
      weekDayBuilder: WeekHeaderWidget.new,
      weekPageHeaderBuilder: (_, _) => const SizedBox.shrink(),
      weekNumberBuilder: (_) => Material(color: context.ext.theme.backgroundSubtle),
      backgroundColor: context.ext.theme.backgroundDefault,
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
        markingStyle: AppTextStyles.bodySmall.copyWith(color: context.ext.theme.textPlaceholder),
      ),
      hourIndicatorSettings: HourIndicatorSettings(height: 1, color: context.ext.theme.backgroundDisabled, offset: 5),
      hourLinePainter: scheduleHourLinePainter(context, context.watch<MasterScope>().schedule),
      liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
        color: context.ext.theme.textPrimary,
        bulletRadius: 0,
        height: 1.5,
      ),
      scrollOffset: offset,
      onDateTap: (date) {
        scope.setViewMode(CalendarViewMode.day);
        scope.setDate(date);
      },
    );
  }
}
