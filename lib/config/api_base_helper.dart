import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:grofery_rider/config/security.dart';
import 'error_message_code.dart';

class ApiBaseHelper {
  static final Dio _dio =
      Dio()
        ..options.connectTimeout = const Duration(seconds: 30)
        ..options.receiveTimeout = const Duration(seconds: 30)
        ..options.sendTimeout = const Duration(seconds: 30)
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              debugPrint('➡️ REQUEST');
              debugPrint('URL: ${options.uri}');
              debugPrint('Method: ${options.method}');
              debugPrint('Headers: ${options.headers}');
              debugPrint('Query params: ${options.queryParameters}');
              debugPrint('Body: ${options.data}');
              return handler.next(options);
            },
            onResponse: (response, handler) {
              debugPrint('✅ RESPONSE');
              debugPrint('URL: ${response.requestOptions.uri}');
              debugPrint('Status: ${response.statusCode}');
              debugPrint('Data: ${response.data}');
              return handler.next(response);
            },
            onError: (DioException e, handler) async {
              debugPrint('❌ ERROR');
              debugPrint('URL: ${e.requestOptions.uri}');
              debugPrint('Status: ${e.response?.statusCode}');
              debugPrint('Error: ${e.message}');
              debugPrint('Response: ${e.response?.data}');
              return handler.next(e);
            },
          ),
        );

  static Future<Map<String, dynamic>> loginPost({
    Map<String, dynamic>? body,
    required String url,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      ("e: $e");
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> formPost({
    required String url,
    dynamic body,
    bool useAuthToken = true,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final Map<String, String> authHeaders = await headers;
      final response = await _dio.post(
        url,
        data: body,

        queryParameters: queryParameters,
        options: Options(
          headers: authHeaders,
          contentType: Headers.jsonContentType,
        ),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (response.statusCode != 200) {}

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }

      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> post({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      body ??= {};

      final Map<String, String> authHeaders = await headers;

      final response = await _dio.post(
        url,
        data: body,
        options: Options(headers: authHeaders, followRedirects: false),
      );

      if (response.statusCode != 200) {
        return {
          'success': false,
          'message': 'Request failed with status ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }

      final responseData = response.data as Map<String, dynamic>;

      return responseData;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }

      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> postMedia({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final Map<String, String> authHeaders = await headers;

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: authHeaders),
      );
      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }

      return <String, dynamic>{"data": Map.from(response.data), "status": 200};
    } on DioException catch (e) {
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<dynamic> postProfile({
    required String url,
    bool? useAuthToken,
    File? profile,
    String? type,
    int? id,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'upload': await MultipartFile.fromFile(profile!.path),
        'id': id,
        'type': type,
      });

      final Map<String, String> header = await headers;
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: header),
      );
      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }

      return <String, dynamic>{"data": Map.from(response.data), "status": 200};
    } on DioException catch (e) {
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<dynamic> delete({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      body ??= {};

      FormData formData = FormData();
      final Map<String, String> header = await headers;

      body.forEach((key, value) {
        if (value is File) {
          formData.files.add(
            MapEntry(
              key,
              MultipartFile.fromFileSync(
                value.path,
                filename: value.path.split('/').last,
              ),
            ),
          );
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      final response = await _dio.delete(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: header),
      );

      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }

      return <String, dynamic>{"data": Map.from(response.data), "status": 200};
    } on DioException catch (e) {
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> deleteApi({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      body ??= {};
      FormData formData = FormData();
      final Map<String, String> header = await headers;

      body.forEach((key, value) {
        if (value is File) {
          formData.files.add(
            MapEntry(
              key,
              MultipartFile.fromFileSync(
                value.path,
                filename: value.path.split('/').last,
              ),
            ),
          );
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      final response = await _dio.delete(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(headers: header),
      );

      if (response.data['error']) {
        throw ApiException(response.data['message']);
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> getApi({
    required String url,
    required bool useAuthToken,
    required Map<String, dynamic> params,
  }) async {
    final Map<String, String> header = await headers;
    try {
      final response = await _dio.get(
        url,
        queryParameters: params,
        options: Options(headers: header),
      );

      if (response.statusCode == 403) {
        final responseData = response.data as Map<String, dynamic>;
        return {
          'statusCode': 403,
          'message':
              responseData['message'] ?? 'Your account is currently inactive',
          'success': false,
          ...responseData,
        };
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final responseData = e.response?.data as Map<String, dynamic>? ?? {};
        return {
          'statusCode': 403,
          'message':
              responseData['message'] ?? 'Your account is currently inactive',
          'success': false,
          ...responseData,
        };
      }

      if (e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }

      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on SocketException {
      throw ApiException('No Internet connection');
    } catch (e) {
      throw ApiException('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> put({
    Map<String, dynamic>? body,
    required String url,
    bool? useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      body ??= {};

      final Map<String, String> authHeaders = await headers;

      final response = await _dio.put(
        url,
        data: body,
        options: Options(headers: authHeaders),
      );

      if (response.statusCode != 200) {}

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null) {
      } else {}
      if (e.response?.data != null) {
        return e.response?.data as Map<String, dynamic>;
      }

      throw ApiException(
        e.error is SocketException
            ? ErrorMessageKeysAndCode.noInternetCode
            : ErrorMessageKeysAndCode.defaultErrorMessageCode,
        isNoInternet: true,
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }
}

class ApiException implements Exception {
  String errorMessage;
  bool isNoInternet;

  ApiException(this.errorMessage, {this.isNoInternet = false});

  @override
  String toString() {
    return errorMessage;
  }
}
