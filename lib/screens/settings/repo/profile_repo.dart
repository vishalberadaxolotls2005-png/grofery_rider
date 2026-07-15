import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../config/api_base_helper.dart';
import '../../../config/constant.dart';
import '../model/profile_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:grofery_rider/config/security.dart' as sec;

class ProfileRepo {
  Future<ProfileModel> getProfile() async {
    try {
      final response = await ApiBaseHelper.getApi(
        url: '${baseUrl}profile',
        useAuthToken: true,
        params: {},
      );

      if (response['success'] == true && response['data'] != null) {
        return ProfileModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ProfileModel> updateProfile({
    String? fullName,
    String? address,
    String? driverLicenseNumber,
    String? vehicleType,
    String? mobile,
    String? email,
    String? country,
    List<String>? driverLicenseFiles,
    List<String>? vehicleRegistrationFiles,
    String? profileImageFile,
  }) async {
    try {
      // Check if we have files to upload
      final hasFiles =
          (driverLicenseFiles?.isNotEmpty == true) ||
          (vehicleRegistrationFiles?.isNotEmpty == true) ||
          (profileImageFile != null);

      dynamic response;

      if (hasFiles) {
        // Use FormData for file uploads
        final formData = FormData.fromMap({});

        // Add text fields
        if (fullName != null) {
          formData.fields.add(MapEntry('full_name', fullName));
        }
        if (address != null) formData.fields.add(MapEntry('address', address));
        if (driverLicenseNumber != null) {
          formData.fields.add(
            MapEntry('driver_license_number', driverLicenseNumber),
          );
        }
        if (vehicleType != null) {
          formData.fields.add(MapEntry('vehicle_type', vehicleType));
        }
        if (mobile != null) formData.fields.add(MapEntry('mobile', mobile));
        if (email != null) formData.fields.add(MapEntry('email', email));
        if (country != null) formData.fields.add(MapEntry('country', country));

        // Add driver license files
        if (driverLicenseFiles?.isNotEmpty == true) {
          for (final filePath in driverLicenseFiles!) {
            if (filePath.startsWith('http://') ||
                filePath.startsWith('https://')) {
              // Network URL: Download and re-upload as file to pass backend validation
              try {
                final multipartFile = await _urlToMultipartFile(
                  filePath,
                  'driver_license[]',
                );
                if (multipartFile != null) {
                  formData.files.add(
                    MapEntry('driver_license[]', multipartFile),
                  );
                }
              } catch (e) {
                continue;
              }
            } else {
              // Upload local files
              try {
                final file = File(filePath);
                final fileName = file.path.split('/').last;
                formData.files.add(
                  MapEntry(
                    'driver_license[]',
                    await MultipartFile.fromFile(filePath, filename: fileName),
                  ),
                );
              } catch (e) {
                continue;
              }
            }
          }
        }

        // Add vehicle registration files
        if (vehicleRegistrationFiles?.isNotEmpty == true) {
          for (final filePath in vehicleRegistrationFiles!) {
            if (filePath.startsWith('http://') ||
                filePath.startsWith('https://')) {
              // Network URL: Download and re-upload as file to pass backend validation
              try {
                final multipartFile = await _urlToMultipartFile(
                  filePath,
                  'vehicle_registration[]',
                );
                if (multipartFile != null) {
                  formData.files.add(
                    MapEntry('vehicle_registration[]', multipartFile),
                  );
                }
              } catch (e) {
                continue;
              }
            } else {
              // Upload local files
              try {
                final file = File(filePath);
                final fileName = file.path.split('/').last;
                formData.files.add(
                  MapEntry(
                    'vehicle_registration[]',
                    await MultipartFile.fromFile(filePath, filename: fileName),
                  ),
                );
              } catch (e) {
                continue;
              }
            }
          }
        }

        // Add profile image (only local files, not network URLs)
        if (profileImageFile != null &&
            !profileImageFile.startsWith('http://') &&
            !profileImageFile.startsWith('https://')) {
          try {
            final file = File(profileImageFile);
            final fileName = file.path.split('/').last;
            formData.files.add(
              MapEntry(
                'profile_image',
                await MultipartFile.fromFile(
                  profileImageFile,
                  filename: fileName,
                ),
              ),
            );
          } catch (e) {
            //
          }
        }

        response = await ApiBaseHelper.formPost(
          url: '${baseUrl}profile',
          body: formData,
        );
      } else {
        // No files, use regular POST for text-only updates
        final Map<String, dynamic> body = {};

        // Add fields only if they are provided
        if (fullName != null) body['full_name'] = fullName;
        if (address != null) body['address'] = address;
        if (driverLicenseNumber != null) {
          body['driver_license_number'] = driverLicenseNumber;
        }
        if (vehicleType != null) body['vehicle_type'] = vehicleType;
        if (mobile != null) body['mobile'] = mobile;
        if (email != null) body['email'] = email;
        if (country != null) body['country'] = country;

        response = await ApiBaseHelper.post(
          url: '${baseUrl}profile',
          body: body,
        );
      }

      if (response['success'] == true && response['data'] != null) {
        final profile = ProfileModel.fromJson(response['data']);

        return profile;
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Downloads a network image and converts it to a MultipartFile
  Future<MultipartFile?> _urlToMultipartFile(
    String url,
    String fieldName,
  ) async {
    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final fileName = url.split('/').last.split('?').first;
      final filePath = '${tempDir.path}/$fieldName-$fileName';

      // Use the same auth headers for download
      final authHeaders = await sec.headers;

      await dio.download(url, filePath, options: Options(headers: authHeaders));

      return await MultipartFile.fromFile(filePath, filename: fileName);
    } catch (e) {
      debugPrint('Error downloading image for re-upload: $e');
      return null;
    }
  }
}
