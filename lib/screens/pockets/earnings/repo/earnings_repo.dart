import '../../../../config/api_routes.dart';
import '../../../../config/api_base_helper.dart';
import '../model/earnings_model.dart';

class EarningsRepo {
  // Get earnings list
  Future<Map<String, dynamic>> getEarnings({
    String? dateRange,
    int? perPage,
    int? page,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      if (dateRange != null) {
        params['date_range'] = dateRange;
      }
      if (perPage != null) {
        params['per_page'] = perPage;
      }
      if (page != null) {
        params['page'] = page;
      }

      final response = await ApiBaseHelper.getApi(
        url: getEarningsApi,
        useAuthToken: true,
        params: params,
      );




      // Check if this is a 403 response
      if (response.containsKey('statusCode') && response['statusCode'] == 403) {
        // Return the response with status code for the bloc to handle
        return response;
      }

      // Convert to model for normal processing
      final earningsResponse = EarningsResponse.fromJson(response);
      return {'success': true, 'data': earningsResponse, 'statusCode': 200};
    } catch (error) {




      // Check if the error is a DioException with 403 status
      if (error.toString().contains('403') ||
          error.toString().contains('Forbidden')) {
        return {
          'statusCode': 403,
          'message': 'Access forbidden',
          'success': false,
        };
      }

      rethrow;
    }
  }

  // Get earnings statistics
  Future<Map<String, dynamic>> getEarningsStats() async {
    try {

      final response = await ApiBaseHelper.getApi(
        url: getEarningsStatsApi,
        useAuthToken: true,
        params: {},
      );







      // Check if this is a 403 response
      if (response.containsKey('statusCode') && response['statusCode'] == 403) {

        // Return the response with status code for the bloc to handle
        return response;
      }

      // Convert to model for normal processing
      final earningsStatsResponse = EarningsStatsResponse.fromJson(response);
      return {
        'success': true,
        'data': earningsStatsResponse,
        'statusCode': 200,
      };
    } catch (error) {





      // Check if the error is a DioException with 403 status
      if (error.toString().contains('403') ||
          error.toString().contains('Forbidden')) {
        return {
          'statusCode': 403,
          'message': 'Access forbidden',
          'success': false,
        };
      }

      throw Exception('Failed to fetch earnings statistics: $error');
    }
  }

  // Get earnings by date range
  Future<Map<String, dynamic>> getEarningsByDateRange({
    required String dateRange,
    int? perPage,
    int? page,
  }) async {
    try {
      final Map<String, dynamic> params = {'date_range': dateRange};
      if (perPage != null) {
        params['per_page'] = perPage;
      }
      if (page != null) {
        params['page'] = page;
      }

      final response = await ApiBaseHelper.getApi(
        url: getEarningsDateRangeApi,
        useAuthToken: true,
        params: params,
      );

      // Check if this is a 403 response
      if (response.containsKey('statusCode') && response['statusCode'] == 403) {
        // Return the response with status code for the bloc to handle
        return response;
      }

      // Convert to model for normal processing
      final earningsResponse = EarningsResponse.fromJson(response);
      return {'success': true, 'data': earningsResponse, 'statusCode': 200};
    } catch (error) {
      // Check if the error is a DioException with 403 status
      if (error.toString().contains('403') ||
          error.toString().contains('Forbidden')) {
        return {
          'statusCode': 403,
          'message': 'Access forbidden',
          'success': false,
        };
      }

      throw Exception('Failed to fetch earnings by date range: $error');
    }
  }
}
