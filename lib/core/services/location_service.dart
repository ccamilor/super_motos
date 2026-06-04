import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> isPermissionGranted() async {
    return await Permission.location.isGranted;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await isPermissionGranted();
      if (!hasPermission) {
        final granted = await requestPermission();
        if (!granted) return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('LocationService: failed to get position: $e');
      return null;
    }
  }
}
