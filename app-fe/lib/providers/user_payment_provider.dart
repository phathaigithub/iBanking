import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api/tuition_response.dart';
import '../models/api/payment_request.dart' as payment_request;
import '../models/api/payment_response.dart' as payment_model;
import '../services/api/tuition_api_service.dart';
import '../services/api/payment_api_service.dart';
import '../services/api/api_client.dart';
import '../providers/auth_provider.dart';
import '../config/time_config.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for TuitionApiService
final tuitionApiServiceProvider = Provider<TuitionApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TuitionApiService(apiClient: apiClient);
});

// Provider for PaymentApiService
final paymentApiServiceProvider = Provider<PaymentApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentApiService(apiClient: apiClient);
});

// Payment Flow Steps
enum PaymentStep { search, confirmation, otpVerification, success, failed }

// State for User Payment
class UserPaymentState {
  final PaymentStep currentStep;
  final String tuitionCode;
  final TuitionResponse? tuition;
  final payment_model.PaymentResponse? payment;
  final int remainingSeconds;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final int otpAttempts;

  UserPaymentState({
    this.currentStep = PaymentStep.search,
    this.tuitionCode = '',
    this.tuition,
    this.payment,
    this.remainingSeconds = 0,
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.otpAttempts = 0,
  });

  UserPaymentState copyWith({
    PaymentStep? currentStep,
    String? tuitionCode,
    TuitionResponse? tuition,
    payment_model.PaymentResponse? payment,
    int? remainingSeconds,
    bool? isLoading,
    String? error,
    String? successMessage,
    int? otpAttempts,
    bool clearError = false,
    bool clearTuition = false,
    bool clearPayment = false,
    bool clearOtpAttempts = false,
  }) {
    return UserPaymentState(
      currentStep: currentStep ?? this.currentStep,
      tuitionCode: tuitionCode ?? this.tuitionCode,
      tuition: clearTuition ? null : (tuition ?? this.tuition),
      payment: clearPayment ? null : (payment ?? this.payment),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: successMessage ?? this.successMessage,
      otpAttempts: clearOtpAttempts ? 0 : (otpAttempts ?? this.otpAttempts),
    );
  }

  bool get hasActiveTuition => tuition != null && remainingSeconds > 0;
  bool get canProceedToPayment =>
      hasActiveTuition && tuition!.isUnpaid && !isLoading;
}

// User Payment Notifier
class UserPaymentNotifier extends StateNotifier<UserPaymentState> {
  final TuitionApiService _tuitionApiService;
  final PaymentApiService _paymentApiService;
  final Ref _ref;
  Timer? _countdownTimer;

  UserPaymentNotifier(
    this._tuitionApiService,
    this._paymentApiService,
    this._ref,
  ) : super(UserPaymentState());

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void setTuitionCode(String code) {
    state = state.copyWith(tuitionCode: code);
  }

  Future<void> searchTuition() async {
    if (state.tuitionCode.isEmpty) {
      state = state.copyWith(
        error: 'Vui lòng nhập mã học phí',
        clearError: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final tuition = await _tuitionApiService.getTuitionByCode(
        state.tuitionCode,
      );

      // Check if tuition is already paid
      if (!tuition.isUnpaid) {
        state = state.copyWith(
          isLoading: false,
          error: 'Mã học phí này đã được thanh toán',
          clearTuition: true,
        );
        return;
      }

      // Start countdown using config
      state = state.copyWith(
        tuition: tuition,
        remainingSeconds: TimeConfig.tuitionCardDisplayDuration,
        isLoading: false,
      );

      _startCountdown();
    } catch (e) {
      String errorMessage = 'Mã học phí không tồn tại hoặc đã hết hạn';

      if (e.toString().contains('404') || e.toString().contains('NOT_FOUND')) {
        errorMessage = 'Mã học phí không tồn tại hoặc đã hết hạn';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        clearTuition: true,
      );
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        // Timeout - clear tuition data
        state = state.copyWith(clearTuition: true, remainingSeconds: 0);
      }
    });
  }

  void _startOtpCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        // OTP timeout - go to failed page
        state = state.copyWith(
          currentStep: PaymentStep.failed,
          error: 'Giao dịch thất bại do quá thời hạn',
          remainingSeconds: 0,
        );
      }
    });
  }

  Future<void> initiatePayment() async {
    if (!state.canProceedToPayment) return;

    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(error: 'Không tìm thấy thông tin người dùng');
      return;
    }

    // Check balance
    if (user.balance < state.tuition!.amount) {
      state = state.copyWith(
        error:
            'Số dư không đủ để thanh toán. Vui lòng nạp thêm ${state.tuition!.amount - user.balance} VNĐ',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final request = payment_request.PaymentRequest(
        userId: user.id,
        tuitionCode: state.tuition!.tuitionCode,
        amount: state.tuition!.amount,
      );

      final paymentResponse = await _paymentApiService.createPayment(request);

      // Calculate remaining seconds until OTP expiry
      final otpExpiry = paymentResponse.otpExpiry;
      final now = DateTime.now();
      final remainingSeconds = otpExpiry.difference(now).inSeconds;

      // Clear tuition code before navigating to OTP page
      state = state.copyWith(
        tuitionCode: '',
        payment: paymentResponse,
        currentStep: PaymentStep.otpVerification,
        remainingSeconds: remainingSeconds > 0
            ? remainingSeconds
            : TimeConfig.otpVerificationDuration,
        isLoading: false,
        clearOtpAttempts: true, // Reset OTP attempts for new payment
      );

      _startOtpCountdown();
    } catch (e) {
      String errorMessage =
          'Có giao dịch khác đang diễn ra trên sinh viên này. Vui lòng thử lại trong giây lát';

      if (e.toString().contains('PAYMENT_IN_PROGRESS') ||
          e.toString().contains('ALREADY_PROCESSING')) {
        errorMessage =
            'Có giao dịch khác đang diễn ra trên sinh viên này. Vui lòng thử lại trong giây lát';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> verifyOtp(String otpCode) async {
    if (state.payment == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final verifiedPayment = await _paymentApiService.verifyOtp(
        paymentId: state.payment!.id,
        otpCode: otpCode,
      );

      _countdownTimer?.cancel();

      // Update user balance after successful payment
      final user = _ref.read(currentUserProvider);
      if (user != null && state.tuition != null) {
        final newBalance = user.balance - state.tuition!.amount;
        _ref.read(authProvider.notifier).updateUserBalance(newBalance);
      }

      state = state.copyWith(
        payment: verifiedPayment,
        currentStep: PaymentStep.success,
        successMessage: 'Thanh toán thành công!',
        isLoading: false,
        remainingSeconds: 0,
      );
    } catch (e) {
      // Increment OTP attempts
      final newAttempts = state.otpAttempts + 1;

      // Check if exceeded maximum attempts (3)
      if (newAttempts >= 3) {
        _countdownTimer?.cancel();
        state = state.copyWith(
          currentStep: PaymentStep.failed,
          error: 'Không thể xác minh giao dịch',
          isLoading: false,
          remainingSeconds: 0,
          otpAttempts: newAttempts,
        );
        return;
      }

      String errorMessage = 'Xác thực OTP thất bại';

      if (e.toString().contains('PAYMENT_ALREADY_SUCCESS')) {
        errorMessage = 'Giao dịch đã được thanh toán';
      } else if (e.toString().contains('OTP_EXPIRED')) {
        errorMessage = 'Mã OTP không tìm thấy hoặc đã hết hạn';
      } else if (e.toString().contains('OTP_INVALID')) {
        errorMessage = 'Mã OTP không hợp lệ';
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
    state = UserPaymentState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void backToSearch() {
    _countdownTimer?.cancel();
    state = UserPaymentState();
  }
}

// User Payment Provider
final userPaymentProvider =
    StateNotifierProvider<UserPaymentNotifier, UserPaymentState>((ref) {
      final tuitionApiService = ref.watch(tuitionApiServiceProvider);
      final paymentApiService = ref.watch(paymentApiServiceProvider);
      return UserPaymentNotifier(tuitionApiService, paymentApiService, ref);
    });
