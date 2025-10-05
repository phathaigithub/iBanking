/// Configuration constants for tuition inquiry flow
class TuitionInquiryConfig {
  /// Countdown duration for OTP dialog (in seconds)
  static const int otpDialogDuration = 75;

  /// Countdown duration for inquiry result display (in seconds)
  static const int resultDisplayDuration = 120;

  /// Maximum OTP attempts allowed
  static const int maxOtpAttempts = 3;

  TuitionInquiryConfig._(); // Private constructor to prevent instantiation
}
