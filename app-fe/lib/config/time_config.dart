/// Time and timeout configuration constants for the app
class TimeConfig {
  /// Countdown duration for tuition card display after search (in seconds)
  static const int tuitionCardDisplayDuration = 120;

  /// Countdown duration for OTP verification (in seconds)
  static const int otpVerificationDuration = 60;

  /// Threshold for "time running out" warning (in seconds)
  static const int timeRunningOutThreshold = 30;

  /// Countdown duration for payment confirmation dialog (in seconds)
  static const int paymentConfirmationDialogDuration = 30;

  /// Default network request timeout
  static const Duration requestTimeout = Duration(seconds: 30);

  TimeConfig._();
}
