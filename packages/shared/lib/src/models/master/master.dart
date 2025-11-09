import 'package:flutter/material.dart';
import 'package:shared/src/dev/json_equatable.dart';
import 'package:shared/src/models/service/service_categories.dart';
import 'package:shared/src/models/service/service_location.dart';
import 'package:shared/src/models/user.dart';

class Master extends JsonEquatable implements User {
  const Master({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profession,
    required this.city,
    required this.experience,
    required this.about,
    required this.address,
    required this.avatarUrl,
    required this.portfolio,
    required this.workplace,
    required this.categories,
    required this.rating,
    required this.reviewsCount,
    required this.latitude,
    required this.longitude,
    required this.location,
    super.json,
  });

  factory Master.fromJson(Map<String, dynamic> json) => Master(
    id: (json['user_id'] ?? json['master_id'] ?? json['id']) as int,
    firstName: (json['first_name'] ?? json['name']) as String,
    lastName: json['last_name'] as String,
    profession: json['activity'] as String,
    city: json['city'] as String,
    experience: json['experience'] as String,
    about: json['about'] as String,
    address: json['address'] as String,
    avatarUrl: (json['avatar_photo']) as String,
    portfolio: (json['general_portfolio'] as List?)?.cast<String>() ?? [],
    workplace: (json['workplace_photos'] as List?)?.cast<String>() ?? [],
    categories: (json['categories'] as List).map((e) => ServiceCategories.fromJson(e)).toList(),
    rating: (json['rating'] as num).toDouble(),
    reviewsCount: json['reviews_count'] as int? ?? 0,
    latitude: (json['latitude'] as num? ?? 0).toDouble(),
    longitude: (json['longitude'] as num? ?? 0).toDouble(),
    location: ServiceLocation.fromJson(json['location'] ?? ''),
    json: json,
  );

  final int id, reviewsCount;
  final String firstName, lastName, profession, city, experience, about, address, avatarUrl;
  final List<String> portfolio, workplace;
  final List<ServiceCategories> categories;
  final double rating, latitude, longitude;
  final ServiceLocation location;

  @override
  String get identifier => 'master-$id';

  String get fullName => '$firstName $lastName';

  String get ratingFixed => rating.toStringAsFixed(1);

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    profession,
    city,
    experience,
    about,
    address,
    avatarUrl,
    portfolio,
    workplace,
    categories,
    rating,
    reviewsCount,
    latitude,
    longitude,
    location,
  ];

  Master copyWith({
    ValueGetter<String>? firstName,
    ValueGetter<String>? lastName,
    ValueGetter<String>? profession,
    ValueGetter<String>? city,
    ValueGetter<String>? experience,
    ValueGetter<String>? about,
    ValueGetter<String>? address,
    ValueGetter<String>? avatarUrl,
    ValueGetter<List<String>>? portfolio,
    ValueGetter<List<String>>? workplace,
    ValueGetter<List<ServiceCategories>>? categories,
    ValueGetter<double>? rating,
    ValueGetter<int>? reviewsCount,
    ValueGetter<double>? latitude,
    ValueGetter<double>? longitude,
    ValueGetter<ServiceLocation>? location,
  }) => Master(
    id: id,
    firstName: firstName != null ? firstName() : this.firstName,
    lastName: lastName != null ? lastName() : this.lastName,
    profession: profession != null ? profession() : this.profession,
    city: city != null ? city() : this.city,
    experience: experience != null ? experience() : this.experience,
    about: about != null ? about() : this.about,
    address: address != null ? address() : this.address,
    avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
    portfolio: portfolio != null ? portfolio() : this.portfolio,
    workplace: workplace != null ? workplace() : this.workplace,
    categories: categories != null ? categories() : this.categories,
    rating: rating != null ? rating() : this.rating,
    reviewsCount: reviewsCount != null ? reviewsCount() : this.reviewsCount,
    latitude: latitude != null ? latitude() : this.latitude,
    longitude: longitude != null ? longitude() : this.longitude,
    location: location != null ? location() : this.location,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'activity': profession,
    'city': city,
    'experience': experience,
    'about': about,
    'address': address,
    'avatar_photo': avatarUrl,
    'general_portfolio': portfolio,
    'workplace_photos': workplace,
    'categories': categories.map((e) => e.toJson()).toList(),
    'rating': rating,
    'reviews_count': reviewsCount,
    'latitude': latitude,
    'longitude': longitude,
    'location': location.toJson(),
  };
}
