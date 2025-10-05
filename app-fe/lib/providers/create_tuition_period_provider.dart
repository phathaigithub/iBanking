import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/major.dart';
import '../models/api/create_tuition_period_request.dart';
import '../services/api/major_api_service.dart';
import '../services/api/tuition_api_service.dart';
import '../services/api/api_client.dart';

// Provider for ApiClient (reuse from existing)
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for MajorApiService (reuse from existing)
final majorApiServiceProvider = Provider<MajorApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MajorApiService(apiClient: apiClient);
});

// Provider for TuitionApiService (reuse from existing)
final tuitionApiServiceProvider = Provider<TuitionApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TuitionApiService(apiClient: apiClient);
});

// State for Create Tuition Period
class CreateTuitionPeriodState {
  final int academicYear;
  final int selectedSemester;
  final String? selectedMajorCode;
  final DateTime? dueDate;
  final double tuitionAmount;
  final List<Major> majors;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  CreateTuitionPeriodState({
    required this.academicYear,
    this.selectedSemester = 1,
    this.selectedMajorCode,
    this.dueDate,
    this.tuitionAmount = 15000000.0,
    this.majors = const [],
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  CreateTuitionPeriodState copyWith({
    int? academicYear,
    int? selectedSemester,
    String? selectedMajorCode,
    DateTime? dueDate,
    double? tuitionAmount,
    List<Major>? majors,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CreateTuitionPeriodState(
      academicYear: academicYear ?? this.academicYear,
      selectedSemester: selectedSemester ?? this.selectedSemester,
      selectedMajorCode: selectedMajorCode ?? this.selectedMajorCode,
      dueDate: dueDate ?? this.dueDate,
      tuitionAmount: tuitionAmount ?? this.tuitionAmount,
      majors: majors ?? this.majors,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSuccess: clearSuccess ? false : (isSuccess ?? this.isSuccess),
    );
  }

  bool get isValid {
    return selectedMajorCode != null &&
        dueDate != null &&
        dueDate!.isAfter(DateTime.now().add(const Duration(days: 7))) &&
        tuitionAmount > 0;
  }

  String get semesterCode {
    return '$selectedSemester$academicYear';
  }

  String get formattedDueDate {
    if (dueDate == null) return '';
    return '${dueDate!.day.toString().padLeft(2, '0')}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.year}';
  }
}

// Create Tuition Period Notifier
class CreateTuitionPeriodNotifier
    extends StateNotifier<CreateTuitionPeriodState> {
  final MajorApiService _majorApiService;
  final TuitionApiService _tuitionApiService;
  VoidCallback? _onSuccess;

  CreateTuitionPeriodNotifier(this._majorApiService, this._tuitionApiService)
    : super(
        CreateTuitionPeriodState(
          academicYear: DateTime.now().year,
          tuitionAmount: 15000000.0,
        ),
      ) {
    _initializeData();
  }

  void setOnSuccessCallback(VoidCallback? callback) {
    _onSuccess = callback;
  }

  Future<void> _initializeData() async {
    await loadMajors();
  }

  Future<void> loadMajors() async {
    try {
      final majors = await _majorApiService.getAllMajors();
      state = state.copyWith(majors: majors);
    } catch (e) {
      state = state.copyWith(error: 'Không thể tải danh sách ngành học: $e');
    }
  }

  void setSelectedSemester(int semester) {
    state = state.copyWith(selectedSemester: semester);
  }

  void setSelectedMajor(String? majorCode) {
    state = state.copyWith(selectedMajorCode: majorCode);
  }

  void setDueDate(DateTime? dueDate) {
    state = state.copyWith(dueDate: dueDate);
  }

  void setTuitionAmount(double amount) {
    state = state.copyWith(tuitionAmount: amount);
  }

  Future<bool> createTuitionPeriod() async {
    if (!state.isValid) return false;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final request = CreateTuitionPeriodRequest(
        semester: state.semesterCode,
        majorCode: state.selectedMajorCode!,
        amount: state.tuitionAmount,
        dueDate: state.formattedDueDate,
      );

      await _tuitionApiService.createTuitionPeriodByMajor(request);

      state = state.copyWith(isLoading: false, isSuccess: true);

      // Call success callback to switch tabs
      _onSuccess?.call();

      return true;
    } catch (e) {
      String errorMessage = 'Không thể tạo đợt đóng học phí';

      // Parse error message to extract major and semester info
      if (e.toString().contains('BAD_REQUEST') ||
          e.toString().contains('already exists')) {
        final major = state.majors.firstWhere(
          (m) => m.code == state.selectedMajorCode,
          orElse: () => throw Exception('Major not found'),
        );
        errorMessage =
            'Khoa ${major.name} chưa có học viên hoặc đã có học phí ở học kỳ ${state.selectedSemester} năm ${state.academicYear}.';
      } else {
        errorMessage = 'Không thể tạo đợt đóng học phí: $e';
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  void resetForm() {
    state = state.copyWith(
      selectedSemester: 1,
      selectedMajorCode: null,
      dueDate: null,
      tuitionAmount: 15000000.0,
      clearError: true,
      clearSuccess: true,
    );
  }
}

// Create Tuition Period Provider
final createTuitionPeriodProvider =
    StateNotifierProvider<
      CreateTuitionPeriodNotifier,
      CreateTuitionPeriodState
    >((ref) {
      final majorApiService = ref.watch(majorApiServiceProvider);
      final tuitionApiService = ref.watch(tuitionApiServiceProvider);
      return CreateTuitionPeriodNotifier(majorApiService, tuitionApiService);
    });
