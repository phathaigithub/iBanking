import '../config/api_routes.dart';

/// Payment API Routes
/// Contains all payment-related endpoints and their specific error codes
class PaymentRoutes {
  static String get _baseUrl => ApiRoutes.paymentServiceEndpoint;

  // Payment Endpoints
  static String get initiatePayment => '$_baseUrl/payments/initiate';
  static String get confirmPayment => '$_baseUrl/payments/confirm';
  static String get cancelPayment =>
      '$_baseUrl/payments'; // DELETE /payments/{id}
  static String get getPaymentStatus =>
      '$_baseUrl/payments'; // GET /payments/{id}
  static String get getPaymentHistory => '$_baseUrl/payments/history';
  static String get getPaymentByTransactionId =>
      '$_baseUrl/payments/transaction'; // GET /payments/transaction/{transactionId}

  // OTP Endpoints
  static String get generateOTP => '$_baseUrl/otp/generate';
  static String get verifyOTP => '$_baseUrl/otp/verify';
  static String get resendOTP => '$_baseUrl/otp/resend';

  // Payment Error Codes
  static const Map<String, String> errorCodes = {
    'PAYMENT_NOT_FOUND': 'Không tìm thấy giao dịch thanh toán',
    'PAYMENT_ALREADY_PROCESSED': 'Giao dịch đã được xử lý',
    'PAYMENT_CANCELLED': 'Giao dịch đã bị hủy',
    'PAYMENT_EXPIRED': 'Giao dịch đã hết hạn',
    'INSUFFICIENT_BALANCE': 'Số dư không đủ để thực hiện giao dịch',
    'PAYMENT_AMOUNT_INVALID': 'Số tiền thanh toán không hợp lệ',
    'PAYMENT_METHOD_NOT_SUPPORTED': 'Phương thức thanh toán không được hỗ trợ',
    'PAYMENT_GATEWAY_ERROR': 'Lỗi cổng thanh toán',
    'PAYMENT_TIMEOUT': 'Giao dịch quá thời gian chờ',
    'OTP_INVALID': 'Mã OTP không hợp lệ',
    'OTP_EXPIRED': 'Mã OTP đã hết hạn',
    'OTP_ALREADY_USED': 'Mã OTP đã được sử dụng',
    'OTP_LIMIT_EXCEEDED': 'Đã vượt quá số lần nhập OTP cho phép',
    'OTP_GENERATION_FAILED': 'Không thể tạo mã OTP',
    'OTP_SEND_FAILED': 'Không thể gửi mã OTP',
    'TRANSACTION_LOCKED': 'Giao dịch đang được xử lý',
    'ACCOUNT_LOCKED': 'Tài khoản đã bị khóa do giao dịch',
    'DAILY_LIMIT_EXCEEDED': 'Đã vượt quá giới hạn giao dịch hàng ngày',
    'MONTHLY_LIMIT_EXCEEDED': 'Đã vượt quá giới hạn giao dịch hàng tháng',
  };

  // Helper method to get error message by code
  static String getErrorMessage(String errorCode) {
    return errorCodes[errorCode] ?? 'Lỗi thanh toán không xác định';
  }

  // Helper method to build payment-specific URLs
  static String getPaymentUrl(String paymentId) =>
      '$_baseUrl/payments/$paymentId';
  static String getPaymentByTransactionUrl(String transactionId) =>
      '$_baseUrl/payments/transaction/$transactionId';
  static String getCancelPaymentUrl(String paymentId) =>
      '$_baseUrl/payments/$paymentId';
}
