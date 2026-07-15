import 'package:grofery_rider/config/api_routes.dart';

import '../../../config/api_base_helper.dart';
class UpdateCurrentLocationRepo {
  Future<Map<String, dynamic>> updateCurrentLocation({
    double? latitude,
    double? longitude,
  }) async {
    try {

      Map<String, dynamic> body = {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      final response = await ApiBaseHelper.post(
        url: updateCurrentLocationApi,
        useAuthToken: true,
        body: body,


      );
      return response;
    } catch (error) {

      throw Exception('Error occurred');
    }
  }
}
