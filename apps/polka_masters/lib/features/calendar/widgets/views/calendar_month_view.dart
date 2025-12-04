import 'package:calendar_view/calendar_view.dart' hide WeekDays;
import 'package:flutter/material.dart';
import 'package:polka_masters/features/calendar/widgets/app_filled_cell.dart';
import 'package:polka_masters/features/calendar/widgets/notification_builder.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class CalendarMonthView extends StatelessWidget {
  const CalendarMonthView({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = context.read<CalendarScope>();

    return MonthView<Booking>(
      initialMonth: scope.date,
      controller: scope.eventController,
      onPageChange: (date, __) => scope.setDate(date),
      key: scope.monthViewKey,
      useAvailableVerticalSpace: true,
      safeAreaOption: const SafeAreaOption(bottom: false),
      weekDayBuilder: (index) => WeekDayTile(
        dayIndex: index,
        displayBorder: false,
        weekDayStringBuilder: (index) => WeekDays.values[index].short,
        backgroundColor: context.ext.colors.white[100],
        textStyle: AppTextStyles.bodyLarge500.copyWith(color: context.ext.colors.black[500]),
      ),
      cellBuilder: (date, event, isToday, isInMonth, hideDaysNotInMonth) => AppFilledCell.factory(
        date,
        event,
        isToday,
        isInMonth,
        hideDaysNotInMonth,
        onTileTap: (event, date) => _openDate(scope, date),
      ),
      borderColor: context.ext.colors.black[100],
      borderSize: 0.5,
      headerBuilder: (_) => const SizedBox.shrink(),
      notificationBuilder: calendarNotificationBuilder,
      onCellTap: (events, date) => _openDate(scope, date),
      hideDaysNotInMonth: true,
    );
  }

  void _openDate(CalendarScope scope, DateTime date) {
    scope.setViewMode(CalendarViewMode.day);
    scope.setDate(date);
  }
}
