import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
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
  CalendarScope({required this.eventController});

  final EventController<Booking> eventController;
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
    // If view is current month, set current date to now when changing view to day/week
    final now = DateTime.now();
    if (_viewMode == CalendarViewMode.month && _date.month == now.month && _date.year == now.year) {
      _date = now;
    }

    _viewMode = $mode;
    notifyListeners();
  }
}
