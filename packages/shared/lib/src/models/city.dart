import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class City extends Equatable {
  const City({
    required this.name,
    required this.fullName,
    required this.description,
    required this.placeId,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
    name: json['name'],
    fullName: json['full_name'],
    description: json['description'],
    placeId: json['place_id'],
  );

  final String placeId;
  final String name;
  final String fullName;
  final String description;

  @override
  List<Object?> get props => [name, fullName, description, placeId];

  City copyWith({
    ValueGetter<String>? name,
    ValueGetter<String>? fullName,
    ValueGetter<String>? description,
    ValueGetter<String>? placeId,
  }) => City(
    name: name != null ? name.call() : this.name,
    fullName: fullName != null ? fullName.call() : this.fullName,
    description: description != null ? description.call() : this.description,
    placeId: placeId != null ? placeId.call() : this.placeId,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'full_name': fullName,
    'description': description,
    'place_id': placeId,
  };
}
