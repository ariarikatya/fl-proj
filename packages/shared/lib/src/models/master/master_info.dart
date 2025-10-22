import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

/// Full Master Info
class MasterInfo extends JsonEquatable {
  const MasterInfo({
    required this.master,
    required this.services,
    required this.schedule,
    required this.reviews,
    super.json,
  });

  factory MasterInfo.fromJson(Map<String, dynamic> json) => MasterInfo(
    master: Master.fromJson(json['master_profile']),
    schedule: Schedule.fromJson((json['master_schedules'] as List).first),
    services: parseJsonList(json['master_services'], Service.fromJson),
    reviews: parseJsonList(json['reviews'], Review.fromJson),
    json: json,
  );

  final Master master;
  final List<Service> services;
  final Schedule schedule;
  final List<Review> reviews;

  @override
  List<Object?> get props => [master, services, schedule, reviews];

  MasterInfo copyWith({
    ValueGetter<Master>? master,
    ValueGetter<List<Service>>? services,
    ValueGetter<Schedule>? schedule,
    ValueGetter<List<Review>>? reviews,
  }) => MasterInfo(
    master: master != null ? master() : this.master,
    services: services != null ? services() : this.services,
    schedule: schedule != null ? schedule() : this.schedule,
    reviews: reviews != null ? reviews() : this.reviews,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'master': master.toJson(),
    'services': services.map((e) => e.toJson()).toList(),
    'schedule': schedule.toJson(),
    'reviews': reviews.map((e) => e.toJson()).toList(),
  };
}
