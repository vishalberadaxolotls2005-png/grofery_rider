import '../../../../config/api_base_helper.dart';
import '../../../../config/api_routes.dart';
import '../model/cash_collection_model.dart';

class CashCollectionRepo {
  Future<CashCollectionResponse> getCashCollection({
    String? dateRange,
    String? submissionStatus,
    int? perPage,
    int? page,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      if (dateRange != null && dateRange.isNotEmpty) {
        params['date_range'] = dateRange;
      }
      if (submissionStatus != null) {
        params['submission_status'] = submissionStatus;
      }
      if (perPage != null) params['per_page'] = perPage;
      if (page != null) params['page'] = page;

      final response = await ApiBaseHelper.getApi(
        url: getCashCollectionApi,
        useAuthToken: true,
        params: params,
      );

      return CashCollectionResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch cash collection: $e');
    }
  }

  Future<CashCollectionResponse> getCashCollectionStats() async {
    try {
      final response = await ApiBaseHelper.getApi(
        url: getCashCollectionStatisticsApi,
        useAuthToken: true,
        params: {},
      );

      return CashCollectionResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch cash collection stats: $e');
    }
  }
}
