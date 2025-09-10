import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/otp.dart';

class OTPService {
  static final OTPService _instance = OTPService._internal();
  factory OTPService() => _instance;
  OTPService._internal();

  final Map<String, OTP> _otpStorage = {};
  final _uuid = const Uuid();

  Future<String> generateOTP(String transactionId) async {
    // Generate 6-digit OTP
    final random = Random();
    final code = (100000 + random.nextInt(900000)).toString();

    final otp = OTP(
      id: _uuid.v4(),
      code: code,
      expiryTime: DateTime.now().add(const Duration(minutes: 5)),
      transactionId: transactionId,
    );

    _otpStorage[transactionId] = otp;

    // TODO: Send OTP via email
    await _sendOTPEmail(code, transactionId);

    return code; // Return for demo purposes - in real app, don't return the code
  }

  Future<bool> verifyOTP(String transactionId, String inputCode) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate verification delay

    final otp = _otpStorage[transactionId];
    if (otp == null) return false;

    if (otp.isValid && otp.code == inputCode) {
      // Mark OTP as used
      _otpStorage[transactionId] = otp.copyWith(isUsed: true);
      return true;
    }

    return false;
  }

  // TODO: Replace with actual email service
  Future<void> _sendOTPEmail(String code, String transactionId) async {
    await Future.delayed(const Duration(seconds: 1));
    print('Email sent with OTP: $code for transaction: $transactionId');
    // In real implementation, use a proper email service
  }

  void clearExpiredOTPs() {
    _otpStorage.removeWhere((key, otp) => otp.isExpired);
  }
}
