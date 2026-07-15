import 'dart:async';
import 'package:location/location.dart';
import '../screens/feed_page/repo/update_current_location.dart';

class PeriodicLocationService {
  static final PeriodicLocationService _instance =
      PeriodicLocationService._internal();
  factory PeriodicLocationService() => _instance;
  PeriodicLocationService._internal();

  final Location _location = Location();
  final UpdateCurrentLocationRepo _locationRepo = UpdateCurrentLocationRepo();

  Timer? _periodicTimer;
  bool _isRunning = false;

  static const int _updateInterval = 60000;

  Future<bool> startPeriodicUpdates() async {
    if (_isRunning) return true;

    try {
      bool serviceEnabled = await _location.serviceEnabled().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return false;
        },
      );

      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            return false;
          },
        );
        if (!serviceEnabled) {
          return false;
        }
      }

      PermissionStatus permissionGranted;
      try {
        permissionGranted = await Future.microtask(() async {
          return await _location.hasPermission().timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              return PermissionStatus.denied;
            },
          );
        });
      } catch (e) {
        return false;
      }

      if (permissionGranted == PermissionStatus.denied) {
        try {
          permissionGranted = await Future.microtask(() async {
            return await _location.requestPermission().timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                return PermissionStatus.denied;
              },
            );
          });
          if (permissionGranted != PermissionStatus.granted) {
            return false;
          }
        } catch (e) {
          return false;
        }
      }

      try {
        await _updateLocationPeriodically().timeout(
          const Duration(seconds: 10),
        );
      } catch (e) {
        //
      }

      _periodicTimer = Timer.periodic(
        Duration(milliseconds: _updateInterval),
        (_) => _updateLocationPeriodically(),
      );

      _isRunning = true;

      return true;
    } catch (e) {
      return false;
    }
  }

  void stopPeriodicUpdates() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _isRunning = false;
  }

  Future<void> _updateLocationPeriodically() async {
    try {
      // Basic check
      final isServiceEnabled = await _location.serviceEnabled();
      if (!isServiceEnabled) return;

      final locationData = await _location.getLocation().timeout(
        const Duration(seconds: 10),
      );

      if (locationData.latitude != null && locationData.longitude != null) {
        await _updateLocationOnServer(locationData);
      }
    } catch (e) {
      // Silently fail for periodic updates to avoid spamming the user
      print('⚠️ Periodic Location update failed: $e');
    }
  }

  Future<void> _updateLocationOnServer(LocationData locationData) async {
    try {
      final response = await _locationRepo.updateCurrentLocation(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
      );

      if (response['success'] == true) {
      } else {}
    } catch (e) {
      //
    }
  }

  bool get isRunning => _isRunning;

  Future<LocationData?> getCurrentLocation() async {
    try {
      return await _location.getLocation();
    } catch (e) {
      return null;
    }
  }

  Future<void> manualUpdate() async {
    await _updateLocationPeriodically();
  }

  Future<void> forceUpdate() async {
    await _updateLocationPeriodically();
  }

  Map<String, dynamic> getStatus() {
    return {
      'isRunning': _isRunning,
      'interval': _updateInterval,
      'intervalSeconds': _updateInterval ~/ 1000,
    };
  }
}
