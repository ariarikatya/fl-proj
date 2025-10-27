import 'package:flutter/material.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class CalendarAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CalendarAppbar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final date = context.watch<CalendarScope>().date;
    return Material(
      color: context.ext.theme.backgroundSubtle,
      child: SafeArea(
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            spacing: 24,
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(padding: const EdgeInsets.all(8.0), child: AppIcons.drawer.icon(context)),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final newDate = await DateTimePickerMBS.pickDate(context, initValue: date);
                  if (newDate != null && context.mounted) {
                    _updateDate(context, newDate);
                  }
                },
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      AppText(date.format('MMMM').capitalized, style: AppTextStyles.headingLarge),
                      AppIcons.arrowDown.icon(context),
                    ],
                  ),
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => _updateDate(context, DateTime.now()),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.ext.theme.borderSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AppText(DateTime.now().format('d')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateDate(BuildContext context, DateTime date) {
    context.read<CalendarScope>().setDate(date);
    context.read<CalendarScope>()
      ..dayViewKey.currentState?.animateToDate(date)
      ..weekViewKey.currentState?.animateToWeek(date)
      ..monthViewKey.currentState?.animateToMonth(date);
  }
}
