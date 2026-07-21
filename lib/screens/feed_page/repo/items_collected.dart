import 'package:grofery_rider/config/api_routes.dart';
import '../../../config/api_base_helper.dart';

class ItemsCollectedRepo {
  Future<Map<String, dynamic>> itemsCollected(String orderItemId) async {
    try {
      final response = await ApiBaseHelper.put(
        url: '$itemsCollectedApi/$orderItemId/status',
        body: {
          'status': 'collected',
        },
      );

      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> itemsDelivered(String orderItemId, String? otp, {int? quantity, String? reason}) async {
    try {
      // Initialize the body with the status
      final Map<String, dynamic> body = {
        'status': 'delivered',
      };

      // Add otp to the body only if it is not null or empty
      if (otp != null && otp.isNotEmpty) {
        body['otp'] = otp;
      }
      
      if (quantity != null) {
        body['quantity'] = quantity;
      }
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await ApiBaseHelper.put(
        url: '$itemsCollectedApi/$orderItemId/status',
        body: body,
      );

      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
} 
