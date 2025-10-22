import 'package:flutter/material.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:shared/shared.dart';

class CalendarAppbar extends StatefulWidget implements PreferredSizeWidget {
  const CalendarAppbar({super.key});

  @override
  State<CalendarAppbar> createState() => CalendarAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(48);
}

class CalendarAppbarState extends State<CalendarAppbar> {
  late DateTime? date = CalendarScope.of(context).monthViewKey.currentState?.currentDate;

  void updateDate(DateTime $date) => setState(() => date = $date);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundSubtle,
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
                  child: Padding(padding: const EdgeInsets.all(8.0), child: AppIcons.drawer.icon()),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  AppText(date?.format('MMMM').capitalized ?? '', style: AppTextStyles.headingLarge),
                  AppIcons.arrowDown.icon(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
