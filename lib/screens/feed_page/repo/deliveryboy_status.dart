import 'package:grofery_rider/config/api_routes.dart';
import 'package:grofery_rider/config/constant.dart';


import '../../../config/api_base_helper.dart';

class DeliveryBoyStatusRepo {
  Future<Map<String, dynamic>> getDeliveryBoyStatus() async {
    try {
      final response = await ApiBaseHelper.getApi(
        url: '${baseUrl}profile',
        useAuthToken: true,
        params: {},
      );
      return response;
    } catch (error) {

      throw Exception('Error occurred while getting status');
    }
  }

  Future<Map<String, dynamic>> updateDeliveryBoyStatus({
    required bool isOnline,
    double? latitude,
    double? longitude,
  }) async {
    try {
      String status = isOnline == true ? "active" : "inactive";
      Map<String, dynamic> body = {
        'status': status,
        // 23.12171827, 69.99563923
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };


      final response = await ApiBaseHelper.post(
        url: deliveryBoyStatusApi,
        useAuthToken: true,
        body: body,
      );


      return response;
    } catch (error) {

      throw Exception('Error occurred: ${error.toString()}');
    }
  }
}
