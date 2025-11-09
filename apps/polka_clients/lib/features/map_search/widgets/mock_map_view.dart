import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:polka_clients/dependencies.dart';
import 'package:polka_clients/features/map_search/controller/map_markers_paginator.dart';
import 'package:polka_clients/features/map_search/controller/map_search_cubit.dart';
import 'package:polka_clients/features/map_search/widgets/master_map_card.dart';
import 'package:shared/shared.dart';

typedef MarkerBuilder = Widget Function(BuildContext context, MasterMarker marker);

class MockMapView extends StatefulWidget {
  const MockMapView({super.key});

  @override
  State<MockMapView> createState() => _MockMapViewState();
}

class _MockMapViewState extends State<MockMapView> {
  late final _markersPaginator = blocs.get<MapMarkersPaginator>(context);
  final List<MasterMarker> _markers = [];
  final TransformationController _controller = TransformationController();
  static const double _minScale = 0.5;
  static const double _maxScale = 4.0;
  static const Size _mapSize = Size(1000, 1000);

  @override
  void initState() {
    super.initState();
    _markersPaginator.setOnPlacemarksAddedListener(_addMarkers);
    _markersPaginator.setOnPlacemarksClearedListener(_clearMarkers);
    _markersPaginator.loadPlacemarks();
  }

  @override
  void dispose() {
    _markersPaginator.clearListeners();
    _controller.dispose();
    super.dispose();
  }

  void _addMarkers(List<MasterMarker> markers) => setState(() => _markers.addAll(markers));
  void _clearMarkers() => setState(() => _markers.clear());

  /// Converts geographical coordinates to view coordinates
  Offset _latLongToPoint(double latitude, double longitude) {
    final random = Random();
    final x = random.nextDouble() * (_mapSize.width - 40) + 20;
    final y = random.nextDouble() * (_mapSize.height - 40) + 20;

    // Scale to view size
    return Offset(x, y);
  }

  Widget markerBuilder(MasterMarker marker) => GestureDetector(
    onTap: () => _showCustomModal(context, marker.id),
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: context.ext.theme.backgroundDefault,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: context.ext.theme.textPrimary, width: 2),
      ),
      child: Center(
        child: AppText(
          '⭐${marker.rating.toStringAsFixed(1)}',
          style: AppTextStyles.bodySmall.copyWith(color: context.ext.theme.textPrimary),
        ),
      ),
    ),
  );

  List<Widget> _buildMarkers() {
    return _markers.map((marker) {
      final position = _latLongToPoint(marker.latitude, marker.longitude);
      return Positioned(
        left: position.dx - 20, // Half of marker width
        top: position.dy - 20, // Half of marker height
        child: markerBuilder(marker),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      alignment: Alignment.center,
      child: ClipRect(
        child: InteractiveViewer(
          transformationController: _controller,
          scaleFactor: 1000,
          minScale: _minScale,
          maxScale: _maxScale,
          constrained: true,
          boundaryMargin: const EdgeInsets.all(500),
          child: Container(
            width: _mapSize.width,
            height: _mapSize.height,
            color: Colors.white,
            child: Stack(
              children: [
                CustomPaint(painter: GridPainter(), size: _mapSize),
                ..._buildMarkers(),
              ],
            ),
          ),
        ),
      ),
    );
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
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw vertical lines
    for (var i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw horizontal lines
    for (var i = 0; i <= 10; i++) {
      final y = size.height * i / 10;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}
