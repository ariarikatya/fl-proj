import 'package:polka_masters/features/schedules/widgets/schedule_mbs.dart';
import 'package:polka_masters/repos/schedules_repository.dart';
import 'package:shared/shared.dart';

class SchedulesCubit extends DataCubit<List<Schedule>> {
  SchedulesCubit(this.repo);
  final SchedulesRepository repo;

  @override
  Future<Result<List<Schedule>>> loadData() => repo.getSchedules();

  Schedule? scheduleOf(DateTime date) {
    return data?.where((schedule) => schedule.dateTimeRange.containsDate(date)).firstOrNull;
  }

  ScheduleDay? scheduleDayOf(DateTime date) {
    return scheduleOf(date.dateOnly)?.days[WeekDays.fromDateTime(date.dateOnly)];
  }

  Future<void> createSchedule(Schedule schedule, List<ScheduleBreak> breaks) async {
    emit(DataState.loading());
    final result = await repo.createSchedule(schedule);
    result.when(
      ok: (_) {
        _blockTimePeriods(schedule, breaks);
        showInfoSnackbar('Расписание успешно обновлено');
        load();
      },
      err: (err, st) {
        emit(DataState.error(parseError(err, st)));
      },
    );
  }

  void _blockTimePeriods(Schedule schedule, List<ScheduleBreak> breaks) {
    for (var $break in breaks) {
      repo
          .blockTimePeriod(
            startDate: schedule.periodStart.dateOnly,
            endDate: schedule.periodEnd.dateOnly,
            startTime: $break.start,
            endTime: $break.end,
          )
          .ignore();
    }
  }
}
