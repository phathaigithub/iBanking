import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/major.dart';
import '../models/student_detail.dart';
import '../services/api/major_api_service.dart';
import '../services/api/student_api_service.dart';
import '../services/api/api_client.dart';

// Provider for MajorApiService
final majorApiServiceProvider = Provider<MajorApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MajorApiService(apiClient: apiClient);
});

// Provider for StudentApiService (reuse from existing if available)
final studentApiServiceProvider = Provider<StudentApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StudentApiService(apiClient: apiClient);
});

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// State for Admin Dashboard
enum AdminViewTab { majorsAndStudents, tuition, createTuitionPeriod }

enum MajorStudentTab { majors, students }

class AdminDashboardState {
  final AdminViewTab currentTab;
  final MajorStudentTab majorStudentTab;
  final List<Major> majors;
  final List<StudentDetail> students;
  final bool isLoadingMajors;
  final bool isLoadingStudents;
  final String? errorMajors;
  final String? errorStudents;

  AdminDashboardState({
    this.currentTab = AdminViewTab.majorsAndStudents,
    this.majorStudentTab = MajorStudentTab.majors,
    this.majors = const [],
    this.students = const [],
    this.isLoadingMajors = false,
    this.isLoadingStudents = false,
    this.errorMajors,
    this.errorStudents,
  });

  AdminDashboardState copyWith({
    AdminViewTab? currentTab,
    MajorStudentTab? majorStudentTab,
    List<Major>? majors,
    List<StudentDetail>? students,
    bool? isLoadingMajors,
    bool? isLoadingStudents,
    String? errorMajors,
    String? errorStudents,
    bool clearErrorMajors = false,
    bool clearErrorStudents = false,
  }) {
    return AdminDashboardState(
      currentTab: currentTab ?? this.currentTab,
      majorStudentTab: majorStudentTab ?? this.majorStudentTab,
      majors: majors ?? this.majors,
      students: students ?? this.students,
      isLoadingMajors: isLoadingMajors ?? this.isLoadingMajors,
      isLoadingStudents: isLoadingStudents ?? this.isLoadingStudents,
      errorMajors: clearErrorMajors ? null : (errorMajors ?? this.errorMajors),
      errorStudents: clearErrorStudents
          ? null
          : (errorStudents ?? this.errorStudents),
    );
  }

  // Group students by major
  Map<String, List<StudentDetail>> get studentsByMajor {
    final Map<String, List<StudentDetail>> grouped = {};
    for (final student in students) {
      if (!grouped.containsKey(student.majorCode)) {
        grouped[student.majorCode] = [];
      }
      grouped[student.majorCode]!.add(student);
    }
    return grouped;
  }
}

// Admin Dashboard Notifier
class AdminDashboardNotifier extends StateNotifier<AdminDashboardState> {
  final MajorApiService _majorApiService;
  final StudentApiService _studentApiService;

  AdminDashboardNotifier(this._majorApiService, this._studentApiService)
    : super(AdminDashboardState());

  void setTab(AdminViewTab tab) {
    state = state.copyWith(currentTab: tab);
  }

  void setMajorStudentTab(MajorStudentTab tab) {
    state = state.copyWith(majorStudentTab: tab);

    // Load data when switching tabs
    if (tab == MajorStudentTab.majors && state.majors.isEmpty) {
      loadMajors();
    } else if (tab == MajorStudentTab.students && state.students.isEmpty) {
      loadStudents();
    }
  }

  Future<void> loadMajors() async {
    state = state.copyWith(isLoadingMajors: true, clearErrorMajors: true);
    try {
      final majors = await _majorApiService.getAllMajors();
      state = state.copyWith(majors: majors, isLoadingMajors: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingMajors: false,
        errorMajors: 'Không thể tải danh sách ngành học: ${e.toString()}',
      );
    }
  }

  Future<void> loadStudents() async {
    state = state.copyWith(isLoadingStudents: true, clearErrorStudents: true);
    try {
      final students = await _studentApiService.getAllStudentDetails();
      state = state.copyWith(students: students, isLoadingStudents: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingStudents: false,
        errorStudents: 'Không thể tải danh sách sinh viên: ${e.toString()}',
      );
    }
  }

  Future<void> searchStudents(String query) async {
    if (query.trim().isEmpty) {
      // If query is empty, reload all students
      await loadStudents();
      return;
    }

    state = state.copyWith(isLoadingStudents: true, clearErrorStudents: true);
    try {
      final students = await _studentApiService.searchStudentDetails(query);
      state = state.copyWith(students: students, isLoadingStudents: false);
    } catch (e) {
      state = state.copyWith(
        isLoadingStudents: false,
        errorStudents: 'Không thể tìm kiếm sinh viên: ${e.toString()}',
      );
    }
  }

  void clearErrorMajors() {
    state = state.copyWith(clearErrorMajors: true);
  }

  void clearErrorStudents() {
    state = state.copyWith(clearErrorStudents: true);
  }
}

// Admin Dashboard Provider
final adminDashboardProvider =
    StateNotifierProvider<AdminDashboardNotifier, AdminDashboardState>((ref) {
      final majorApiService = ref.watch(majorApiServiceProvider);
      final studentApiService = ref.watch(studentApiServiceProvider);
      return AdminDashboardNotifier(majorApiService, studentApiService);
    });
