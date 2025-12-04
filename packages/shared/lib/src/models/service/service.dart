import 'package:flutter/foundation.dart';
import 'package:shared/src/dev/json_equatable.dart';
import 'package:shared/src/models/service/service_categories.dart';

class Service extends JsonEquatable {
  const Service({
    required this.id,
    required this.category,
    required this.title,
    required this.duration,
    required this.resultPhotos,
    required this.price,
    required this.cost,
    super.json,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      cost: json['cost'] as int?,
      category: ServiceCategories.fromJson(json['category']),
      title: json['title'] as String,
      duration: Duration(minutes: json['duration_min'] as int),
      resultPhotos: (json['result_photos'] as List?)?.cast<String>() ?? [?json['service_image_url'] as String?],
      price: (json['price'] as num).toInt(),
      json: json,
    );
  }

  final int id, price;
  final int? cost; // Себестоимость
  final String title;
  final ServiceCategories category;
  final Duration duration;
  final List<String> resultPhotos;

  @override
  List<Object?> get props => [id, cost, category, title, duration, resultPhotos, price];

  Service copyWith({
    ValueGetter<ServiceCategories>? category,
    ValueGetter<String>? title,
    ValueGetter<Duration>? duration,
    ValueGetter<List<String>>? resultPhotos,
    ValueGetter<int>? price,
    ValueGetter<int?>? cost,
  }) => Service(
    id: id,
    category: category != null ? category() : this.category,
    title: title != null ? title() : this.title,
    duration: duration != null ? duration() : this.duration,
    resultPhotos: resultPhotos != null ? resultPhotos() : this.resultPhotos,
    price: price != null ? price() : this.price,
    cost: cost != null ? cost() : this.cost,
    json: json,
  );

  @override
  Map<String, dynamic> toJson() => {
    'category': category.toJson(),
    'title': title,
    'duration_min': duration.inMinutes,
    'result_photos': resultPhotos,
    'price': price,
    'cost': cost,
  };
}
