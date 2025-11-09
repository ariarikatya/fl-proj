import 'package:flutter/material.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class CalendarDrawer extends StatelessWidget {
  const CalendarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      color: context.ext.theme.backgroundSubtle,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  AppText('Выбери пероид', style: AppTextStyles.headingSmall.copyWith(fontWeight: FontWeight.w600)),
                  AppText(
                    'Мы покажем твое расписание на эти даты',
                    style: AppTextStyles.bodyLarge500.copyWith(color: context.ext.theme.textSecondary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(children: [for (var mode in CalendarViewMode.values) _ViewModeButton(mode)]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton(this.viewMode);

  final CalendarViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    final calendar = context.watch<CalendarScope>();
    final decoration = BoxDecoration(color: context.ext.theme.accentLight, borderRadius: BorderRadius.circular(16));

    return GestureDetector(
      onTap: () {
        calendar.setViewMode(viewMode);
        context.ext.pop();
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: calendar.viewMode == viewMode ? decoration : null,
          child: Row(spacing: 8, children: [viewMode.icon.icon(context), AppText(viewMode.label)]),
        ),
      ),
    );
  }
}
