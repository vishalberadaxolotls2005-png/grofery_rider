import 'package:grofery_rider/config/api_routes.dart';
import '../../../../config/api_base_helper.dart';
import '../model/withdrawal_model.dart';

class WithdrawalRepo {
  // Create withdrawal request
  Future<Map<String, dynamic>> createWithdrawal(CreateWithdrawalRequest request) async {
    try {
      final response = await ApiBaseHelper.post(
        url: createWithdrawalsReqApi,
        useAuthToken: true,
        body: request.toJson(),
      );
      return response;
    } catch (error) {

      throw Exception('Error occurred while creating withdrawal request');
    }
  }

  // Get all withdrawals
  Future<Map<String, dynamic>> getWithdrawals({int? perPage, int? page}) async {
    try {
      final Map<String, dynamic> params = {};
      if (perPage != null) params['per_page'] = perPage;
      if (page != null) params['page'] = page;
      
      final response = await ApiBaseHelper.getApi(
        url: getWithdrawalsApi,
        useAuthToken: true,
        params: params,
      );
      return response;
    } catch (error) {

      throw Exception('Error occurred while fetching withdrawals');
    }
  }

  // Get single withdrawal by ID
  Future<Map<String, dynamic>> getWithdrawalById(int id) async {
    try {
      final response = await ApiBaseHelper.getApi(
        url: '$getWithdrawalByIdApi/$id',
        useAuthToken: true,
        params: {},
      );
      return response;
    } catch (error) {

      throw Exception('Error occurred while fetching withdrawal details');
    }
  }
} 
