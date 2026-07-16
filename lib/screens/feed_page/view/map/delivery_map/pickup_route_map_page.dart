import 'dart:async';
import 'dart:math' show sin, cos, atan2, sqrt, pi;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:grofery_rider/l10n/app_localizations.dart';
import '../../../../../config/colors.dart';
import '../../../../../config/constant.dart';
import '../../../../../config/theme_bloc.dart';
import '../../../model/available_orders.dart';
import '../../../bloc/order_details_bloc/order_details_bloc.dart';
import '../../../bloc/order_details_bloc/order_details_event.dart';
import '../../../bloc/order_details_bloc/order_details_state.dart';
import '../../../../../utils/widgets/custom_button.dart';
import '../../../../../utils/widgets/custom_text.dart';
import '../../../../../utils/widgets/custom_appbar_without_navbar.dart';
import 'package:go_router/go_router.dart';
import '../../../../../router/app_routes.dart';
import '../../../../../utils/widgets/toast_message.dart';

class PickupRouteMapPage extends StatefulWidget {
  final Orders order;
  final OrderDetailsBloc? bloc; // Add bloc parameter
  final List<dynamic>? groupOrders;

  const PickupRouteMapPage({
    super.key,
    required this.order,
    this.bloc, // Make it optional
    this.groupOrders,
  });

  @override
  State<PickupRouteMapPage> createState() => _PickupRouteMapPageState();
}

class _PickupRouteMapPageState extends State<PickupRouteMapPage> {
  late MapController _mapController;
  LocationData? _currentLocation;
  bool _isLoadingLocation = true;
  LatLng? _customerLatLng;
  bool _isGeocodingCustomer = true;

  // Manual confirmation variables
  bool _hasReachedDestination = false;
  bool _hasConfirmedArrival = false;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();

    if (widget.bloc != null) {
      final currentState = widget.bloc!.state;
      if (currentState is OrderDetailsSuccess) {
        final hasAnyReachedDestination =
            currentState.order.items?.any(
              (item) => item.reachedDestination == true,
            ) ??
            false;
        if (hasAnyReachedDestination) {
          _hasReachedDestination = true;
        }
      }
    }

    // Also check the order data directly if bloc is not available
    if (widget.order.items != null) {
      final hasAnyReachedDestination = widget.order.items!.any(
        (item) => item.reachedDestination == true,
      );
      if (hasAnyReachedDestination) {
        _hasReachedDestination = true;
      }
    }

    Future.delayed(const Duration(seconds: 6), () {
      if (_isLoadingLocation) {
        _setFallbackLocation();
      }
    });

    _resolveCustomerLocation().then((_) {
      _getCurrentLocation();
    });
  }

  Future<void> _resolveCustomerLocation() async {
    // 1. Try routeDetails.last
    if (widget.order.deliveryRoute?.routeDetails != null &&
        widget.order.deliveryRoute!.routeDetails!.isNotEmpty) {
      final lastIndex = widget.order.deliveryRoute!.routeDetails!.length - 1;
      final customerAddress =
          widget.order.deliveryRoute!.routeDetails![lastIndex];

      if (customerAddress.latitude != null &&
          customerAddress.longitude != null) {
        if (mounted) {
          setState(() {
            _customerLatLng = LatLng(
                customerAddress.latitude!, customerAddress.longitude!);
            _isGeocodingCustomer = false;
          });
        }
        return;
      }
    }

    // 2. Try shippingLatitude
    if (widget.order.shippingLatitude != null &&
        widget.order.shippingLongitude != null) {
      double? lat = double.tryParse(widget.order.shippingLatitude!);
      double? lng = double.tryParse(widget.order.shippingLongitude!);
      if (lat != null && lng != null) {
        if (mounted) {
          setState(() {
            _customerLatLng = LatLng(lat, lng);
            _isGeocodingCustomer = false;
          });
        }
        return;
      }
    }

    // 3. Fallback to geocoding shippingAddress1
    if (widget.order.shippingAddress1 != null) {
      String address = widget.order.shippingAddress1!;
      if (widget.order.shippingAddress2 != null) {
        address += ', ${widget.order.shippingAddress2}';
      }
      if (widget.order.shippingCity != null) {
        address += ', ${widget.order.shippingCity}';
      }
      
      try {
        print('Geocoding address: $address');
        List<geocoding.Location> locations = await geocoding.locationFromAddress(address);
        print('Geocoding results: $locations');
        if (locations.isNotEmpty) {
          if (mounted) {
            setState(() {
              _customerLatLng = LatLng(locations.first.latitude, locations.first.longitude);
              _isGeocodingCustomer = false;
            });
          }
          return;
        }
      } catch (e) {
        print('Geocoding error: $e');
        
        // Fallback to OSM Nominatim API if native geocoding fails (e.g. on emulators)
        try {
           print('Trying OSM Nominatim fallback for: $address');
           final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1');
           final response = await http.get(url, headers: {'User-Agent': 'GroferyRiderApp'});
           if (response.statusCode == 200) {
             final List data = jsonDecode(response.body);
             if (data.isNotEmpty) {
               final double lat = double.parse(data[0]['lat'].toString());
               final double lng = double.parse(data[0]['lon'].toString());
               print('OSM Nominatim success: lat=$lat, lng=$lng');
               if (mounted) {
                 setState(() {
                   _customerLatLng = LatLng(lat, lng);
                   _isGeocodingCustomer = false;
                 });
               }
               return;
             } else {
               print('OSM Nominatim returned empty results, trying just city');
               if (widget.order.shippingCity != null) {
                 final cityUrl = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(widget.order.shippingCity!)}&format=json&limit=1');
                 final cityResponse = await http.get(cityUrl, headers: {'User-Agent': 'GroferyRiderApp'});
                 if (cityResponse.statusCode == 200) {
                   final List cityData = jsonDecode(cityResponse.body);
                   if (cityData.isNotEmpty) {
                     final double lat = double.parse(cityData[0]['lat'].toString());
                     final double lng = double.parse(cityData[0]['lon'].toString());
                     print('OSM Nominatim city fallback success: lat=$lat, lng=$lng');
                     if (mounted) {
                       setState(() {
                         _customerLatLng = LatLng(lat, lng);
                         _isGeocodingCustomer = false;
                       });
                     }
                     return;
                   }
                 }
               }
             }
           } else {
             print('OSM Nominatim failed with status code: ${response.statusCode}');
           }
        } catch(e2) {
           print('OSM Nominatim error: $e2');
        }
      }
    }

    if (mounted) {
      setState(() {
        _isGeocodingCustomer = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          _setFallbackLocation();
          return;
        }
      }

      PermissionStatus permissionGranted;
      try {
        permissionGranted = await Future.microtask(
          () async => await location.hasPermission(),
        );
      } catch (e) {
        _setFallbackLocation();
        return;
      }

      if (permissionGranted == PermissionStatus.denied) {
        try {
          permissionGranted = await Future.microtask(
            () async => await location.requestPermission(),
          );
          if (permissionGranted != PermissionStatus.granted) {
            _setFallbackLocation();
            return;
          }
        } catch (e) {
          _setFallbackLocation();
          return;
        }
      }

      final locationData = await location.getLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Location request timed out'),
      );

      setState(() {
        _currentLocation = locationData;
        _isLoadingLocation = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToAllPoints());
    } catch (e) {
      _setFallbackLocation();
    }
  }

  void _checkArrivalStatus() {
    // Check if arrival has already been confirmed based on order data
    if (widget.order.items != null) {
      final hasAnyReachedDestination = widget.order.items!.any(
        (item) => item.reachedDestination == true,
      );
      if (hasAnyReachedDestination && !_hasReachedDestination) {
        setState(() {
          _hasReachedDestination = true;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check arrival status whenever dependencies change
    _checkArrivalStatus();
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
      // Use shipping address coordinates + offset as fallback location so it doesn't overlap exactly
      double fallbackLat = 23.2488453; // Default Bhuj coordinates
      double fallbackLng = 69.6696795;

      // Try to use the store's location as the fallback so distance matches exactly with what's expected
      if (widget.order.deliveryRoute?.routeDetails?.isNotEmpty == true) {
        final firstStore = widget.order.deliveryRoute!.routeDetails!.first;
        if (firstStore.latitude != null && firstStore.longitude != null) {
          fallbackLat = firstStore.latitude!;
          fallbackLng = firstStore.longitude!;
        } else if (_customerLatLng != null) {
          fallbackLat = _customerLatLng!.latitude - 0.02;
          fallbackLng = _customerLatLng!.longitude - 0.02;
        }
      } else if (_customerLatLng != null) {
        fallbackLat = _customerLatLng!.latitude - 0.02; // Offset by ~2km south
        fallbackLng = _customerLatLng!.longitude - 0.02; // Offset by ~2km west
      }

      _currentLocation = LocationData.fromMap({
        'latitude': fallbackLat,
        'longitude': fallbackLng,
      });
      _isLoadingLocation = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToAllPoints());
  }

  void _fitMapToAllPoints() {
    if (_currentLocation == null) return;

    final dest = _destinationLocation;
    final List<LatLng> allPoints = [
      LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      dest,
    ];

    if (allPoints.length >= 2) {
      // Add a tiny offset to avoid 0-area bounds crashing FlutterMap
      final bounds = LatLngBounds.fromPoints(allPoints);
      if (bounds.southWest == bounds.northEast) {
        bounds.extend(LatLng(bounds.northEast.latitude + 0.001, bounds.northEast.longitude + 0.001));
        bounds.extend(LatLng(bounds.southWest.latitude - 0.001, bounds.southWest.longitude - 0.001));
      }

      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(50)),
      );
    } else {}
  }

  List<LatLng> _generatePickupRoute() {
    if (_currentLocation == null) return [];

    final dest = _destinationLocation;
    final List<LatLng> routePoints = [
      LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      dest,
    ];

    final validPoints =
        routePoints
            .where((p) => !p.latitude.isNaN && !p.longitude.isNaN)
            .toList();

    return validPoints;
  }

  List<Polyline> _generateDashedRoute() {
    final List<Polyline> dashedPolylines = [];
    final routePoints = _generatePickupRoute();

    if (routePoints.length < 2) {
      if (routePoints.isNotEmpty) {
        return [
          Polyline(
            points: routePoints,
            strokeWidth: 3.sp,
            color: const Color(0xFF059669),
          ),
        ];
      }
      return [];
    }

    for (int i = 0; i < routePoints.length - 1; i++) {
      final start = routePoints[i];
      final end = routePoints[i + 1];

      // Create 15 dashes for this segment (settings dashes = settings visible)
      const int numDashes = 15;
      for (int dash = 0; dash < numDashes; dash++) {
        final dashStartFraction = dash / numDashes.toDouble();
        final dashEndFraction =
            (dash + 0.4) /
            numDashes.toDouble(); // 40% dash, 60% gap for clear visibility

        if (dashEndFraction <= 1.0) {
          final dashStart = _interpolatePoint(start, end, dashStartFraction);
          final dashEnd = _interpolatePoint(start, end, dashEndFraction);

          if (!dashStart.latitude.isNaN &&
              !dashStart.longitude.isNaN &&
              !dashEnd.latitude.isNaN &&
              !dashEnd.longitude.isNaN) {
            dashedPolylines.add(
              Polyline(
                points: [dashStart, dashEnd],
                strokeWidth: 3.sp, // Medium thickness for better visibility
                color: const Color(0xFF059669),
                strokeCap: StrokeCap.round,
              ),
            );
          }
        }
      }
    }

    return dashedPolylines;
  }

  LatLng _interpolatePoint(LatLng start, LatLng end, double fraction) {
    if (fraction.isNaN || fraction < 0.0 || fraction > 1.0) {
      return start; // Fallback to start point
    }
    final lat = start.latitude + (end.latitude - start.latitude) * fraction;
    final lng = start.longitude + (end.longitude - start.longitude) * fraction;
    return LatLng(lat.isNaN ? 0.0 : lat, lng.isNaN ? 0.0 : lng);
  }

  // Calculate distance from current location to stores (excluding shipping address)
  double _calculateDistanceToStores() {
    if (_currentLocation == null) {
      return 0.0;
    }

    final dest = _destinationLocation;
    final currentPoint = _getCurrentLocationLatLng();

    if (!currentPoint.latitude.isNaN && !currentPoint.longitude.isNaN) {
      const double earthRadius = 6371; // kilometers
      final lat1 = currentPoint.latitude * pi / 180;
      final lat2 = dest.latitude * pi / 180;
      final deltaLat = (dest.latitude - currentPoint.latitude) * pi / 180;
      final deltaLng = (dest.longitude - currentPoint.longitude) * pi / 180;

      final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
          cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
      if (a <= 1.0) {
        final c = 2 * atan2(sqrt(a), sqrt(1 - a));
        return earthRadius * c;
      }
    }
    return 0.0;
  }

  LatLng _getCurrentLocationLatLng() {
    if (_currentLocation != null) {
      return LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    }

    if (_customerLatLng != null) {
      return _customerLatLng!;
    }

    // Final fallback to default Bhuj coordinates

    return const LatLng(23.2488453, 69.6696795);
  }

  LatLng get _destinationLocation {
    if (_customerLatLng != null) {
      return _customerLatLng!;
    }
    // Final fallback to default Bhuj coordinates
    return const LatLng(23.2488453, 69.6696795);
  }

  void _showArrivalConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.green),
              SizedBox(width: 8.w),
              CustomText(
                text: AppLocalizations.of(context)!.confirmArrival,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          content: CustomText(
            text: AppLocalizations.of(context)!.haveYouReachedAddress,
            fontSize: 14.sp,
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: CustomText(
                text: AppLocalizations.of(context)!.cancel,
                fontSize: 14.sp,
              ),
            ),
            CustomButton(
              textSize: 15.sp,
              text: AppLocalizations.of(context)!.yesImHere,
              onPressed: () {
                context.pop();
                setState(() {
                  _hasConfirmedArrival = true;
                  _hasReachedDestination =
                      true; // Set this to true to show "Arrival Confirmed"
                });

                // Mark ALL items as reached destination using the bloc from widget
                if (widget.order.items != null &&
                    widget.order.items!.isNotEmpty &&
                    widget.bloc != null) {
                  for (final item in widget.order.items!) {
                    if (item.id != null) {
                      widget.bloc!.add(
                        MarkItemReachedDestination(widget.order.id!, item.id!),
                      );
                    }
                  }
                } else {
                  //
                }

                // Show success message
                ToastManager.show(
                  context: context,
                  message: 'Arrival confirmed! You can now view order details.',
                  type: ToastType.success,
                );

                // Automatically navigate to order details page after 3 seconds
                Future.delayed(const Duration(seconds: 3), () {
                  if (!context.mounted) return;
                  if (mounted) {
                    context.pushNamed(
                      'orderDetails',
                      extra: {
                        'orderId': widget.order.id,
                        'from':
                            false, // Using false instead of string as expected by the route
                      },
                    );
                  }
                });
              },
              backgroundColor: AppColors.primaryColor,
              textColor: Colors.white,
            ),
          ],
        );
      },
    );
  }

  List<Marker> _buildMarkers() {
    final List<Marker> markers = [];

    if (_currentLocation != null) {
      if (_currentLocation!.latitude!.isNaN ||
          _currentLocation!.longitude!.isNaN) {
      } else {
        markers.add(
          Marker(
            point: LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
            width: 40.w,
            height: 40.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Icon(Icons.my_location, color: Colors.white, size: 20.sp),
            ),
          ),
        );
      }
    }

    // Add seller/shipping address marker
    markers.add(
      Marker(
        point: _destinationLocation,
        width: 45.w,
        height: 45.h,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Icon(Icons.location_on, color: Colors.white, size: 22.sp),
        ),
      ),
    );

    final routePoints = _generatePickupRoute();
    if (routePoints.length > 2) {
      final bikeIndex = (routePoints.length / 2).floor();
      if (bikeIndex < routePoints.length) {
        // final bikePoint = routePoints[bikeIndex];
        // final nextIndex = (bikeIndex + 1).clamp(0, routePoints.length - 1);
        // final nextPoint = routePoints[nextIndex];
        // final angle =
        //     atan2(
        //       nextPoint.longitude - bikePoint.longitude,
        //       nextPoint.latitude - bikePoint.latitude,
        //     ) *
        //     10 /
        //     pi;
      }
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.order.items != null) {
    //   final reachedDestinationItems =
    //       widget.order.items!
    //           .where((item) => item.reachedDestination == true)
    //           .length;
    //
    //   // Check if View Details button should be shown
    //   final shouldShowViewDetails =
    //       _hasReachedDestination || _hasConfirmedArrival;
    // }

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkTheme = themeState.currentTheme == 'dark';

        if (widget.order.deliveryRoute?.routeDetails != null) {
          for (
            int i = 0;
            i < widget.order.deliveryRoute!.routeDetails!.length;
            i++
          ) {
            // final store = widget.order.deliveryRoute!.routeDetails![i];
          }
        }

        return CustomScaffold(
          appBar: CustomAppBarWithoutNavbar(
            title: AppLocalizations.of(context)!.deliveryRoute,

            showRefreshButton: false,
            showThemeToggle: false,
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter:
                      _currentLocation != null
                          ? _getCurrentLocationLatLng()
                          : const LatLng(23.2530, 69.6693),
                  initialZoom: 13.0,
                  onMapReady: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_currentLocation != null) _fitMapToAllPoints();
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: packageName,
                    maxZoom: 19,
                    minZoom: 0.0,
                  ),
                  if (_currentLocation != null) ...[
                    PolylineLayer(polylines: _generateDashedRoute()),
                    MarkerLayer(markers: _buildMarkers()),
                  ],
                ],
              ),
              if (_isLoadingLocation || _isGeocodingCustomer)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        CustomText(
                          text: AppLocalizations.of(context)!.loadingMap,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.straighten,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      CustomText(
                        text:
                            '${_calculateDistanceToStores().toStringAsFixed(1)} km',
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                    minHeight: 150.h,
                  ),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isDarkTheme ? AppColors.cardDarkColor : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15.r,
                        offset: Offset(0, 5.h),
                        spreadRadius: 2.r,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 32.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Icon(
                                    Icons.store,
                                    color: Colors.white,
                                    size: 14.sp,
                                  ),
                                ),
                                SizedBox(width: 7.w),
                                CustomText(
                                  text:
                                      AppLocalizations.of(
                                        context,
                                      )!.deliveryRoute,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.oppColorChange,
                                ),
                              ],
                            ),

                            if (!_hasReachedDestination ||
                                !_hasConfirmedArrival)
                              CustomText(
                                text:
                                    '${_calculateDistanceToStores().toStringAsFixed(1)} km',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            if (_hasReachedDestination ||
                                _hasConfirmedArrival) ...[
                              SizedBox(
                                width: 100.w,
                                height: 24.h,
                                child: CustomButton(
                                  text:
                                      AppLocalizations.of(context)!.viewDetails,
                                  // width: 80.w,
                                  textSize: 10.sp,
                                  height: 24.h,

                                  borderRadius: 12.r,
                                  backgroundColor: AppColors.primaryColor,
                                  textColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onPressed: () {
                                    context.push(
                                      AppRoutes.orderDetails,
                                      extra: {
                                        'orderId': widget.order.id!,
                                        'from': true,
                                        'sourceTab':
                                            1, // 1 = My Orders tab (since this is from accepted orders)
                                        'arrivalConfirmed':
                                            _hasReachedDestination ||
                                            _hasConfirmedArrival, // Pass arrival status
                                        'groupOrders': widget.groupOrders,
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Shipping Address Section
                      SizedBox(height: 12.h),
                      if (widget.order.shippingAddress1 != null)
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: CustomText(
                                  text: widget.order.shippingAddress1!,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 8.h),

                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          textSize: 15.sp,
                          text:
                              _hasReachedDestination
                                  ? AppLocalizations.of(
                                    context,
                                  )!.arrivalConfirmed
                                  : AppLocalizations.of(
                                    context,
                                  )!.confirmArrival,
                          onPressed:
                              _hasReachedDestination
                                  ? null
                                  : _showArrivalConfirmationDialog,
                          icon: Icon(
                            _hasReachedDestination
                                ? Icons.check_circle
                                : Icons.location_on,
                            color:
                                _hasReachedDestination
                                    ? Colors.green
                                    : Colors.white,
                          ),
                          backgroundColor:
                              _hasReachedDestination
                                  ? Colors.grey.shade200
                                  : AppColors.primaryColor,
                          textColor:
                              _hasReachedDestination
                                  ? Colors.green
                                  : Colors.white,
                          borderRadius: 8.r,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          textStyle: TextStyle(
                            color:
                                _hasReachedDestination
                                    ? Colors.green
                                    : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () async {
                    try {
                      final currentLocation = _getCurrentLocationLatLng();
                      final currentLat = currentLocation.latitude.toString();
                      final currentLng = currentLocation.longitude.toString();

                      // String destinationLat = '0', destinationLng = '0';

                      // Use shipping address coordinates for navigation (final destination)
                      if (widget.order.shippingLatitude != null &&
                          widget.order.shippingLongitude != null) {
                        // destinationLat = widget.order.shippingLatitude!;
                        // destinationLng = widget.order.shippingLongitude!;
                      } else if (widget.order.deliveryRoute?.routeDetails !=
                              null &&
                          widget
                              .order
                              .deliveryRoute!
                              .routeDetails!
                              .isNotEmpty) {
                        // Fallback to last item in route_details (shipping address)
                        final lastIndex =
                            widget.order.deliveryRoute!.routeDetails!.length -
                            1;
                        final shippingAddress =
                            widget
                                .order
                                .deliveryRoute!
                                .routeDetails![lastIndex];
                        if (shippingAddress.latitude != null &&
                            shippingAddress.longitude != null) {
                          // destinationLat = shippingAddress.latitude!.toString();
                          // destinationLng =
                          //     shippingAddress.longitude!.toString();
                        }
                      }

                      // For PickupRouteMapPage: Only navigate to shipping address (no store addresses)
                      String destinationAddress =
                          'Bhuj, Gujarat, India'; // Default fallback

                      // Use shipping address directly (this is a pickup route to seller)
                      if (widget.order.shippingAddress1 != null) {
                        destinationAddress = widget.order.shippingAddress1!;
                        if (widget.order.shippingAddress2 != null) {
                          destinationAddress +=
                              ', ${widget.order.shippingAddress2}';
                        }
                      } else if (widget.order.deliveryRoute?.routeDetails !=
                              null &&
                          widget
                              .order
                              .deliveryRoute!
                              .routeDetails!
                              .isNotEmpty) {
                        // Fallback to last item in route_details (shipping address)
                        final lastIndex =
                            widget.order.deliveryRoute!.routeDetails!.length -
                            1;
                        final shippingAddress =
                            widget
                                .order
                                .deliveryRoute!
                                .routeDetails![lastIndex];
                        if (shippingAddress.address != null &&
                            shippingAddress.address!.isNotEmpty) {
                          destinationAddress = shippingAddress.address!;
                        }
                      }

                      // Build Google Maps URL: Current location to shipping address only
                      final googleMapsUrl =
                          'https://www.google.com/maps/dir/?api=1'
                          '&origin=${Uri.encodeComponent('$currentLat,$currentLng')}'
                          '&destination=${Uri.encodeComponent(destinationAddress)}'
                          '&travelmode=driving';

                      final url = Uri.parse(googleMapsUrl);
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ToastManager.show(
                        context: context,
                        message: 'Could not open navigation: $e',
                        type: ToastType.error,
                      );
                    }
                  },
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.navigation),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
