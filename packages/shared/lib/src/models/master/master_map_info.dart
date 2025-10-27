import 'package:flutter/foundation.dart';
import 'package:shared/src/dev/json_equatable.dart';
import 'package:shared/src/models/master/master.dart';
import 'package:shared/src/models/service/service.dart';
import 'package:shared/src/utils.dart';

class MasterMapInfo extends JsonEquatable {
  const MasterMapInfo({
    required this.master,
    required this.services,
    required this.distanceMeters,
    required super.json,
  });

  factory MasterMapInfo.fromJson(Map<String, dynamic> json) => MasterMapInfo(
    master: Master.fromJson(json),
    services: parseJsonList(json['services'], Service.fromJson),
    distanceMeters: (json['distance_meters'] as num).toInt(),
    json: json,
  );

  final Master master;
  final List<Service> services;
  final int distanceMeters;

  @override
  List<Object?> get props => [master, services, distanceMeters];

  MasterMapInfo copyWith({
    ValueGetter<Master>? master,
    ValueGetter<List<Service>>? services,
    ValueGetter<int>? distanceMeters,
  }) => MasterMapInfo(
    master: master != null ? master() : this.master,
    services: services != null ? services() : this.services,
    distanceMeters: distanceMeters != null ? distanceMeters() : this.distanceMeters,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'master': master.toJson(),
    'services': services.map((e) => e.toJson()).toList(),
    'distance_meters': distanceMeters,
  };
}
