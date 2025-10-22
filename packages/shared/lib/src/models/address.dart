import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Address extends Equatable {
  const Address({
    required this.placeId,
    required this.city,
    required this.address,
    required this.fullName,
    required this.latitude,
    required this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    placeId: json['place_id'] as String,
    city: json['city'] as String,
    address: json['address'] as String,
    fullName: json['fullname'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );

  final String placeId, city, address, fullName;
  final double latitude, longitude;

  String get cityAndAddress => 'г. $city, $address';

  String get searchQuery => '$city, $address';

  @override
  List<Object?> get props => [placeId, city, address, fullName, latitude, longitude];

  Address copyWith({
    ValueGetter<String>? placeId,
    ValueGetter<String>? city,
    ValueGetter<String>? address,
    ValueGetter<String>? fullName,
    ValueGetter<double>? latitude,
    ValueGetter<double>? longitude,
  }) => Address(
    placeId: placeId != null ? placeId() : this.placeId,
    city: city != null ? city() : this.city,
    address: address != null ? address() : this.address,
    fullName: fullName != null ? fullName() : this.fullName,
    latitude: latitude != null ? latitude() : this.latitude,
    longitude: longitude != null ? longitude() : this.longitude,
  );

  Map<String, dynamic> toJson() => {
    'place_id': placeId,
    'city': city,
    'address': address,
    'fullname': fullName,
    'latitude': latitude,
    'longitude': longitude,
  };
}
