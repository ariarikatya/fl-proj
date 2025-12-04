import 'package:flutter/material.dart';
import 'package:polka_masters/features/calendar/widgets/mbs/book_client_mbs.dart';
import 'package:polka_masters/scopes/calendar_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

import '../../schedules/controller/schedules_cubit.dart';

class CreateBookingButton extends StatelessWidget {
  const CreateBookingButton({super.key});

  Future<void> _bookClient(BuildContext context) async {
    final date = await DateTimePickerMBS.pickDate(context);
    if (date != null && context.mounted) {
      final scheduleDay = context.read<SchedulesCubit>().scheduleDayOf(date);
      final startDate = date.add(scheduleDay?.start ?? const Duration(hours: 12));
      final result = await showBookClientMbs(context: context, start: startDate);
      if (result != null && context.mounted) {
        final scope = context.read<CalendarScope>();
        scope.setDate(date);
        scope.setViewMode(CalendarViewMode.day);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFloatingActionButton$Add(text: 'Создать  запись', onTap: () => _bookClient(context));
  }
}
