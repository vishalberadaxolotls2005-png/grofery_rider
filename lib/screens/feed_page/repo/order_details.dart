import 'package:grofery_rider/config/api_routes.dart';
import '../../../config/api_base_helper.dart';

class OrderDetailsRepo {
  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {

      final response = await ApiBaseHelper.getApi(
        url: '$orderDetailsApi/$orderId',
        useAuthToken: true,
        params: {},
      );


      return response;
    } catch (error) {

      throw Exception('Error occurred while fetching order details');
    }
  }
}
