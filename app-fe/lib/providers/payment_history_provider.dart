import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api/payment_history_response.dart';
import '../services/api/payment_api_service.dart';
import '../services/api/api_client.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for PaymentApiService
final paymentApiServiceProvider = Provider<PaymentApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentApiService(apiClient: apiClient);
});

// State for Payment History
class PaymentHistoryState {
  final List<PaymentHistoryResponse> history;
  final bool isLoading;
  final String? error;

  PaymentHistoryState({
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  PaymentHistoryState copyWith({
    List<PaymentHistoryResponse>? history,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PaymentHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  // Sorted history by id descending (newest first)
  List<PaymentHistoryResponse> get sortedHistory {
    final sorted = List<PaymentHistoryResponse>.from(history);
    sorted.sort((a, b) => b.id.compareTo(a.id));
    return sorted;
  }
}

// Payment History Notifier
class PaymentHistoryNotifier extends StateNotifier<PaymentHistoryState> {
  final PaymentApiService _paymentApiService;

  PaymentHistoryNotifier(this._paymentApiService)
    : super(PaymentHistoryState());

  Future<void> loadHistory(int userId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final history = await _paymentApiService.getPaymentHistory(userId);
      state = state.copyWith(history: history, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải lịch sử hoạt động: ${e.toString()}',
      );
    }
  }

  Future<void> refresh(int userId) async {
    await loadHistory(userId);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Payment History Provider
final paymentHistoryProvider =
    StateNotifierProvider<PaymentHistoryNotifier, PaymentHistoryState>((ref) {
      final paymentApiService = ref.watch(paymentApiServiceProvider);
      return PaymentHistoryNotifier(paymentApiService);
    });
