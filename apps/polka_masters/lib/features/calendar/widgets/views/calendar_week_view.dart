import 'package:calendar_view/calendar_view.dart';
import 'package:polka_masters/features/calendar/widgets/schedule_hour_line_painter.dart';
import 'package:polka_masters/features/calendar/widgets/week_header_widget.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:polka_masters/scopes/master_scope.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class CalendarWeekView extends StatefulWidget {
  const CalendarWeekView({super.key});

  @override
  State<CalendarWeekView> createState() => _CalendarWeekViewState();
}

class _CalendarWeekViewState extends State<CalendarWeekView> {
  static const _heightPerMinuteRatio = 1.75;

  @override
  Widget build(BuildContext context) {
    final offset = (DateTime.now().hour - 1.5) * _heightPerMinuteRatio * 60;
    final scope = CalendarScope.of(context);

    return WeekView(
      onPageChange: (date, __) => scope.calendarAppbarKey.currentState?.updateDate(date),
      key: scope.weekViewKey,
      safeAreaOption: SafeAreaOption(bottom: false),
      weekDayBuilder: WeekHeaderWidget.new,
      weekPageHeaderBuilder: (_, _) => SizedBox.shrink(),
      weekNumberBuilder: (_) => Material(color: AppColors.backgroundSubtle),
      backgroundColor: AppColors.backgroundDefault,
      heightPerMinute: _heightPerMinuteRatio,
      timeLineBuilder: (date) => DefaultTimeLineMark(
        date: date,
        timeStringBuilder: (date, {secondaryDate}) => date.formatTimeOnly(),
        markingStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textPlaceholder),
      ),
      hourIndicatorSettings: HourIndicatorSettings(height: 1, color: AppColors.backgroundDisabled, offset: 5),
      hourLinePainter: _scheduleHourLinePainter,
      liveTimeIndicatorSettings: LiveTimeIndicatorSettings(color: AppColors.textPrimary, bulletRadius: 0, height: 1.5),
      scrollOffset: offset,
    );
  }

  ScheduleHourLinePainter _scheduleHourLinePainter(
    Color lineColor,
    double lineHeight,
    double offset,
    double minuteHeight,
    bool showVerticalLine,
    double verticalLineOffset,
    LineStyle lineStyle,
    double dashWidth,
    double dashSpaceWidth,
    double emulateVerticalOffsetBy,
    int startHour,
    int endHour,
  ) => ScheduleHourLinePainter(
    lineColor: lineColor,
    lineHeight: lineHeight,
    offset: offset,
    minuteHeight: minuteHeight,
    showVerticalLine: showVerticalLine,
    startHour: startHour,
    emulateVerticalOffsetBy: emulateVerticalOffsetBy,
    verticalLineOffset: verticalLineOffset,
    lineStyle: lineStyle,
    dashWidth: dashWidth,
    dashSpaceWidth: dashSpaceWidth,
    endHour: endHour,
    schedule: MasterScope.of(context).schedule,
  );
}
