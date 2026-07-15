import 'dart:developer';

import 'package:grofery_rider/config/api_routes.dart';
import '../../../config/api_base_helper.dart';

class MyOrdersRepo {
  Future<Map<String, dynamic>> myOrdersList({
    int? limit,
    int? offset,
    String? status,
    String? search = "",
  }) async {
    try {
      Map<String, dynamic> body = {};

      log('selected filter is :: $status');

      if (status != null) {
        body["status"] = status;
      }

      if (limit != null) {
        body["per_page"] = limit;
      }
      if (offset != null) {
        // Convert offset to page number (offset 0 = page 1, offset 10 = page 2, etc.)
        int page = (offset ~/ (limit ?? 10)) + 1;
        body["page"] = page;
      }


      final response = await ApiBaseHelper.getApi(
        url: myOrdersApi,
        useAuthToken: true,
        params: body,
      );
      
      log('My orders API response: $response');
      
      return response;
    } catch (error) {

      throw Exception('Error occurred');
    }
  }

  Future<Map<String, dynamic>> getDeliveredOrders({
    int? limit,
    int? offset,
    String? search = "",
  }) async {
    try {
      Map<String, dynamic> body = {
        "status": "completed", // Filter for completed orders only
      };

      if (limit != null) {
        body["per_page"] = limit;
      }
      if (offset != null) {
        // Convert offset to page number (offset 0 = page 1, offset 10 = page 2, etc.)
        int page = (offset ~/ (limit ?? 10)) + 1;
        body["page"] = page;

      }


      final response = await ApiBaseHelper.getApi(
        url: myOrdersApi,
        useAuthToken: true,
        params: body,
      );
      return response;
    } catch (error) {

      throw Exception('Error occurred');
    }
  }
}
