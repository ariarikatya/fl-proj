import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

enum CalendarViewMode {
  day('1 день', AppIcons.calendarViewDay),
  week('7 дней', AppIcons.calendarViewWeek),
  month('Месяц', AppIcons.calendarViewMonth);

  final String label;
  final AppIcons icon;
  const CalendarViewMode(this.label, this.icon);
}

class CalendarScope extends ChangeNotifier {
  CalendarScope();

  final _controller = EventController<Booking>();
  final monthViewKey = GlobalKey<MonthViewState>();
  final weekViewKey = GlobalKey<WeekViewState>();
  final dayViewKey = GlobalKey<DayViewState>();

  var _viewMode = CalendarViewMode.month;
  CalendarViewMode get viewMode => _viewMode;

  var _date = DateTime.now();
  DateTime get date => _date;

  static double heigthPerMinuteRatio = 1.75;

  void setDate($date) {
    _date = $date;
    notifyListeners();
  }

  void setViewMode(CalendarViewMode $mode) {
    _viewMode = $mode;
    // _date = DateTime.now();
    notifyListeners();
  }
}

class CalendarScopeWidget extends StatelessWidget {
  const CalendarScopeWidget({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalendarScope(),
      builder: (ctx, _) {
        final controller = ctx.read<CalendarScope>()._controller;
        return CalendarControllerProvider(controller: controller, child: child);
      },
    );
  }
}
