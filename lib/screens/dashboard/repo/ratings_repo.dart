import '../model/ratings_model.dart';
import '../../../config/api_base_helper.dart';
import '../../../config/api_routes.dart';
import '../../../config/constant.dart';

class RatingsRepo {
  // Get delivery boy ID from profile
  Future<int> _getDeliveryBoyId() async {
    try {
      final response = await ApiBaseHelper.getApi(
        url: '${baseUrl}profile',
        useAuthToken: true,
        params: {},
      );

      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['delivery_boy'] != null) {
        return response['data']['delivery_boy']['id'] ?? 0;
      } else {
        throw Exception('Failed to get delivery boy ID from profile');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  // Fetch overall ratings summary (total reviews, average rating, breakdown)
  Future<RatingsResponse> fetchOverallRatings() async {
    try {
      final deliveryBoyId = await _getDeliveryBoyId();

      final response = await ApiBaseHelper.getApi(
        url: ratingApi,
        useAuthToken: true,
        params: {'delivery_boy_id': deliveryBoyId},
      );

      return RatingsResponse.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching overall ratings: $e');
    }
  }

  // Fetch individual feedback items with pagination
  Future<DeliveryFeedbackResponse> fetchDeliveryFeedback({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final deliveryBoyId = await _getDeliveryBoyId();

      final response = await ApiBaseHelper.getApi(
        url: feedbackApi,
        useAuthToken: true,
        params: {
          'page': page,
          'per_page': perPage,
          'delivery_boy_id': deliveryBoyId,
        },
      );

      return DeliveryFeedbackResponse.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching delivery feedback: $e');
    }
  }
}
