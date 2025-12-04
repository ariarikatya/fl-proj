import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polka_clients/client_scope.dart';
import 'package:polka_clients/features/map_search/data/map_repo.dart';
import 'package:polka_clients/features/search/filters/search_filter.dart';
import 'package:shared/shared.dart';

class MapMarkersPaginator extends Cubit<int> {
  MapMarkersPaginator({required this.context, required this.repo, this.limit = 50}) : super(1);

  void setOnPlacemarksAddedListener(void Function(List<MasterMarker> placemarks) listener) {
    onPlacemarksAdded = listener;
  }

  void setOnPlacemarksClearedListener(void Function() listener) {
    onPlacemarksCleared = listener;
  }

  void clearListeners() {
    onPlacemarksAdded = null;
    onPlacemarksCleared = null;
  }

  void Function(List<MasterMarker> placemarks)? onPlacemarksAdded;
  void Function()? onPlacemarksCleared;
  final MapRepository repo;
  final int limit;
  final BuildContext context;

  int _page = 1;
  SearchFilter filter = const SearchFilter();
  String? query;
  (double latitude, double longitude)? location;

  int get page => _page;

  void setFilter(SearchFilter newFilter) => {filter = newFilter, reset()};

  void setQuery(String? newQuery) => query = newQuery;

  void setLocation((double latitude, double longitude)? newLocation) => {location = newLocation, reset()};

  Future<void> loadPlacemarks() async {
    final city = context.read<ClientViewModel>().client.city;
    final result = await repo.searchMasterMarkers(query, filter, city, location: location, page: _page, limit: limit);

    result.maybeWhen(
      ok: (placemarks) {
        if (placemarks.isNotEmpty) {
          onPlacemarksAdded?.call(placemarks);
          _page++;
        }
      },
    );
  }

  Future<void> reset() async {
    onPlacemarksCleared?.call();
    _page = 1;
    await loadPlacemarks();
  }
}
