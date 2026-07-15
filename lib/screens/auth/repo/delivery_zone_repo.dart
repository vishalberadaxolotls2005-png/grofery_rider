import 'package:flutter/material.dart';
import 'package:grofery_rider/config/api_routes.dart';

import '../../../config/api_base_helper.dart';

class DeliveryZoneRepo {
  Future<Map<String, dynamic>> getDeliveryZone({
    int? offset,
    int? limit,
  }) async {
    try {
      Map<String, dynamic> body = {};

      // if (limit != null) {
      //   body["limit"] = limit;
      // }
      //
      // if (offset != null) {
      //   body["offset"] = offset;
      // }

      final response = await ApiBaseHelper.getApi(
        url: deliveryZoneApi,
        useAuthToken: true,
        params: body,
      );
      return response;
    } catch (error, s) {
      debugPrint('error ::: $error');
      debugPrint('stacktrace ::: $s');
      throw Exception('Error occurred');
    }
  }
}
