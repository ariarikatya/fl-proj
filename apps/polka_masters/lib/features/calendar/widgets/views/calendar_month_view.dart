import 'package:calendar_view/calendar_view.dart' hide WeekDays;
import 'package:flutter/material.dart';
import 'package:polka_masters/features/calendar/widgets/app_filled_cell.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:shared/shared.dart';

class CalendarMonthView extends StatelessWidget {
  const CalendarMonthView({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = CalendarScope.of(context);

    return MonthView(
      onPageChange: (date, __) => scope.calendarAppbarKey.currentState?.updateDate(date),
      key: scope.monthViewKey,
      useAvailableVerticalSpace: true,
      safeAreaOption: SafeAreaOption(bottom: false),
      weekDayBuilder: (index) => WeekDayTile(
        dayIndex: index,
        displayBorder: false,
        weekDayStringBuilder: (index) => WeekDays.values[index].short,
        backgroundColor: AppColors.backgroundSubtle,
        textStyle: AppTextStyles.bodyLarge2.copyWith(color: AppColors.textPlaceholder),
      ),
      cellBuilder: AppFilledCell.factory,
      borderColor: AppColors.backgroundDisabled,
      borderSize: 0.5,
      headerBuilder: (_) => SizedBox.shrink(),
      onCellTap: (events, date) => CalendarScope.of(context).monthViewKey.currentState?.animateToMonth(date),
    );
  }
}
