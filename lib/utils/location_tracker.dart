import 'dart:async';
import 'dart:math';
import 'package:location/location.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../screens/feed_page/repo/update_current_location.dart';

class LocationTracker {
  static final LocationTracker _instance = LocationTracker._internal();
  factory LocationTracker() => _instance;
  LocationTracker._internal();

  final Location _location = Location();
  final UpdateCurrentLocationRepo _locationRepo = UpdateCurrentLocationRepo();

  StreamSubscription<LocationData>? _locationSubscription;
  bool _isTracking = false;
  LocationData? _lastLocation;

  // Minimum distance (in meters) to trigger location update
  static const double _minDistance = 10.0; // 10 meters

  // Update interval (in milliseconds)
  static const int _updateInterval = 30000; // 30 seconds

  /// Start tracking location changes
  Future<bool> startTracking() async {
    if (_isTracking) return true;

    try {
      // Check and request permissions with timeout
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
        permissionGranted = await _location.hasPermission().timeout(
          const Duration(seconds: 5),
          onTimeout: () => PermissionStatus.denied,
        );
      } catch (e) {
        return false;
      }

      if (permissionGranted != PermissionStatus.granted &&
          permissionGranted != PermissionStatus.grantedLimited) {
        if (permissionGranted == PermissionStatus.denied) {
          try {
            permissionGranted = await _location.requestPermission().timeout(
              const Duration(seconds: 5),
              onTimeout: () => PermissionStatus.denied,
            );

            if (permissionGranted != PermissionStatus.granted &&
                permissionGranted != PermissionStatus.grantedLimited) {
              return false;
            }
          } catch (e) {
            return false;
          }
        } else {
          return false;
        }
      }

      // Configure location system_settings for background
      try {
        await _location
            .changeSettings(
              accuracy: LocationAccuracy.high,
              interval: _updateInterval,
              distanceFilter: _minDistance,
            )
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        //
      }

      // Get initial location with timeout
      try {
        _lastLocation = await _location.getLocation().timeout(
          const Duration(seconds: 10),
        );
      } catch (e) {
        _lastLocation = null;
      }

      // Start background service with timeout
      try {
        await _startBackgroundService().timeout(const Duration(seconds: 5));
      } catch (e) {
        //
      }

      // Start listening to location changes
      _locationSubscription = _location.onLocationChanged.listen(
        _onLocationChanged,
        onError: (error) {},
      );

      _isTracking = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Stop tracking location changes
  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isTracking = false;
    _lastLocation = null;

    // Stop background service
    _stopBackgroundService();
  }

  /// Handle location changes
  void _onLocationChanged(LocationData locationData) {
    if (_lastLocation == null) {
      _lastLocation = locationData;
      _updateLocationOnServer(locationData);
      return;
    }

    // Calculate distance between current and last location
    double distance = _calculateDistance(
      _lastLocation!.latitude!,
      _lastLocation!.longitude!,
      locationData.latitude!,
      locationData.longitude!,
    );

    // Update if distance is significant enough
    if (distance >= _minDistance) {
      _lastLocation = locationData;
      _updateLocationOnServer(locationData);
    }
  }

  /// Update location on server
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

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  /// Check if tracking is active
  bool get isTracking => _isTracking;

  /// Get current location
  LocationData? get currentLocation => _lastLocation;

  /// Test method to manually update location (for testing purposes)
  Future<void> testLocationUpdate() async {
    try {
      final locationData = await _location.getLocation();
      await _updateLocationOnServer(locationData);
    } catch (e) {
      //
    }
  }

  /// Start background service
  Future<void> _startBackgroundService() async {
    final service = FlutterBackgroundService();

    // Configure the service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode:
            false, // Changed to false to avoid notification issues
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    // Start the service
    await service.startService();
  }

  /// Stop background service
  void _stopBackgroundService() {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }
}

// Background service callback
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Ensure the engine is initialized in this isolate
  try {
    // WidgetsFlutterBinding.ensureInitialized() is sometimes needed for plugin channels
    // but in background isolates we usually use this sparingly.
    // However, giving it a tiny moment to settle helps with NPEs.
    await Future.delayed(const Duration(milliseconds: 500));
  } catch (e) {}

  // Initialize location tracking in background
  final location = Location();
  final locationRepo = UpdateCurrentLocationRepo();
  LocationData? lastLocation;

  // Configure location for background
  try {
    // Check if service is enabled before changing settings
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    if (serviceEnabled) {
      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.granted ||
          permission == PermissionStatus.grantedLimited) {
        // Enable background mode for the plugin
        try {
          await location.enableBackgroundMode(enable: true);
        } catch (e) {
          print('⚠️ Could not enable background mode: $e');
        }

        await location
            .changeSettings(
              accuracy: LocationAccuracy.high,
              interval: 30000, // 30 seconds
              distanceFilter: 10.0, // 10 meters
            )
            .timeout(const Duration(seconds: 5));
      }
    }
  } catch (e) {
    // Prevent app crash on CHANGE_SETTINGS_ERROR or NullPointerException from plugin
    print('⚠️ Background Location Setup Error: $e');
  }

  // Get initial location
  try {
    lastLocation = await location.getLocation();
    await _updateLocationInBackground(locationRepo, lastLocation);
  } catch (e) {
    //
  }

  // Listen to location changes
  location.onLocationChanged.listen((LocationData locationData) async {
    if (lastLocation == null) {
      lastLocation = locationData;
      await _updateLocationInBackground(locationRepo, locationData);
      return;
    }

    // Calculate distance
    double distance = _calculateDistanceInBackground(
      lastLocation!.latitude!,
      lastLocation!.longitude!,
      locationData.latitude!,
      locationData.longitude!,
    );

    // Update if distance is significant
    if (distance >= 10.0) {
      lastLocation = locationData;
      await _updateLocationInBackground(locationRepo, locationData);
    }
  });

  // Start periodic location updates (60 seconds interval)
  Timer.periodic(Duration(seconds: 60), (_) async {
    try {
      final locationData = await location.getLocation();
      await _updateLocationInBackground(locationRepo, locationData);
    } catch (e) {
      //
    }
  });

  // Keep service alive
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

// iOS background callback
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

// Update location in background
Future<void> _updateLocationInBackground(
  UpdateCurrentLocationRepo locationRepo,
  LocationData locationData,
) async {
  try {
    final response = await locationRepo.updateCurrentLocation(
      latitude: locationData.latitude,
      longitude: locationData.longitude,
    );

    if (response['success'] == true) {
    } else {}
  } catch (e) {
    //
  }
}

// Calculate distance in background
double _calculateDistanceInBackground(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double earthRadius = 6371000; // Earth's radius in meters

  double dLat = _degreesToRadiansInBackground(lat2 - lat1);
  double dLon = _degreesToRadiansInBackground(lon2 - lon1);

  double a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadiansInBackground(lat1)) *
          cos(_degreesToRadiansInBackground(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double _degreesToRadiansInBackground(double degrees) {
  return degrees * (3.14159265359 / 180);
}
