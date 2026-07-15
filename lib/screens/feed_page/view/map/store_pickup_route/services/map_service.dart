import 'dart:math' show sin, cos, atan2, sqrt, pi;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../../../model/available_orders.dart';

class MapService {
  static const double _earthRadius = 6371; // Earth's radius in kilometers

  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(LatLng point1, LatLng point2) {
    final lat1 = point1.latitude * pi / 180;
    final lat2 = point2.latitude * pi / 180;
    final deltaLat = (point2.latitude - point1.latitude) * pi / 180;
    final deltaLng = (point2.longitude - point1.longitude) * pi / 180;

    final a =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = _earthRadius * c;

    return distance;
  }

  /// Generate pickup route from current location to stores
  static List<LatLng> generatePickupRoute(
    LocationData? currentLocation,
    List<RouteDetails>? routeDetails,
  ) {
    if (currentLocation == null) {
      return [];
    }

    final List<LatLng> routePoints = [];

    try {
      final currentLatLng = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );
      routePoints.add(currentLatLng);
    } catch (e) {
      return [];
    }

    // Add store locations from route_details (excluding the last index which is shipment address)
    if (routeDetails != null) {
      // Exclude the last index (shipment address) - only include stores
      for (int i = 0; i < routeDetails.length - 1; i++) {
        final store = routeDetails[i];

        // Skip if it's "Customer Location" or doesn't have a store ID (not a real store)
        if (store.storeName != null &&
            store.storeName!.toLowerCase() != 'customer location' &&
            store.storeId != null &&
            store.latitude != null &&
            store.longitude != null) {
          final storePoint = LatLng(store.latitude!, store.longitude!);
          routePoints.add(storePoint);
        } else {
          //
        }
      }
    }

    final validPoints =
        routePoints
            .where((p) => !p.latitude.isNaN && !p.longitude.isNaN)
            .toList();

    return validPoints;
  }

  /// Generate curved path between points
  static List<LatLng> generateCurvedPath(
    List<LatLng> routePoints, {
    double curveIntensity = 0.12,
  }) {
    if (routePoints.length < 2) return routePoints;

    final List<LatLng> curvedPoints = [];

    for (int i = 0; i < routePoints.length - 1; i++) {
      final start = routePoints[i];
      final end = routePoints[i + 1];

      // Add start point
      curvedPoints.add(start);

      // Calculate midpoint
      final midLat = (start.latitude + end.latitude) / 2;
      final midLng = (start.longitude + end.longitude) / 2;

      // Calculate perpendicular offset for curve
      final latDiff = end.latitude - start.latitude;
      final lngDiff = end.longitude - start.longitude;

      // Perpendicular vector (swap and negate)
      final perpLat = -lngDiff;
      final perpLng = latDiff;

      // Normalize perpendicular vector
      final perpMagnitude = sqrt(perpLat * perpLat + perpLng * perpLng);
      if (perpMagnitude > 0) {
        final normalizedPerpLat = perpLat / perpMagnitude;
        final normalizedPerpLng = perpLng / perpMagnitude;

        // Apply curve with intensity
        final curveLat = midLat + normalizedPerpLat * curveIntensity;
        final curveLng = midLng + normalizedPerpLng * curveIntensity;

        // Add curved midpoint
        curvedPoints.add(LatLng(curveLat, curveLng));
      }

      // Add end point (will be start of next segment)
      if (i == routePoints.length - 2) {
        curvedPoints.add(end);
      }
    }

    return curvedPoints;
  }

  /// Generate dashed route polylines
  static List<Polyline> generateDashedRoute(List<LatLng> routePoints) {
    final List<Polyline> dashedPolylines = [];

    if (routePoints.length < 2) {
      if (routePoints.isNotEmpty) {
        return [
          Polyline(
            points: routePoints,
            strokeWidth: 1.5, // Very thin lines for elegant appearance
            color: const Color(0xFF059669),
          ),
        ];
      }
      return [];
    }

    // Use straight lines directly (no curves)

    // Create proper dashed lines by breaking the route into segments
    for (int i = 0; i < routePoints.length - 1; i++) {
      final start = routePoints[i];
      final end = routePoints[i + 1];

      // Create multiple small dashes for each segment
      const int numDashes = 8;
      for (int dash = 0; dash < numDashes; dash++) {
        final dashStartFraction = dash / numDashes.toDouble();
        final dashEndFraction =
            (dash + 0.6) / numDashes.toDouble(); // 60% dash, 40% gap

        if (dashEndFraction <= 1.0) {
          final dashStart = _interpolatePoint(start, end, dashStartFraction);
          final dashEnd = _interpolatePoint(start, end, dashEndFraction);

          dashedPolylines.add(
            Polyline(
              points: [dashStart, dashEnd],
              strokeWidth: 3, // Very thin lines for elegant appearance
              color: const Color(0xFF059669),
              strokeCap: StrokeCap.round,
            ),
          );
        }
      }
    }
    return dashedPolylines;
  }

  /// Helper method to interpolate between two points
  static LatLng _interpolatePoint(LatLng start, LatLng end, double fraction) {
    final lat = start.latitude + (end.latitude - start.latitude) * fraction;
    final lng = start.longitude + (end.longitude - start.longitude) * fraction;
    return LatLng(lat, lng);
  }

  /// Build all markers for the map
  static List<Marker> buildAllMarkers(
    LocationData? currentLocation,
    List<RouteDetails>? routeDetails,
  ) {
    final List<Marker> markers = [];

    // Current location marker (blue circle)
    if (currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          width: 20,
          height: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 12),
          ),
        ),
      );
    }

    // Store markers (orange circles with store icon and index)
    if (routeDetails != null) {
      for (int i = 0; i < routeDetails.length - 1; i++) {
        final store = routeDetails[i];

        // Skip if it's "Customer Location" or doesn't have coordinates
        if (store.storeName != null &&
            store.storeName!.toLowerCase() != 'customer location' &&
            store.storeId != null &&
            store.latitude != null &&
            store.longitude != null) {
          markers.add(
            Marker(
              point: LatLng(store.latitude!, store.longitude!),
              width: 40,
              height: 40,
              child: Stack(
                children: [
                  // Store icon circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  // Store number inside circle
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }

    // Shipping address marker (red circle)
    if (routeDetails != null && routeDetails.isNotEmpty) {
      final lastIndex = routeDetails.length - 1;
      final shippingAddress = routeDetails[lastIndex];

      if (shippingAddress.latitude != null &&
          shippingAddress.longitude != null) {
        markers.add(
          Marker(
            point: LatLng(
              shippingAddress.latitude!,
              shippingAddress.longitude!,
            ),
            width: 25,
            height: 25,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  /// Calculate total route distance (current location → store 1 → store 2 → delivery address)
  static double calculateDistanceToStores(
    LocationData? currentLocation,
    List<RouteDetails>? routeDetails,
  ) {
    if (currentLocation == null || routeDetails == null) {
      return 0.0;
    }

    if (routeDetails.isEmpty) {
      return 0.0;
    }

    double totalDistance = 0.0;
    LatLng? previousPoint = LatLng(
      currentLocation.latitude!,
      currentLocation.longitude!,
    );

    // Calculate distance following the actual route path
    for (int i = 0; i < routeDetails.length; i++) {
      final routePoint = routeDetails[i];

      // Skip if it's "Customer Location" or doesn't have coordinates
      if (routePoint.storeName != null &&
          routePoint.storeName!.toLowerCase() != 'customer location' &&
          routePoint.latitude != null &&
          routePoint.longitude != null) {
        final currentPoint = LatLng(
          routePoint.latitude!,
          routePoint.longitude!,
        );

        // Calculate distance from previous point to current point
        final segmentDistance = calculateDistance(previousPoint!, currentPoint);
        totalDistance += segmentDistance;

        // Update previous point for next iteration
        previousPoint = currentPoint;
      } else {
        //
      }
    }

    // Add distance to delivery address (last item in route details)
    if (routeDetails.isNotEmpty) {
      final deliveryAddress = routeDetails.last;

      if (deliveryAddress.latitude != null &&
          deliveryAddress.longitude != null) {
        final deliveryLatLng = LatLng(
          deliveryAddress.latitude!,
          deliveryAddress.longitude!,
        );
        final deliveryDistance = calculateDistance(
          previousPoint!,
          deliveryLatLng,
        );
        totalDistance += deliveryDistance;
      } else {}
    }

    return totalDistance;
  }

  /// Get filtered stores (excluding Customer Location)
  static List<RouteDetails> getFilteredStores(
    List<RouteDetails>? routeDetails,
  ) {
    if (routeDetails == null) return [];

    return routeDetails
        .where(
          (store) =>
              store.storeName?.toLowerCase() != 'customer location' &&
              store.storeId != null,
        )
        .toList();
  }
}
