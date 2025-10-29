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
    final scope = context.watch<CalendarScope>();
    final date = scope.date;
    return Material(
      color: context.ext.theme.backgroundSubtle,
      child: SafeArea(
        child: SizedBox(
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
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
              if (false)
                Positioned(
                  top: switch (scope.viewMode) {
                    // Different views have different heights
                    CalendarViewMode.day => 96,
                    CalendarViewMode.week => 99,
                    CalendarViewMode.month => 93,
                  },
                  left: 0,
                  right: 0,
                  child: CalendarBanner$ScheduleRequired(),
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

class CalendarBanner$ScheduleRequired extends StatelessWidget {
  const CalendarBanner$ScheduleRequired({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
      color: context.ext.theme.accentLight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  'Твои свободные слоты сейчас не видны клиенту в приложении, заполни расписание, чтобы начать работу',
                  style: AppTextStyles.bodyLarge500,
                ),
              ),
              AppIcons.close.icon(context),
            ],
          ),
          SizedBox(height: 16),
          AppTextButtonTertiary.medium(text: 'Заполнить расписание', onTap: () {}),
        ],
      ),
    );
  }
}
