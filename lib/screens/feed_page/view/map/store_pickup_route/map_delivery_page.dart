// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/widgets/custom_appbar_without_navbar.dart';
import '../../../../../utils/widgets/toast_message.dart';
import '../../../model/available_orders.dart';
import 'widgets/index.dart';

class MapDeliveryPage extends StatefulWidget {
  final Orders order;
  final String? currentLat;
  final String? currentLng;
  final List<dynamic>? groupOrders;

  const MapDeliveryPage({
    super.key,
    required this.order,
    this.currentLat,
    this.currentLng,
    this.groupOrders,
  });

  @override
  State<MapDeliveryPage> createState() => _MapDeliveryPageState();
}

class _MapDeliveryPageState extends State<MapDeliveryPage> {
  late MapController _mapController;
  LocationData? _currentLocation;
  bool _isLoadingLocation = true;
  final bool _hasReachedDestination = false;
  double _distanceToStores = 0.0;
  List<RouteDetails> _filteredStores = [];

  @override
  void initState() {
    super.initState();

    _mapController = MapController();
    _initializeData();
    _getCurrentLocation();
  }

  void _initializeData() {
    // Get filtered stores
    _filteredStores = MapService.getFilteredStores(
      widget.order.deliveryRoute?.routeDetails,
    );


    if (widget.order.deliveryRoute != null) {
      if (widget.order.deliveryRoute!.routeDetails != null) {
        for (
          int i = 0;
          i < widget.order.deliveryRoute!.routeDetails!.length;
          i++
        ) {
          //
        }
      }
    }

    // If we have route details, try to calculate distance (will be updated when location is available)
    if (widget.order.deliveryRoute?.routeDetails != null &&
        widget.order.deliveryRoute!.routeDetails!.isNotEmpty) {}
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationData = await LocationService.getCurrentLocation();

      if (locationData != null) {
        setState(() {
          _currentLocation = locationData;
          _isLoadingLocation = false;
        });

        // Calculate distance to stores
        _calculateDistanceToStores();

        // Fit map to show all points
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fitMapToAllPoints();
        });
      } else {
        _setFallbackLocation();
      }
    } catch (e) {
      _setFallbackLocation();
    }
  }

  void _setFallbackLocation() {
    if (mounted) {
      ToastManager.show(
        context: context,
        message: 'Please enable GPS and Location Permissions to track your route',
        type: ToastType.error,
      );
    }

    setState(() {
      // Use shipping address coordinates as fallback location
      double fallbackLat = 23.2488453; // Default Bhuj coordinates
      double fallbackLng = 69.6696795;

      if (widget.order.deliveryRoute?.routeDetails != null &&
          widget.order.deliveryRoute!.routeDetails!.isNotEmpty) {
        final lastIndex = widget.order.deliveryRoute!.routeDetails!.length - 1;
        final shippingAddress =
            widget.order.deliveryRoute!.routeDetails![lastIndex];

        if (shippingAddress.latitude != null &&
            shippingAddress.longitude != null) {
          fallbackLat = shippingAddress.latitude!;
          fallbackLng = shippingAddress.longitude!;
        } else {}
      }

      _currentLocation = LocationService.setFallbackLocation(
        fallbackLat,
        fallbackLng,
      );
      _isLoadingLocation = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToAllPoints();
      _calculateDistanceToStores(); // Calculate distance after setting fallback location
    });
  }

  void _calculateDistanceToStores() {
    if (_currentLocation != null) {
      _distanceToStores = MapService.calculateDistanceToStores(
        _currentLocation,
        widget.order.deliveryRoute?.routeDetails,
      );

      // Force UI update
      setState(() {});
    } else {}
  }

  void _fitMapToAllPoints() {
    if (_currentLocation == null ||
        widget.order.deliveryRoute?.routeDetails == null) {
      return;
    }

    try {
      final List<LatLng> allPoints = [];

      // Add current location
      final currentLatLng = LocationService.locationDataToLatLng(
        _currentLocation,
      );
      if (currentLatLng != null) {
        allPoints.add(currentLatLng);
      }

      // Add filtered store locations
      for (int i = 0; i < _filteredStores.length; i++) {
        final store = _filteredStores[i];
        if (store.latitude != null && store.longitude != null) {
          final storePoint = LatLng(store.latitude!, store.longitude!);
          allPoints.add(storePoint);
        }
      }

      if (allPoints.length >= 2) {
        final bounds = LatLngBounds.fromPoints(allPoints);
        if (bounds.southWest == bounds.northEast) {
          bounds.extend(LatLng(bounds.northEast.latitude + 0.001, bounds.northEast.longitude + 0.001));
          bounds.extend(LatLng(bounds.southWest.latitude - 0.001, bounds.southWest.longitude - 0.001));
        }

        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(50)),
        );
      } else {}
    } catch (e) {
      //
    }
  }

  LatLng _getDestinationLocation() {
    return LocationService.getDestinationLocation(
      widget.order.deliveryRoute?.routeDetails,
    );
  }

  List<Polyline> _generateDashedRoute() {
    if (_currentLocation == null) return [];

    final routePoints = MapService.generatePickupRoute(
      _currentLocation,
      widget.order.deliveryRoute?.routeDetails,
    );

    return MapService.generateDashedRoute(routePoints);
  }

  List<Marker> _buildAllMarkers() {
    return MapService.buildAllMarkers(
      _currentLocation,
      widget.order.deliveryRoute?.routeDetails,
    );
  }

  void _onNavigationPressed() {
    if (_currentLocation == null) {
      return;
    }

    final currentLatLng = LocationService.locationDataToLatLng(
      _currentLocation,
    );
    if (currentLatLng != null) {
      // Use filtered stores for navigation (excludes shipping address)
      final storesForNavigation = _filteredStores;

      for (int i = 0; i < storesForNavigation.length; i++) {}

      NavigationService.openGoogleMapsToStores(
        currentLatLng,
        storesForNavigation,
      );
    } else {}
  }

  void _onMapReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToAllPoints();
      _calculateDistanceToStores(); // Calculate distance when map is ready
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.pop(true);
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBarWithoutNavbar(
          title:
              _hasReachedDestination
                  ? AppLocalizations.of(context)!.deliveryRoute
                  : '${AppLocalizations.of(context)!.storePickup} ${AppLocalizations.of(context)!.pickupRoute}',
          showRefreshButton: false,
          showThemeToggle: false,
        ),
        body: Stack(
          children: [
            // Map
            MapViewWidget(
              mapController: _mapController,
              initialCenter: _getDestinationLocation(),
              polylines: _generateDashedRoute(),
              markers: _buildAllMarkers(),
              onMapReady: _onMapReady,
              showMapContent: _currentLocation != null,
            ),

            // Loading overlay
            if (_isLoadingLocation) const LoadingOverlayWidget(),

            // Distance Indicator
            Positioned(
              top: 20.h,
              left: 20.w,
              child: DistanceIndicatorWidget(distance: _distanceToStores),
            ),

            // Navigation Button
            Positioned(
              top: 20.h,
              right: 20.w,
              child: NavigationButtonWidget(onPressed: _onNavigationPressed),
            ),

            // Bottom Card
            BottomCardWidget(
              order: widget.order,
              hasReachedDestination: _hasReachedDestination,
              filteredStores: _filteredStores,
              shouldShowNumbers: _filteredStores.length > 1,
              distanceToStores: _distanceToStores, // Pass the calculated distance
              groupOrders: widget.groupOrders,
            ),
          ],
        ),
      ),
    );
  }
}
