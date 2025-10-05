/// Payment flow configuration constants
class PaymentConfig {
  /// Countdown duration for tuition card display after search (in seconds)
  static const int tuitionCardDisplayDuration = 90;

  /// Countdown duration for OTP verification (in seconds)
  static const int otpVerificationDuration = 90;

  /// Threshold for "time running out" warning (in seconds)
  static const int timeRunningOutThreshold = 30;

  PaymentConfig._(); // Private constructor to prevent instantiation
}
