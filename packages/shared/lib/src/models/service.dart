import 'package:flutter/foundation.dart';
import 'package:shared/src/dev/json_equatable.dart';
import 'package:shared/src/models/service_categories.dart';
import 'package:shared/src/models/service_location.dart';

class Service extends JsonEquatable {
  const Service({
    required this.id,
    // required this.latitude,
    // required this.longitude,
    required this.category,
    required this.title,
    required this.duration,
    required this.description,
    required this.location,
    required this.resultPhotos,
    required this.price,
    super.json,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
    id: json['id'] as int,
    category: ServiceCategories.fromJson(json['category']),
    title: json['title'] as String,
    duration: Duration(minutes: json['duration_min'] as int),
    description: json['activity'] as String? ?? 'activity',
    location: ServiceLocation.fromJson(json['location']),
    resultPhotos: (json['result_photos'] as List).cast<String>(),
    price: (json['price'] as num).toInt(),
    json: json,
  );

  final int id, price;
  final String title, description;
  final ServiceCategories category;
  final Duration duration;
  final ServiceLocation location;
  final List<String> resultPhotos;

  @override
  List<Object?> get props => [id, category, title, duration, description, location, resultPhotos, price];

  Service copyWith({
    ValueGetter<ServiceCategories>? category,
    ValueGetter<String>? title,
    ValueGetter<Duration>? duration,
    ValueGetter<String>? description,
    ValueGetter<ServiceLocation>? location,
    ValueGetter<List<String>>? resultPhotos,
    ValueGetter<int>? price,
  }) => Service(
    id: id,
    category: category != null ? category() : this.category,
    title: title != null ? title() : this.title,
    duration: duration != null ? duration() : this.duration,
    description: description != null ? description() : this.description,
    location: location != null ? location() : this.location,
    resultPhotos: resultPhotos != null ? resultPhotos() : this.resultPhotos,
    price: price != null ? price() : this.price,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'category': category.toJson(),
    'title': title,
    'duration_min': duration.inMinutes,
    'activity': description,
    'location': location.toJson(),
    'result_photos': resultPhotos,
    'price': price,
  };
}
