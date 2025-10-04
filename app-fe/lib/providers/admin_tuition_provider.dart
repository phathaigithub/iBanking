import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api/tuition_response.dart';
import '../models/major.dart';
import '../services/api/tuition_api_service.dart';
import '../services/api/major_api_service.dart';
import '../services/api/api_client.dart';

// Provider for TuitionApiService
final tuitionApiServiceProvider = Provider<TuitionApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TuitionApiService(apiClient: apiClient);
});

// Provider for MajorApiService (reuse from admin_provider.dart)
final majorApiServiceProvider = Provider<MajorApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MajorApiService(apiClient: apiClient);
});

// Provider for ApiClient (reuse from admin_provider.dart)
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Tuition View Mode
enum TuitionViewMode { all, byMajor }

// State for Admin Tuition Management
class AdminTuitionState {
  final TuitionViewMode viewMode;
  final List<TuitionResponse> tuitions;
  final List<TuitionResponse>
  allTuitions; // Store all tuitions for semester list
  final List<Major> majors;
  final String? selectedSemester;
  final String? selectedMajorCode;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  AdminTuitionState({
    this.viewMode = TuitionViewMode.all,
    this.tuitions = const [],
    this.allTuitions = const [],
    this.majors = const [],
    this.selectedSemester,
    this.selectedMajorCode,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  AdminTuitionState copyWith({
    TuitionViewMode? viewMode,
    List<TuitionResponse>? tuitions,
    List<TuitionResponse>? allTuitions,
    List<Major>? majors,
    String? selectedSemester,
    String? selectedMajorCode,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AdminTuitionState(
      viewMode: viewMode ?? this.viewMode,
      tuitions: tuitions ?? this.tuitions,
      allTuitions: allTuitions ?? this.allTuitions,
      majors: majors ?? this.majors,
      selectedSemester: selectedSemester ?? this.selectedSemester,
      selectedMajorCode: selectedMajorCode ?? this.selectedMajorCode,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  // Filtered tuitions based on search query and semester selection
  List<TuitionResponse> get filteredTuitions {
    List<TuitionResponse> filtered = tuitions;

    // Filter by semester if selected (for "Tất cả" mode)
    if (viewMode == TuitionViewMode.all &&
        selectedSemester != null &&
        selectedSemester != 'Tất cả học kỳ') {
      filtered = filtered.where((tuition) {
        return tuition.semester == selectedSemester;
      }).toList();
    }

    // Filter by search query if provided
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((tuition) {
        return tuition.studentCode.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            tuition.tuitionCode.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Sort data: semester descending, then student code ascending
    filtered.sort((a, b) {
      // First sort by semester (descending)
      final semesterCompare = b.semester.compareTo(a.semester);
      if (semesterCompare != 0) return semesterCompare;

      // If same semester, sort by student code (ascending)
      return a.studentCode.compareTo(b.studentCode);
    });

    return filtered;
  }

  // Available semesters from all tuitions (not just filtered ones)
  List<String> get availableSemesters {
    final semesters = allTuitions.map((t) => t.semester).toSet().toList();
    semesters.sort();
    return semesters;
  }

  // Available semesters for dropdown (includes "All" option only for "Tất cả" mode)
  List<String> get availableSemestersForDropdown {
    final semesters = availableSemesters;
    if (viewMode == TuitionViewMode.all) {
      return ['Tất cả học kỳ', ...semesters];
    }
    return semesters;
  }

  // Available majors from tuitions (if we have student data)
  List<Major> get availableMajorsFromTuitions {
    // This would need student data to map student codes to majors
    // For now, return all majors
    return majors;
  }
}

// Admin Tuition Notifier
class AdminTuitionNotifier extends StateNotifier<AdminTuitionState> {
  final TuitionApiService _tuitionApiService;
  final MajorApiService _majorApiService;

  AdminTuitionNotifier(this._tuitionApiService, this._majorApiService)
    : super(AdminTuitionState()) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await loadMajors();
    // Auto-load tuitions (will set default selections automatically)
    await _loadTuitions();
  }

  void setViewMode(TuitionViewMode mode) {
    state = state.copyWith(viewMode: mode);

    // Handle semester selection when switching modes
    if (mode == TuitionViewMode.all) {
      // Switching to "Tất cả" mode - set to "Tất cả học kỳ" if current selection is not available
      if (state.selectedSemester != null &&
          !state.availableSemestersForDropdown.contains(
            state.selectedSemester,
          )) {
        state = state.copyWith(selectedSemester: 'Tất cả học kỳ');
      }
    } else {
      // Switching to "Xem theo ngành" mode - set to first semester if current selection is "Tất cả học kỳ"
      if (state.selectedSemester == 'Tất cả học kỳ' &&
          state.availableSemesters.isNotEmpty) {
        state = state.copyWith(
          selectedSemester: state.availableSemesters.first,
        );
      }
    }

    _loadTuitions();
  }

  void setSelectedSemester(String? semester) {
    state = state.copyWith(selectedSemester: semester);
    if (state.viewMode == TuitionViewMode.byMajor) {
      _loadTuitions();
    }
  }

  void setSelectedMajor(String? majorCode) {
    state = state.copyWith(selectedMajorCode: majorCode);
    if (state.viewMode == TuitionViewMode.byMajor) {
      _loadTuitions();
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> loadMajors() async {
    try {
      final majors = await _majorApiService.getAllMajors();
      state = state.copyWith(majors: majors);
    } catch (e) {
      state = state.copyWith(
        error: 'Không thể tải danh sách ngành học: ${e.toString()}',
      );
    }
  }

  Future<void> _loadTuitions() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Always load all tuitions to ensure we have complete semester list
      final allTuitions = await _tuitionApiService.getAllTuitions();

      List<TuitionResponse> tuitions;

      if (state.viewMode == TuitionViewMode.all) {
        tuitions = allTuitions;
      } else {
        // For "by major" mode, filter by major and semester
        if (state.selectedMajorCode != null &&
            state.selectedMajorCode!.isNotEmpty) {
          // Use search API for major filtering
          tuitions = await _tuitionApiService.searchTuitions(
            majorCode: state.selectedMajorCode,
            semester: state.selectedSemester,
          );
        } else {
          // If no major selected, show all tuitions
          tuitions = allTuitions;
        }
      }

      state = state.copyWith(
        tuitions: tuitions,
        allTuitions: allTuitions,
        isLoading: false,
      );

      // Set default selections after loading data
      _setDefaultSelections();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể tải danh sách học phí: ${e.toString()}',
      );
    }
  }

  Future<void> refreshTuitions() async {
    await _loadTuitions();
  }

  Future<void> searchTuitions() async {
    await _loadTuitions();
  }

  void clearFilters() {
    state = state.copyWith(
      selectedSemester: null,
      selectedMajorCode: null,
      searchQuery: '',
    );
    _loadTuitions();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Set default selections when data is first loaded
  void _setDefaultSelections() {
    // Auto-select "Tất cả học kỳ" if none selected (for "Tất cả" mode)
    if (state.selectedSemester == null &&
        state.viewMode == TuitionViewMode.all) {
      state = state.copyWith(selectedSemester: 'Tất cả học kỳ');
    }

    // Auto-select first semester if none selected (for "by major" mode)
    if (state.selectedSemester == null &&
        state.viewMode == TuitionViewMode.byMajor &&
        state.availableSemesters.isNotEmpty) {
      state = state.copyWith(selectedSemester: state.availableSemesters.first);
    }

    // Auto-select first major if in "by major" mode and no major selected
    if (state.viewMode == TuitionViewMode.byMajor &&
        state.selectedMajorCode == null &&
        state.majors.isNotEmpty) {
      state = state.copyWith(selectedMajorCode: state.majors.first.code);
    }
  }
}

// Admin Tuition Provider
final adminTuitionProvider =
    StateNotifierProvider<AdminTuitionNotifier, AdminTuitionState>((ref) {
      final tuitionApiService = ref.watch(tuitionApiServiceProvider);
      final majorApiService = ref.watch(majorApiServiceProvider);
      return AdminTuitionNotifier(tuitionApiService, majorApiService);
    });
