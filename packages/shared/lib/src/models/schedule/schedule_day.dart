import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/src/extensions/duration.dart';

class ScheduleDay extends Equatable {
  const ScheduleDay({required this.start, required this.end, required this.active});

  factory ScheduleDay.fromJson(Map<String, dynamic> json) => ScheduleDay(
    start: DurationX.fromTimeString(json['start'] as String),
    end: DurationX.fromTimeString(json['end'] as String),
    active: json['active'],
  );

  final Duration start;
  final Duration end;
  final bool active;

  @override
  List<Object?> get props => [start, end, active];

  ScheduleDay copyWith({
    ValueGetter<Duration>? start,
    ValueGetter<Duration>? end,
    ValueGetter<bool>? active,
  }) => ScheduleDay(
    start: start != null ? start.call() : this.start,
    end: end != null ? end.call() : this.end,
    active: active != null ? active.call() : this.active,
  );

  Map<String, dynamic> toJson() => {
    'start': start.toTimeString(),
    'end': end.toTimeString(),
    'active': active,
  };
}
