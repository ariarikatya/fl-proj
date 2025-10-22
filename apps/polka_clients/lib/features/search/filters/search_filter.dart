import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import 'package:equatable/equatable.dart';

typedef PriceRange = ({int? min, int? max});

enum SearchSort {
  priceAsc('От самой дешевой'),
  priceDesc('От самой дорогой'),
  rating('По рейтингу'),
  distance('По близости');

  final String label;
  const SearchSort(this.label);
}

class SearchFilter extends Equatable {
  const SearchFilter({this.categories = const {}, this.dateRange, this.price, this.sort, this.location});

  final Set<ServiceCategories> categories;
  final DateTimeRange? dateRange;
  final PriceRange? price;
  final SearchSort? sort;
  final ServiceLocation? location;

  int get activeFiltersCount {
    return [dateRange, sort, location, price?.max, price?.min].nonNulls.length + (categories.isNotEmpty ? 1 : 0);
  }

  bool get hasActiveFilters => activeFiltersCount > 0;

  @override
  List<Object?> get props => [categories, dateRange, price, sort, location];

  SearchFilter copyWith({
    ValueGetter<Set<ServiceCategories>>? categories,
    ValueGetter<DateTimeRange?>? dateRange,
    ValueGetter<PriceRange?>? price,
    ValueGetter<SearchSort?>? sort,
    ValueGetter<ServiceLocation?>? location,
  }) => SearchFilter(
    categories: categories != null ? categories.call() : this.categories,
    dateRange: dateRange != null ? dateRange.call() : this.dateRange,
    price: price != null ? price.call() : this.price,
    sort: sort != null ? sort.call() : this.sort,
    location: location != null ? location.call() : this.location,
  );

  Map<String, dynamic> toJson() => {
    if (categories.isNotEmpty) 'categories': categories.map((e) => e.toJson()).toList(),
    'date_from': ?dateRange?.start.toJson(),
    'date_to': ?dateRange?.end.toJson(),
    'price_min': ?price?.min,
    'price_max': ?price?.max,
    'sort': ?sort?.name,
    'location': ?location?.toJson(),
  };
}
