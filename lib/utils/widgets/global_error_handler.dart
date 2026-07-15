import 'package:flutter/material.dart';
import 'inactive_account_widget.dart';
import 'custom_text.dart';

class GlobalErrorHandler {
  /// Checks if the error is a 403 status code and returns true if it is
  static bool is403Error(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();
    return errorString.contains('403') ||
        errorString.contains('forbidden') ||
        errorString.contains('inactive');
  }

  /// Checks if the API response indicates a 403 status
  static bool is403Response(Map<String, dynamic> response) {
    return response.containsKey('statusCode') && response['statusCode'] == 403;
  }

  /// Gets the error message from a 403 response
  static String? get403Message(Map<String, dynamic> response) {
    if (is403Response(response)) {
      return response['message'] ?? 'Your account is currently inactive';
    }
    return null;
  }

  /// Creates an inactive account widget for 403 errors
  static Widget createInactiveWidget({String? message, VoidCallback? onRetry}) {
    return InactiveAccountWidget(message: message, onRetry: onRetry);
  }

  /// Handles API responses and returns appropriate widgets for different error states
  static Widget handleApiResponse({
    required Map<String, dynamic> response,
    required Widget Function() onSuccess,
    Widget Function(String message)? onError,
    Widget Function(String message)? on403Error,
    VoidCallback? onRetry,
  }) {
    // Check for 403 status first
    if (is403Response(response)) {
      final message = get403Message(response);
      if (on403Error != null) {
        return on403Error(message ?? 'Your account is currently inactive');
      }
      return createInactiveWidget(message: message, onRetry: onRetry);
    }

    // Check for other error states
    if (response.containsKey('success') && response['success'] == false) {
      final message = response['message'] ?? 'An error occurred';
      if (onError != null) {
        return onError(message);
      }
      return Center(
        child: CustomText(
          text: 'Error: $message',
          fontSize: 16,
          color: Colors.red,
        ),
      );
    }

    // Success case
    return onSuccess();
  }
}
