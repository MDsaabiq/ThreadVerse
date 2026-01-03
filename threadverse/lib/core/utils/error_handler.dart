import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:threadverse/core/widgets/app_toast.dart';

/// Centralized error handler for the application
class ErrorHandler {
  /// Handle DioException and show appropriate toast
  static void handleDioError(BuildContext context, DioException error) {
    String message = 'An error occurred';
    String? title;

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      // Try to extract error message from response
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? data['error'] ?? message;
      } else if (data is String) {
        message = data;
      }

      // Set title based on status code
      switch (statusCode) {
        case 400:
          title = 'Invalid Request';
          break;
        case 401:
          title = 'Unauthorized';
          message = 'Please log in to continue';
          break;
        case 403:
          title = 'Forbidden';
          message = 'You don\'t have permission to do this';
          break;
        case 404:
          title = 'Not Found';
          break;
        case 409:
          title = 'Conflict';
          break;
        case 429:
          title = 'Too Many Requests';
          message = 'Please slow down and try again later';
          break;
        case 500:
        case 502:
        case 503:
          title = 'Server Error';
          message = 'Something went wrong on our end. Please try again later.';
          break;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      title = 'Connection Timeout';
      message = 'The request took too long. Please check your connection.';
    } else if (error.type == DioExceptionType.connectionError) {
      title = 'Connection Error';
      message = 'Unable to connect to the server. Please check your internet connection.';
    } else if (error.type == DioExceptionType.badResponse) {
      title = 'Bad Response';
      message = 'Received an invalid response from the server.';
    } else if (error.type == DioExceptionType.cancel) {
      // Don't show toast for cancelled requests
      return;
    }

    AppToast.error(context, message, title: title);
  }

  /// Handle generic errors
  static void handleError(BuildContext context, dynamic error) {
    if (error is DioException) {
      handleDioError(context, error);
    } else {
      AppToast.error(
        context,
        error.toString(),
        title: 'Error',
      );
    }
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message, {String? title}) {
    AppToast.success(context, message, title: title);
  }

  /// Show warning message
  static void showWarning(BuildContext context, String message, {String? title}) {
    AppToast.warning(context, message, title: title);
  }

  /// Show info message
  static void showInfo(BuildContext context, String message, {String? title}) {
    AppToast.info(context, message, title: title);
  }

  /// Get user-friendly error message from DioException
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map<String, dynamic>) {
        final data = error.response!.data as Map<String, dynamic>;
        return data['message'] ?? data['error'] ?? 'An error occurred';
      }
      if (error.response?.data is String) {
        return error.response!.data as String;
      }
      return error.message ?? 'An error occurred';
    }
    return error.toString();
  }

  /// Validate input and show error if invalid
  static bool validateInput(
    BuildContext context, {
    String? value,
    String? fieldName,
    int? minLength,
    int? maxLength,
    bool? required,
    String? pattern,
  }) {
    fieldName ??= 'Field';

    if (required == true && (value == null || value.isEmpty)) {
      AppToast.warning(context, '$fieldName is required');
      return false;
    }

    if (value != null && value.isNotEmpty) {
      if (minLength != null && value.length < minLength) {
        AppToast.warning(
          context,
          '$fieldName must be at least $minLength characters',
        );
        return false;
      }

      if (maxLength != null && value.length > maxLength) {
        AppToast.warning(
          context,
          '$fieldName must be at most $maxLength characters',
        );
        return false;
      }

      if (pattern != null) {
        final regex = RegExp(pattern);
        if (!regex.hasMatch(value)) {
          AppToast.warning(context, '$fieldName has invalid format');
          return false;
        }
      }
    }

    return true;
  }
}
