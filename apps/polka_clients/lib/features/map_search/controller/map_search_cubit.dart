import 'package:flutter/material.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/features/map_search/data/map_repo.dart';
import 'package:polka_clients/features/search/filters/search_filter.dart';
import 'package:shared/shared.dart';

class MapFeedCubit extends PaginationCubit<MasterMapInfo> {
  MapFeedCubit({required this.context, required this.repo}) : super(limit: 10);

  final MapRepository repo;
  final BuildContext context;
  final filter = ValueNotifier(SearchFilter());

  @override
  Future<void> close() {
    filter.dispose();
    return super.close();
  }

  String? query;
  (double latitude, double longitude)? location;

  void setQuery(String? newQuery) => query = newQuery;
  void setFilter(SearchFilter newFilter) => {filter.value = newFilter, reset()};
  void setLocation((double latitude, double longitude)? newLocation) => {location = newLocation, reset()};

  @override
  Future<Result<List<MasterMapInfo>>> loadItems(int page, int limit) {
    final city = ClientScope.of(context, listen: false).client.city;
    return repo.searchMastersMapFeed(query, filter.value, city, location: location, page: page, limit: limit);
  }
}
