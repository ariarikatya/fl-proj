import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';

class CalendarDayView extends StatelessWidget {
  const CalendarDayView({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = CalendarScope.of(context);

    return DayView(
      onPageChange: (date, __) => scope.calendarAppbarKey.currentState?.updateDate(date),
      key: scope.dayViewKey,
      safeAreaOption: SafeAreaOption(bottom: false),
      // onCellTap: (events, date) =>
      //     CalendarScope.of(context).monthViewKey.currentState?.animateToMonth(date.add(Duration(days: 31))),
    );
  }
}
