import 'package:flutter/foundation.dart';
import 'package:shared/src/dev/json_equatable.dart';
import 'package:shared/src/models/service_categories.dart';
import 'package:shared/src/models/user.dart';

class Client extends JsonEquatable implements User {
  const Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.services,
    required this.preferredServices,
    required this.avatarUrl,
    required this.email,
    super.json,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json['id'] as int,
    firstName: json['first_name'] as String,
    lastName: json['last_name'] as String,
    city: json['city'] as String,
    preferredServices: (json['preferred_services'] as List).map((e) => ServiceCategories.fromJson(e)).toList(),
    services: (json['services'] as List).map((e) => e as String).toList(),
    avatarUrl: json['avatar_url'] as String? ?? '',
    email: json['email'] as String?,
    json: json,
  );

  final int id;
  final String firstName, lastName, city, avatarUrl;
  final List<String> services;
  final List<ServiceCategories> preferredServices;
  final String? email;

  @override
  String get identifier => 'client-$id';

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, firstName, lastName, city, services, preferredServices, avatarUrl, email];

  Client copyWith({
    ValueGetter<int>? id,
    ValueGetter<String>? firstName,
    ValueGetter<String>? avatarUrl,
    ValueGetter<String>? lastName,
    ValueGetter<String>? city,
    ValueGetter<List<ServiceCategories>>? preferredServices,
    ValueGetter<List<String>>? services,
    ValueGetter<String?>? email,
  }) => Client(
    id: id != null ? id() : this.id,
    firstName: firstName != null ? firstName() : this.firstName,
    avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
    lastName: lastName != null ? lastName() : this.lastName,
    city: city != null ? city() : this.city,
    preferredServices: preferredServices != null ? preferredServices() : this.preferredServices,
    services: services != null ? services() : this.services,
    email: email != null ? email() : this.email,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'city': city,
    'services': services,
    'preferred_services': preferredServices.map((e) => e.toJson()).toList(),
    'avatar_url': avatarUrl,
    'email': ?email,
  };
}
