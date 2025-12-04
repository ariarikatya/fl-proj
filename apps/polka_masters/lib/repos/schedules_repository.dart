import 'package:dio/dio.dart';
import 'package:shared/shared.dart';

sealed class SchedulesRepository {
  Future<Result<Schedule>> createSchedule(Schedule schedule);
  Future<Result<List<Schedule>>> getSchedules();

  Future<Result<bool>> blockTime({
    required DateTime date,
    required Duration startTime,
    required Duration endTime,
    String? reason,
  });

  Future<Result<bool>> blockTimePeriod({
    required DateTime startDate,
    required DateTime endDate,
    required Duration startTime,
    required Duration endTime,
    String? reason,
  });

  Future<Result<bool>> unblockTime({required DateTime date, required Duration startTime, required Duration endTime});
}

final class RestSchedulesRepository extends SchedulesRepository {
  RestSchedulesRepository(this.dio);
  final Dio dio;

  @override
  Future<Result<Schedule>> createSchedule(Schedule schedule) async {
    try {
      final response = await dio.post(
        '/schedules',
        data: schedule.toJson()
          ..['slot_interval_min'] = 30
          ..['auto_generate_slots'] = true,
      );
      return Result.ok(Schedule.fromJson(response.data['schedule']));
    } catch (e, st) {
      return Result.err(e, st);
    }
  }

  @override
  Future<Result<List<Schedule>>> getSchedules() => tryCatch(() async {
    final response = await dio.get('/schedules');
    return parseJsonList(response.data['schedules'], Schedule.fromJson, true)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  });

  @override
  Future<Result<bool>> blockTime({
    required DateTime date,
    required Duration startTime,
    required Duration endTime,
    String? reason,
  }) => tryCatch(() async {
    final response = await dio.post(
      '/master/block-time',
      data: {"date": date.toJson(), "start_time": startTime.toJson(), "end_time": endTime.toJson(), "reason": ?reason},
    );
    return response.data['success'] as bool;
  });

  @override
  Future<Result<bool>> blockTimePeriod({
    required DateTime startDate,
    required DateTime endDate,
    required Duration startTime,
    required Duration endTime,
    String? reason,
  }) => tryCatch(() async {
    final response = await dio.post(
      '/master/block-time/period',
      data: {
        "date_start": startDate.toJson(),
        "date_end": endDate.toJson(),
        "start_time": startTime.toJson(),
        "end_time": endTime.toJson(),
        "reason": ?reason,
      },
    );
    return response.data['success'] as bool;
  });

  @override
  Future<Result<bool>> unblockTime({required DateTime date, required Duration startTime, required Duration endTime}) =>
      tryCatch(() async {
        final response = await dio.post(
          '/master/unblock-time',
          data: {"date": date.toJson(), "start_time": startTime.toJson(), "end_time": endTime.toJson()},
        );
        return response.data['success'] as bool;
      });
}
