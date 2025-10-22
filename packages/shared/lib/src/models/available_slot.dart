import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class AvailableSlot extends Equatable {
  const AvailableSlot({required this.id, required this.date, required this.startTime});

  factory AvailableSlot.fromJson(Map<String, dynamic> json) => AvailableSlot(
    id: json['id'] as int,
    date: DateTimeX.fromDateString(json['date'] as String),
    startTime: DurationX.fromTimeString(json['time_from'] as String),
  );

  final int id;
  final DateTime date;
  final Duration startTime;

  DateTime get datetime => date.add(startTime);

  @override
  List<Object?> get props => [id, date, startTime];

  AvailableSlot copyWith({
    ValueGetter<int>? id,
    ValueGetter<DateTime>? date,
    ValueGetter<Duration>? startTime,
  }) => AvailableSlot(
    id: id != null ? id() : this.id,
    date: date != null ? date() : this.date,
    startTime: startTime != null ? startTime() : this.startTime,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toJson(),
    'startTime': startTime.toTimeString(),
  };
}
