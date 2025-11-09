import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class AvailableSlot extends Equatable {
  const AvailableSlot({required this.id, required this.datetime, required this.duration});

  factory AvailableSlot.fromJson(Map<String, dynamic> json) => AvailableSlot(
    id: json['id'] as int,
    datetime: DateTime.parse(json['date'] as String),
    duration: Duration(minutes: json['duration_minutes'] as int),
  );

  final int id;
  final DateTime datetime;
  final Duration duration;

  @override
  List<Object?> get props => [id, datetime, duration];

  AvailableSlot copyWith({ValueGetter<int>? id, ValueGetter<DateTime>? datetime, ValueGetter<Duration>? duration}) =>
      AvailableSlot(
        id: id != null ? id() : this.id,
        datetime: datetime != null ? datetime() : this.datetime,
        duration: duration != null ? duration() : this.duration,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': datetime.toUtc().toIso8601String(),
    'duration': duration.inMinutes,
  };
}
