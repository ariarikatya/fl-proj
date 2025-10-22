import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared/shared.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position?> determinePosition(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    logger.warning('Location services are disabled.');
    return null;
  }

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied && context.mounted) {
    var promptRequest = false;
    await showInfoBottomSheet(
      context: context,
      title: 'Разрешить доступ к геолокации?',
      description: 'Так мы сможем точнее подобрать мастеров рядом с тобой',
      optionLabel: 'Разрешить доступ к гео',
      optionCallback: () => promptRequest = true,
    );

    if (!promptRequest) {
      logger.info('geolocation request dialog denied by user');
      return null;
    }

    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      logger.warning('Location permissions are denied');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    logger.warning('Location permissions are permanently denied, opening location settings of the app');
    await Geolocator.openLocationSettings();
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
