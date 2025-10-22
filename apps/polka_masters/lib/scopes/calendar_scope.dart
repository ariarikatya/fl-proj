import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:polka_masters/features/calendar/widgets/calendar_appbar.dart';
import 'package:shared/shared.dart';

enum CalendarViewMode {
  day('1 день', AppIcons.calendarViewDay),
  week('7 дней', AppIcons.calendarViewWeek),
  month('Месяц', AppIcons.calendarViewMonth);

  final String label;
  final AppIcons icon;
  const CalendarViewMode(this.label, this.icon);
}

class CalendarScope extends InheritedWidget {
  const CalendarScope({
    super.key,
    required this.controller,
    required this.viewMode,
    required this.changeViewMode,
    required this.monthViewKey,
    required this.weekViewKey,
    required this.dayViewKey,
    required this.calendarAppbarKey,
    required super.child,
  });

  final EventController controller;
  final CalendarViewMode viewMode;
  final GlobalKey<MonthViewState> monthViewKey;
  final GlobalKey<WeekViewState> weekViewKey;
  final GlobalKey<DayViewState> dayViewKey;
  final GlobalKey<CalendarAppbarState> calendarAppbarKey;
  final void Function(CalendarViewMode viewMode) changeViewMode;

  static CalendarScope of(BuildContext context, {bool listen = true}) =>
      CalendarScope.maybeOf(context, listen: listen)!;

  static CalendarScope? maybeOf(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<CalendarScope>();
    }
    return context.getInheritedWidgetOfExactType<CalendarScope>();
  }

  @override
  bool updateShouldNotify(CalendarScope oldWidget) =>
      controller != oldWidget.controller || viewMode != oldWidget.viewMode;
}

class CalendarScopeWidget extends StatefulWidget {
  const CalendarScopeWidget({required this.controller, required this.child, super.key});

  final EventController controller;
  final Widget child;

  @override
  State<CalendarScopeWidget> createState() => _CalendarScopeWidgetState();
}

class _CalendarScopeWidgetState extends State<CalendarScopeWidget> {
  var _viewMode = CalendarViewMode.month;

  void _changeViewMode(CalendarViewMode viewMode) {
    if (viewMode != _viewMode) {
      setState(() => _viewMode = viewMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalendarScope(
      controller: widget.controller,
      viewMode: _viewMode,
      changeViewMode: _changeViewMode,
      monthViewKey: GlobalKey<MonthViewState>(),
      weekViewKey: GlobalKey<WeekViewState>(),
      dayViewKey: GlobalKey<DayViewState>(),
      calendarAppbarKey: GlobalKey<CalendarAppbarState>(),
      child: CalendarControllerProvider(controller: widget.controller, child: widget.child),
    );
  }
}
