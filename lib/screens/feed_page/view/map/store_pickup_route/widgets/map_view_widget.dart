import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:grofery_rider/config/constant.dart';

class MapViewWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng initialCenter;
  final List<Polyline> polylines;
  final List<Marker> markers;
  final VoidCallback onMapReady;
  final bool showMapContent;

  const MapViewWidget({
    super.key,
    required this.mapController,
    required this.initialCenter,
    required this.polylines,
    required this.markers,
    required this.onMapReady,
    required this.showMapContent,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 13.0,
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: packageName,
        ),
        // Only show polylines and markers when content is available
        if (showMapContent) ...[
          PolylineLayer(polylines: polylines),
          MarkerLayer(markers: markers),
        ],
      ],
    );
  }
}
