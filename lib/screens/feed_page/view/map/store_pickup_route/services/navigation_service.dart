// ignore_for_file: empty_catches

import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import '../../../../model/available_orders.dart';

class NavigationService {
  /// Open Google Maps with navigation to stores
  static Future<void> openGoogleMapsToStores(
    LatLng currentLocation,
    List<RouteDetails> routeDetails,
  ) async {
    try {


      final List<String> storeAddresses = [];
      
      // Collect all store addresses (excluding "Customer Location" which is shipping address)
      for (int i = 0; i < routeDetails.length; i++) {
        final store = routeDetails[i];

        
        // Skip if it's "Customer Location" (shipping address) or doesn't have a store ID
        if (store.storeName?.toLowerCase() != 'customer location' &&
            store.storeId != null) {
          
          // Build store address
          final List<String> addressParts = [];
          if (store.address != null && store.address!.isNotEmpty) {
            addressParts.add(store.address!);
          }
          if (store.city != null && store.city!.isNotEmpty) {
            addressParts.add(store.city!);
          }
          if (store.state != null && store.state!.isNotEmpty) {
            addressParts.add(store.state!);
          }
          if (store.zipcode != null && store.zipcode!.isNotEmpty) {
            addressParts.add(store.zipcode!);
          }
          if (store.country != null && store.country!.isNotEmpty) {
            addressParts.add(store.country!);
          }
          
          if (addressParts.isNotEmpty) {
            final storeAddress = addressParts.join(', ');
            storeAddresses.add(storeAddress);

          } else {

          }
        } else {

        }
      }
      
      if (storeAddresses.isEmpty) {

        return;
      }
      
      // Build Google Maps URL
      final origin = '${currentLocation.latitude},${currentLocation.longitude}';
      final destination = storeAddresses.first;
      final waypoints = storeAddresses.skip(1).join('|');
      






      for (int i = 0; i < storeAddresses.length; i++) {

      }
      
      String googleMapsUrl;
      if (storeAddresses.length == 1) {
        // Single destination
        googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=${Uri.encodeComponent(destination)}&travelmode=driving';
      } else {
        // Multiple destinations with waypoints
        googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=${Uri.encodeComponent(destination)}&waypoints=${Uri.encodeComponent(waypoints)}&travelmode=driving';
      }
      

      
      final uri = Uri.parse(googleMapsUrl);
      
      // Try to launch with external application mode first
      try {
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(
            uri, 
            mode: LaunchMode.externalApplication,
          );
          if (launched) {

            return;
          }
        }
      } catch (e) {

      }
      
      // Fallback: Try to launch with in-app mode
      try {
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(
            uri, 
            mode: LaunchMode.inAppWebView,
          );
          if (launched) {

            return;
          }
        }
      } catch (e) {

      }
      
      // Fallback: Try to launch with platform default
      try {
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(uri);
          if (launched) {

            return;
          }
        }
      } catch (e) {

      }
      





      
      // Final fallback: Try to open in web browser
      try {
        final webUri = Uri.parse('https://www.google.com/maps');
        if (await canLaunchUrl(webUri)) {
          final launched = await launchUrl(
            webUri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) {

            return;
          }
        }
      } catch (e) {

      }
      
      // Try to open the actual navigation URL in browser
      try {
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) {

            return;
          }
        }
      } catch (e) {

      }
      
      // Try to open with device's default maps app using geo: scheme
      try {
        final geoUri = Uri.parse('geo:${currentLocation.latitude},${currentLocation.longitude}?q=${Uri.encodeComponent(storeAddresses.first)}');
        if (await canLaunchUrl(geoUri)) {
          final launched = await launchUrl(geoUri);
          if (launched) {

            return;
          }
        }
      } catch (e) {

      }
      
      // Try to open with device's default maps app using coordinates only
      try {
        final coordUri = Uri.parse('geo:${currentLocation.latitude},${currentLocation.longitude}');
        if (await canLaunchUrl(coordUri)) {
          final launched = await launchUrl(coordUri);
          if (launched) {

            return;
          }
        }
      } catch (e) {

      }
      


    } catch (e) {

    }
  }

  /// Open Google Maps with navigation to shipping address
  static Future<void> openGoogleMapsToShippingAddress(
    LatLng currentLocation,
    String? shippingAddress1,
    String? shippingAddress2,
  ) async {
    try {
      // Build shipping address
      final List<String> addressParts = [];
      if (shippingAddress1 != null && shippingAddress1.isNotEmpty) {
        addressParts.add(shippingAddress1);
      }
      if (shippingAddress2 != null && shippingAddress2.isNotEmpty) {
        addressParts.add(shippingAddress2);
      }
      
      if (addressParts.isEmpty) {

        return;
      }
      
      final destination = addressParts.join(', ');
      final origin = '${currentLocation.latitude},${currentLocation.longitude}';
      
      final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=${Uri.encodeComponent(destination)}&travelmode=driving';
      

      
      final uri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {

      }
    } catch (e) {

    }
  }
}
