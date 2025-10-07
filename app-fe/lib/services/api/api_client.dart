import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/api_routes.dart';
import '../../config/time_config.dart';
import '../../models/api/api_error.dart';
import '../../routes/auth_routes.dart';
import '../../routes/student_routes.dart';
import '../../routes/tuition_routes.dart';
import '../../routes/payment_routes.dart';

class ApiException implements Exception {
  final ApiError error;

  ApiException(this.error);

  @override
  String toString() => error.toString();
}

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers ?? ApiRoutes.defaultHeaders,
            body: jsonEncode(body),
          )
          .timeout(TimeConfig.requestTimeout);

      return _handleResponse(response, url);
    } on SocketException {
      throw ApiException(
        ApiError(
          status: 0,
          errorCode: 'NETWORK_ERROR',
          message:
              'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
        ),
      );
    } on http.ClientException {
      throw ApiException(
        ApiError(
          status: 0,
          errorCode: 'CLIENT_ERROR',
          message: 'Có lỗi xảy ra khi gửi yêu cầu.',
        ),
      );
    } catch (e) {
      throw ApiException(
        ApiError(status: 0, errorCode: 'UNKNOWN_ERROR', message: e.toString()),
      );
    }
  }

  Future<Map<String, dynamic>> get({
    required String url,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: headers ?? ApiRoutes.defaultHeaders)
          .timeout(TimeConfig.requestTimeout);

      return _handleResponse(response, url);
    } on SocketException {
      throw ApiException(
        ApiError(
          status: 0,
          errorCode: 'NETWORK_ERROR',
          message:
              'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
        ),
      );
    } on http.ClientException {
      throw ApiException(
        ApiError(
          status: 0,
          errorCode: 'CLIENT_ERROR',
          message: 'Có lỗi xảy ra khi gửi yêu cầu.',
        ),
      );
    } catch (e) {
      throw ApiException(
        ApiError(status: 0, errorCode: 'UNKNOWN_ERROR', message: e.toString()),
      );
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response, String url) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      // Try to parse as ApiError
      try {
        final error = ApiError.fromJson(decoded);

        // Enhance error message based on route and error code
        final enhancedMessage = _getEnhancedErrorMessage(url, error.errorCode);
        final enhancedError = ApiError(
          status: error.status,
          errorCode: error.errorCode,
          message: enhancedMessage,
        );
        throw ApiException(enhancedError);
      } catch (e) {
        // Check if this is our intended ApiException
        if (e is ApiException) {
          rethrow; // Re-throw our ApiException
        }

        // If parsing fails, create a generic error with enhanced message
        final genericErrorCode = 'API_ERROR';
        final enhancedMessage = _getEnhancedErrorMessage(url, genericErrorCode);
        throw ApiException(
          ApiError(
            status: response.statusCode,
            errorCode: genericErrorCode,
            message: enhancedMessage,
          ),
        );
      }
    }
  }

  String _getEnhancedErrorMessage(String url, String errorCode) {
    // Handle generic API errors first
    if (errorCode == 'API_ERROR') {
      if (url.contains('/auth/')) {
        return 'Lỗi xác thực không xác định';
      } else if (url.contains('/students')) {
        return 'Lỗi sinh viên không xác định';
      } else if (url.contains('/periods') ||
          url.contains('/student-tuitions')) {
        return 'Lỗi học phí không xác định';
      } else if (url.contains('/payments') || url.contains('/otp')) {
        return 'Lỗi thanh toán không xác định';
      }
      return 'Lỗi API không xác định';
    }

    // Determine which route this error belongs to and get specific message
    if (url.contains('/auth/')) {
      return AuthRoutes.getErrorMessage(errorCode);
    } else if (url.contains('/students')) {
      return StudentRoutes.getErrorMessage(errorCode);
    } else if (url.contains('/periods') || url.contains('/student-tuitions')) {
      return TuitionRoutes.getErrorMessage(errorCode);
    } else if (url.contains('/payments') || url.contains('/otp')) {
      return PaymentRoutes.getErrorMessage(errorCode);
    }

    // Default message if route not recognized
    return 'Lỗi không xác định: $errorCode';
  }

  void dispose() {
    _client.close();
  }
}
