import 'package:flutter/material.dart';
import 'package:polka_masters/features/calendar/widgets/calendar_appbar.dart';
import 'package:polka_masters/features/calendar/widgets/calendar_drawer.dart';
import 'package:polka_masters/features/calendar/widgets/views/calendar_day_view.dart';
import 'package:polka_masters/features/calendar/widgets/views/calendar_month_view.dart';
import 'package:polka_masters/features/calendar/widgets/views/calendar_week_view.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewMode = context.watch<CalendarScope>().viewMode;

    return Scaffold(
      appBar: const CalendarAppbar(),
      drawer: const CalendarDrawer(),
      body: switch (viewMode) {
        CalendarViewMode.month => const CalendarMonthView(),
        CalendarViewMode.week => const CalendarWeekView(),
        CalendarViewMode.day => const CalendarDayView(),
      },
    );
  }
}
