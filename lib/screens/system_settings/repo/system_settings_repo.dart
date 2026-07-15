import 'package:grofery_rider/config/api_base_helper.dart';
import 'package:grofery_rider/config/api_routes.dart';
import '../model/settings_repo.dart';

class SystemSettingsRepo {
  Future<SettingsModel?> getSystemSettings() async {
    try {
      final response = await ApiBaseHelper.getApi(
        url: getSystemSettingApi,
        useAuthToken: true,
        params: {},
      );

      if (response['success'] == true) {
        // Pass the entire response to the model
        return SettingsModel.fromJson(response);
      } else {
        // Return null if API fails
        return null;
      }
    } catch (e) {
      // Return null on error
      return null;
    }
  }

  Future<SettingsModel?> getDeliveryBoySettings() async {
    try {
      final response = await ApiBaseHelper.getApi(
        url: getDeliveryBoySettingsApi,
        useAuthToken: true,
        params: {},
      );

      if (response['success'] == true) {
        // Pass the entire response to the model
        return SettingsModel.fromJson(response);
      } else {
        // Return null if API fails
        return null;
      }
    } catch (e) {
      // Return null on error
      return null;
    }
  }
}
