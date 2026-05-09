import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationSnapshot {
  const LocationSnapshot({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  String get mapsLink => 'https://maps.google.com/?q=$latitude,$longitude';
}

class LocationDatasource {
  const LocationDatasource();

  Future<LocationSnapshot?> getCurrentOrLastKnown() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LocationSnapshot(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      // Best-effort fallback to last known position when fresh GPS fails.
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown == null) {
        return null;
      }
      return LocationSnapshot(
        latitude: lastKnown.latitude,
        longitude: lastKnown.longitude,
      );
    }
  }
}

final locationDatasourceProvider = Provider<LocationDatasource>(
  (ref) => const LocationDatasource(),
);
