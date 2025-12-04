import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared/src/extensions/datetime.dart';
import 'package:shared/src/models/schedule/schedule_day.dart';
import 'package:shared/src/models/schedule/weekdays.dart';

class Schedule extends Equatable {
  const Schedule({required this.periodStart, required this.periodEnd, required this.days, required this.createdAt});

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    periodStart: DateTime.parse(json['period_start']).dateOnly,
    periodEnd: DateTime.parse(json['period_end']).dateOnly,
    days: ((json['days'] as Map).cast<String, Map<String, dynamic>>()).map(
      (key, value) => MapEntry(WeekDays.fromJson(key), ScheduleDay.fromJson(value)),
    ),
    createdAt: DateTime.parse(json['created_at']),
  );

  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<WeekDays, ScheduleDay> days;
  final DateTime createdAt;

  DateTimeRange get dateTimeRange => DateTimeRange(start: periodStart, end: periodEnd);

  @override
  List<Object?> get props => [periodStart, periodEnd, days, createdAt];

  Schedule copyWith({
    ValueGetter<DateTime>? periodStart,
    ValueGetter<DateTime>? periodEnd,
    ValueGetter<Map<WeekDays, ScheduleDay>>? days,
    ValueGetter<DateTime>? createdAt,
  }) => Schedule(
    periodStart: periodStart != null ? periodStart.call() : this.periodStart,
    periodEnd: periodEnd != null ? periodEnd.call() : this.periodEnd,
    days: days != null ? days.call() : this.days,
    createdAt: createdAt != null ? createdAt.call() : this.createdAt,
  );

  Map<String, dynamic> toJson() => {
    'period_start': periodStart.toJson(),
    'period_end': periodEnd.toJson(),
    'days': {for (var e in days.entries) e.key.toJson(): e.value.toJson()},
    'created_at': createdAt.toJson(),
  };
}
