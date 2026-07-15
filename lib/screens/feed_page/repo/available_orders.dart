import 'dart:developer';
import 'package:grofery_rider/config/api_routes.dart';

import '../../../config/api_base_helper.dart';
import '../../../utils/location_tracker.dart';

class AvailableOrdersRepo {
  Future<Map<String, dynamic>> availableOrdersList({
    int? limit,
    int? offset,
    String? search = "",
  }) async {
    try {
      Map<String, dynamic> body = {};
      // if (limit != null) {
      //   body["limit"] = limit;
      // }
      // if (offset != null) {
      //   body["offset"] = offset;
      // }

      final locationData = LocationTracker().currentLocation;
      if (locationData != null && locationData.latitude != null && locationData.longitude != null) {
        body['latitude'] = locationData.latitude;
        body['longitude'] = locationData.longitude;
      } else {
        // Fallback coordinates if location fetching fails
        body['latitude'] = 18.50;
        body['longitude'] = 73.86;
      }

      final response = await ApiBaseHelper.getApi(
        url: availableOrdersStatusApi,
        useAuthToken: true,
        params: body,
      );
      
      log('Available orders API response: $response');
      
      return response;
    } catch (error) {

      throw Exception('Error occurred');
    }
  }
}
