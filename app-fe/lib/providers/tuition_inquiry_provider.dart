import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api/tuition_inquiry_response.dart';
import '../services/api/tuition_api_service.dart';
import '../services/api/api_client.dart';
import '../utils/tuition_inquiry_config.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for TuitionApiService
final tuitionApiServiceProvider = Provider<TuitionApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TuitionApiService(apiClient: apiClient);
});

// Tuition Inquiry Flow Steps
enum InquiryStep { search, otpVerification, result }

// State for Tuition Inquiry
class TuitionInquiryState {
  final InquiryStep currentStep;
  final String studentCode;
  final TuitionInquiryResponse? inquiryResult;
  final int remainingSeconds;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final int otpAttempts;

  TuitionInquiryState({
    this.currentStep = InquiryStep.search,
    this.studentCode = '',
    this.inquiryResult,
    this.remainingSeconds = 0,
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.otpAttempts = 0,
  });

  TuitionInquiryState copyWith({
    InquiryStep? currentStep,
    String? studentCode,
    TuitionInquiryResponse? inquiryResult,
    int? remainingSeconds,
    bool? isLoading,
    String? error,
    String? successMessage,
    int? otpAttempts,
    bool clearError = false,
    bool clearInquiryResult = false,
    bool clearOtpAttempts = false,
  }) {
    return TuitionInquiryState(
      currentStep: currentStep ?? this.currentStep,
      studentCode: studentCode ?? this.studentCode,
      inquiryResult: clearInquiryResult
          ? null
          : (inquiryResult ?? this.inquiryResult),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: successMessage ?? this.successMessage,
      otpAttempts: clearOtpAttempts ? 0 : (otpAttempts ?? this.otpAttempts),
    );
  }

  bool get hasActiveOtpDialog =>
      currentStep == InquiryStep.otpVerification && remainingSeconds > 0;
  bool get hasActiveResult =>
      currentStep == InquiryStep.result && remainingSeconds > 0;
}

// Tuition Inquiry Notifier
class TuitionInquiryNotifier extends StateNotifier<TuitionInquiryState> {
  final TuitionApiService _tuitionApiService;
  Timer? _countdownTimer;

  TuitionInquiryNotifier(this._tuitionApiService)
    : super(TuitionInquiryState());

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void setStudentCode(String code) {
    state = state.copyWith(studentCode: code);
  }

  Future<void> requestInquiry() async {
    if (state.studentCode.isEmpty) {
      state = state.copyWith(
        error: 'Vui lòng nhập mã số sinh viên',
        clearError: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final message = await _tuitionApiService.requestTuitionInquiryOtp(
        state.studentCode,
      );

      // Start OTP verification step with countdown
      state = state.copyWith(
        currentStep: InquiryStep.otpVerification,
        remainingSeconds: TuitionInquiryConfig.otpDialogDuration,
        isLoading: false,
        successMessage: message,
        clearOtpAttempts: true, // Reset OTP attempts
      );

      _startOtpCountdown();
    } catch (e) {
      String errorMessage = 'Không tìm thấy sinh viên';

      if (e.toString().contains('STUDENT_NOT_FOUND')) {
        errorMessage = 'Không tìm thấy sinh viên với mã số này';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  void _startOtpCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        // Timeout - close OTP dialog
        if (state.currentStep == InquiryStep.otpVerification) {
          reset();
        }
      }
    });
  }

  void _startResultCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        // Timeout - clear result
        reset();
      }
    });
  }

  Future<void> verifyOtp(String otpCode) async {
    if (otpCode.length != 6) {
      state = state.copyWith(error: 'Mã OTP phải có 6 ký tự');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _tuitionApiService.verifyTuitionInquiryOtp(
        studentCode: state.studentCode,
        otpCode: otpCode,
      );

      _countdownTimer?.cancel();

      // Show result with countdown
      state = state.copyWith(
        currentStep: InquiryStep.result,
        inquiryResult: result,
        remainingSeconds: TuitionInquiryConfig.resultDisplayDuration,
        isLoading: false,
      );

      _startResultCountdown();
    } catch (e) {
      // Increment OTP attempts
      final newAttempts = state.otpAttempts + 1;

      // Check if exceeded maximum attempts
      if (newAttempts >= TuitionInquiryConfig.maxOtpAttempts) {
        _countdownTimer?.cancel();
        state = state.copyWith(
          error: 'Đã nhập sai OTP quá số lần cho phép',
          isLoading: false,
          otpAttempts: newAttempts,
          remainingSeconds: 0, // Set timer to 0 to trigger auto-close
        );
        return;
      }

      String errorMessage = 'Xác thực OTP thất bại';

      if (e.toString().contains('INVALID_OTP')) {
        errorMessage = 'Mã OTP không hợp lệ hoặc đã hết hạn';
      } else if (e.toString().contains('STUDENT_NOT_FOUND')) {
        errorMessage = 'Không tìm thấy sinh viên';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        otpAttempts: newAttempts,
      );
    }
  }

  void reset() {
    _countdownTimer?.cancel();
    state = TuitionInquiryState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void backToSearch() {
    _countdownTimer?.cancel();
    state = TuitionInquiryState();
  }
}

// Tuition Inquiry Provider
final tuitionInquiryProvider =
    StateNotifierProvider<TuitionInquiryNotifier, TuitionInquiryState>((ref) {
      final tuitionApiService = ref.watch(tuitionApiServiceProvider);
      return TuitionInquiryNotifier(tuitionApiService);
    });
