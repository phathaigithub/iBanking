import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../routes/payment_routes.dart';
import '../../config/api_routes.dart';
import '../../models/api/payment_request.dart' as payment_request;
import '../../models/api/payment_response.dart' as payment_model;
import '../../models/api/payment_history_response.dart';
import '../../models/api/otp_verification_request.dart';
import 'api_client.dart';

class PaymentApiService {
  final ApiClient _apiClient;

  PaymentApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Payment Management
  Future<PaymentResponse> initiatePayment({
    required String studentId,
    required String tuitionId,
    required double amount,
    required String payerId,
  }) async {
    final response = await _apiClient.post(
      url: PaymentRoutes.initiatePayment,
      body: {
        'studentId': studentId,
        'tuitionId': tuitionId,
        'amount': amount,
        'payerId': payerId,
      },
    );
    return PaymentResponse.fromJson(response['data']);
  }

  Future<bool> confirmPayment({
    required String paymentId,
    required String otpCode,
  }) async {
    try {
      await _apiClient.post(
        url: PaymentRoutes.confirmPayment,
        body: {'paymentId': paymentId, 'otpCode': otpCode},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> cancelPayment(String paymentId) async {
    await _apiClient.post(
      url: PaymentRoutes.getCancelPaymentUrl(paymentId),
      body: {},
    );
  }

  Future<PaymentStatus> getPaymentStatus(String paymentId) async {
    final response = await _apiClient.get(
      url: PaymentRoutes.getPaymentUrl(paymentId),
    );
    return PaymentStatus.fromJson(response['data']);
  }

  Future<List<PaymentHistory>> getPaymentHistoryOld(String userId) async {
    final response = await _apiClient.get(
      url: PaymentRoutes.getPaymentHistory,
      headers: {...ApiRoutes.defaultHeaders, 'userId': userId},
    );
    final List<dynamic> historyJson = response['data'] ?? [];
    return historyJson.map((json) => PaymentHistory.fromJson(json)).toList();
  }

  // OTP Management
  Future<OtpResponse> generateOTP({
    required String paymentId,
    required String phoneNumber,
  }) async {
    final response = await _apiClient.post(
      url: PaymentRoutes.generateOTP,
      body: {'paymentId': paymentId, 'phoneNumber': phoneNumber},
    );
    return OtpResponse.fromJson(response['data']);
  }

  Future<bool> verifyOTP({
    required String paymentId,
    required String otpCode,
  }) async {
    try {
      await _apiClient.post(
        url: PaymentRoutes.verifyOTP,
        body: {'paymentId': paymentId, 'otpCode': otpCode},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> resendOTP(String paymentId) async {
    await _apiClient.post(
      url: PaymentRoutes.resendOTP,
      body: {'paymentId': paymentId},
    );
  }

  // New Payment Methods for User Dashboard
  Future<payment_model.PaymentResponse> createPayment(
    payment_request.PaymentRequest request,
  ) async {
    final response = await _apiClient.post(
      url: '${ApiRoutes.paymentServiceEndpoint}/payments',
      body: request.toJson(),
    );
    return payment_model.PaymentResponse.fromJson(response);
  }

  Future<payment_model.PaymentResponse> verifyOtp({
    required int paymentId,
    required String otpCode,
  }) async {
    final request = OtpVerificationRequest(otpCode: otpCode);
    final response = await _apiClient.post(
      url: '${ApiRoutes.paymentServiceEndpoint}/payments/$paymentId/verify-otp',
      body: request.toJson(),
    );
    return payment_model.PaymentResponse.fromJson(response);
  }

  // Get payment history for a user
  Future<List<PaymentHistoryResponse>> getPaymentHistory(int userId) async {
    try {
      // Try direct HTTP call first since API returns List directly
      return await _getPaymentHistoryDirect(userId);
    } catch (e) {
      // Fallback to ApiClient if direct call fails
      try {
        final response = await _apiClient.get(
          url: '${ApiRoutes.paymentServiceEndpoint}/payments/history/$userId',
        );

        // ApiClient returns Map, extract data field
        final List<dynamic> historyJson =
            response['data'] as List<dynamic>? ?? [];
        return historyJson
            .map(
              (json) =>
                  PaymentHistoryResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } catch (e2) {
        throw Exception('Failed to load payment history: $e');
      }
    }
  }

  Future<List<PaymentHistoryResponse>> _getPaymentHistoryDirect(
    int userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiRoutes.paymentServiceEndpoint}/payments/history/$userId',
        ),
        headers: ApiRoutes.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> historyJson =
            jsonDecode(response.body) as List<dynamic>;
        return historyJson
            .map(
              (json) =>
                  PaymentHistoryResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load payment history: $e');
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}

// Additional models for payment API
class PaymentRequest {
  final String studentId;
  final String tuitionId;
  final double amount;
  final String payerId;

  PaymentRequest({
    required this.studentId,
    required this.tuitionId,
    required this.amount,
    required this.payerId,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'tuitionId': tuitionId,
    'amount': amount,
    'payerId': payerId,
  };
}

class PaymentResponse {
  final String paymentId;
  final String transactionId;
  final String status;
  final DateTime createdAt;

  PaymentResponse({
    required this.paymentId,
    required this.transactionId,
    required this.status,
    required this.createdAt,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      PaymentResponse(
        paymentId: json['paymentId'],
        transactionId: json['transactionId'],
        status: json['status'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class PaymentStatus {
  final String paymentId;
  final String status;
  final String? errorMessage;
  final DateTime? completedAt;

  PaymentStatus({
    required this.paymentId,
    required this.status,
    this.errorMessage,
    this.completedAt,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) => PaymentStatus(
    paymentId: json['paymentId'],
    status: json['status'],
    errorMessage: json['errorMessage'],
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'])
        : null,
  );
}

class PaymentHistory {
  final String paymentId;
  final String studentId;
  final double amount;
  final String status;
  final DateTime createdAt;

  PaymentHistory({
    required this.paymentId,
    required this.studentId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) => PaymentHistory(
    paymentId: json['paymentId'],
    studentId: json['studentId'],
    amount: json['amount'].toDouble(),
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class OtpRequest {
  final String paymentId;
  final String phoneNumber;

  OtpRequest({required this.paymentId, required this.phoneNumber});

  Map<String, dynamic> toJson() => {
    'paymentId': paymentId,
    'phoneNumber': phoneNumber,
  };
}

class OtpResponse {
  final String otpId;
  final DateTime expiresAt;
  final String message;

  OtpResponse({
    required this.otpId,
    required this.expiresAt,
    required this.message,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) => OtpResponse(
    otpId: json['otpId'],
    expiresAt: DateTime.parse(json['expiresAt']),
    message: json['message'],
  );
}
