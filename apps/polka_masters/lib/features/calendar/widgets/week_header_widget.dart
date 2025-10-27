import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class WeekHeaderWidget extends StatelessWidget {
  const WeekHeaderWidget(this.date, {super.key});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: context.ext.theme.backgroundSubtle),
      child: Column(
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
