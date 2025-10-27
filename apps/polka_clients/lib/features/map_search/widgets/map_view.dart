import 'package:flutter/material.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/map_search/controller/map_markers_paginator.dart';
import 'package:polka_clients/features/map_search/controller/map_search_cubit.dart';
import 'package:polka_clients/features/map_search/data/determine_position.dart';
import 'package:polka_clients/features/map_search/widgets/master_map_card.dart';
import 'package:shared/shared.dart';
import 'package:yandex_maps_mapkit_lite/mapkit_factory.dart';
import 'package:yandex_maps_mapkit_lite/ui_view.dart';
import 'package:yandex_maps_mapkit_lite/yandex_map.dart';
import 'package:yandex_maps_mapkit_lite/mapkit.dart' as maps;

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  maps.MapWindow? _mapWindow;
  late maps.MapObjectCollection _markers;
  late final _markersPaginator = blocs.get<MapMarkersPaginator>(context);

  @override
  void initState() {
    super.initState();
    _markersPaginator.setOnPlacemarksAddedListener(_addMarkers);
    _markersPaginator.setOnPlacemarksClearedListener(_clearMarkers);
    logger.info('[mapkit] calling mapkit.onStart()');
    mapkit.onStart();
  }

  @override
  void dispose() {
    mapkit.onStop();
    _markersPaginator.clearListeners();
    logger.info('[mapkit] calling mapkit.onStop()');
    super.dispose();
  }

  void _maybeAskLocationPermissions() async {
    final position = await determinePosition(context);
    if (position != null) _updateLocation(position.latitude, position.longitude);
  }

  void _updateLocation(double latitude, double longitude) {
    blocs.get<MapFeedCubit>(context).setLocation((latitude, longitude));
    _markersPaginator.setLocation((latitude, longitude));
    _moveCamera(latitude, longitude);
  }

  void _moveCamera(double latitude, double longitude) {
    // _mapWindow?.map.moveWithAnimation(
    //   maps.CameraPosition(maps.Point(latitude: latitude, longitude: longitude), azimuth: 0, tilt: 0, zoom: 16),
    //   maps.Animation(maps.AnimationType.Smooth, duration: 1),
    // );
    _mapWindow?.map.move(
      maps.CameraPosition(maps.Point(latitude: latitude, longitude: longitude), azimuth: 0, tilt: 0, zoom: 16),
    );
  }

  void _onMapCreated(maps.MapWindow window) {
    _mapWindow = window;
    _markers = window.map.mapObjects.addCollection();

    // TODO: Set the client's city coordinates
    _moveCamera(56.838011, 60.597474);

    _maybeAskLocationPermissions();
    _markersPaginator.loadPlacemarks();
  }

  void _clearMarkers() {
    _markers.clear();
    _listeners.clear();
  }

  void _addMarkers(List<MasterMarker> markers) {
    // MapView has its own widget tree so we read them theme value and do not subscribe to its changes
    final theme = context.ext.theme;
    Widget mark(MasterMarker marker) => Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: theme.backgroundDefault,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: theme.textPrimary, width: 2),
      ),
      child: Center(
        child: AppText(
          '⭐${marker.rating.toStringAsFixed(1)}',
          // Passing color explicitly is imporant because map's context is different and does not have [AppThemeWidget] above
          style: AppTextStyles.bodySmall.copyWith(color: theme.textPrimary),
        ),
      ),
    );

    for (var data in markers) {
      final listener = MasterMarkerTapListener(marker: data);
      _listeners.add(listener);

      _markers.addPlacemark()
        ..geometry = maps.Point(latitude: data.latitude, longitude: data.longitude)
        ..setView(ViewProvider(builder: () => mark(data), id: data.id.toString()))
        ..addTapListener(listener);
    }
  }

  final List<maps.MapObjectTapListener> _listeners = [];

  @override
  Widget build(BuildContext context) {
    return YandexMap(onMapCreated: _onMapCreated);
  }
}

class MasterMarkerTapListener implements maps.MapObjectTapListener {
  MasterMarkerTapListener({required this.marker});
  final MasterMarker marker;

  @override
  bool onMapObjectTap(maps.MapObject mapObject, maps.Point point) {
    logger.debug('onMapObjectTap: $marker');
    final context = navigatorKey.currentContext;
    if (context != null) _showCustomModal(context, marker.id);
    return true;
  }
}

void _showCustomModal(BuildContext context, int masterId) async {
  final result = await Dependencies().mapRepo.getMasterMapInfo(
    masterId,
    location: blocs.get<MapFeedCubit>(context).location,
  );
  result.when(
    ok: (data) {
      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MbsBase(expandContent: false, child: MasterMapCard(info: data)),
        );
      }
    },
    err: (error, st) => handleError,
  );
}
