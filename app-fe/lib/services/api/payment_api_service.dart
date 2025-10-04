import '../../routes/payment_routes.dart';
import '../../config/api_routes.dart';
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

  Future<List<PaymentHistory>> getPaymentHistory(String userId) async {
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
