import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class MasterMarker extends Equatable {
  const MasterMarker({required this.id, required this.latitude, required this.longitude, required this.rating});

  factory MasterMarker.fromJson(Map<String, dynamic> json) => MasterMarker(
    id: json['id'] as int,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    rating: (json['rating'] as num).toDouble(),
  );

  final int id;
  final double latitude, longitude, rating;

  @override
  List<Object?> get props => [id, latitude, longitude, rating];

  MasterMarker copyWith({
    ValueGetter<int>? id,
    ValueGetter<double>? latitude,
    ValueGetter<double>? longitude,
    ValueGetter<double>? rating,
  }) => MasterMarker(
    id: id != null ? id() : this.id,
    latitude: latitude != null ? latitude() : this.latitude,
    longitude: longitude != null ? longitude() : this.longitude,
    rating: rating != null ? rating() : this.rating,
  );

  Map<String, dynamic> toJson() => {'id': id, 'latitude': latitude, 'longitude': longitude, 'rating': rating};
}
