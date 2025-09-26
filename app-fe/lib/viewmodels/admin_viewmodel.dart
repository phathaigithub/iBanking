import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/student_tuition.dart';
import '../services/student_service.dart';
import '../services/tuition_management_service.dart';

class AdminViewModel extends ChangeNotifier {
  final StudentService _studentService = StudentService();
  final TuitionManagementService _tuitionService = TuitionManagementService();

  List<Student> _students = [];
  List<Student> get students => _students;

  List<StudentTuition> _studentTuitions = [];
  List<StudentTuition> get studentTuitions => _studentTuitions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _selectedPeriodId;
  String? get selectedPeriodId => _selectedPeriodId;

  Future<void> loadStudents() async {
    _setLoading(true);
    _clearError();

    try {
      _students = _studentService.getAllStudents();
      _studentTuitions = _tuitionService.getAllStudentTuitions();
    } catch (e) {
      _setError('Đã xảy ra lỗi khi tải danh sách sinh viên: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh all data (students, periods, tuitions)
  Future<void> refreshData() async {
    await loadStudents();
    // Auto-select the newest period if none selected
    if (_selectedPeriodId == null && availablePeriods.isNotEmpty) {
      _selectedPeriodId = availablePeriods.first;
      notifyListeners();
    }
  }

  StudentTuition? getLatestTuitionForStudent(String studentId) {
    if (_selectedPeriodId != null) {
      // Get tuition for specific period
      final filteredTuitions = _getFilteredStudentTuitions();
      final studentTuitions = filteredTuitions
          .where((st) => st.studentId == studentId)
          .toList();

      if (studentTuitions.isNotEmpty) {
        return studentTuitions.first;
      }
    }

    // Get latest tuition across all periods
    final studentTuitions = _studentTuitions
        .where((st) => st.studentId == studentId)
        .toList();

    if (studentTuitions.isEmpty) return null;

    // Sort by academic year and semester to get the latest
    studentTuitions.sort((a, b) {
      final periodA = _tuitionService.getTuitionPeriod(a.periodId);
      final periodB = _tuitionService.getTuitionPeriod(b.periodId);

      if (periodA == null || periodB == null) return 0;

      if (periodA.academicYear != periodB.academicYear) {
        return periodB.academicYear.compareTo(periodA.academicYear);
      }
      return periodB.semester.compareTo(periodA.semester);
    });

    return studentTuitions.first;
  }

  bool hasUnpaidTuition(String studentId) {
    if (_selectedPeriodId != null) {
      // Check for specific period
      final tuition = _getFilteredStudentTuitions()
          .where((st) => st.studentId == studentId)
          .firstOrNull;

      if (tuition == null) return false;

      final period = _tuitionService.getTuitionPeriod(tuition.periodId);
      if (period == null) return false;

      return !tuition.isPaid && tuition.isActiveForPeriod(period);
    }

    // Check latest tuition across all periods
    final latest = getLatestTuitionForStudent(studentId);
    if (latest == null) return false;

    final period = _tuitionService.getTuitionPeriod(latest.periodId);
    if (period == null) return false;

    return !latest.isPaid && latest.isActiveForPeriod(period);
  }

  // Check if student has any tuition fees at all
  bool hasAnyTuition(String studentId) {
    return _studentTuitions.any((st) => st.studentId == studentId);
  }

  // Get tuition status for display
  String getTuitionStatus(String studentId) {
    if (!hasAnyTuition(studentId)) {
      return 'Chưa có học phí';
    }
    return hasUnpaidTuition(studentId) ? 'Chưa thanh toán' : 'Đã thanh toán';
  }

  // Get status color for display
  Color? getTuitionStatusColor(String studentId) {
    if (!hasAnyTuition(studentId)) {
      return Colors.grey[700];
    }
    return hasUnpaidTuition(studentId) ? Colors.orange[700] : Colors.green[700];
  }

  int get totalStudents => _students.length;

  int get paidStudents =>
      _students.where((s) => hasAnyTuition(s.studentId) && !hasUnpaidTuition(s.studentId)).length;

  int get unpaidStudents =>
      _students.where((s) => hasAnyTuition(s.studentId) && hasUnpaidTuition(s.studentId)).length;

  int get studentsWithoutTuition =>
      _students.where((s) => !hasAnyTuition(s.studentId)).length;

  double get totalRevenue => _getFilteredStudentTuitions()
      .where((st) => st.isPaid)
      .fold(0.0, (sum, st) => sum + st.amount);

  // Create a new student
  Future<bool> createStudent({
    required String studentId,
    required String password,
    required String fullName,
    required String email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Check if student ID already exists
      final existingStudent = _studentService.getStudentById(studentId);
      if (existingStudent != null) {
        _setError('Mã số sinh viên đã tồn tại');
        return false;
      }

      // Create the student
      final success = await _studentService.createStudent(
        studentId: studentId,
        password: password,
        fullName: fullName,
        email: email,
      );

      if (success) {
        // Reload students list
        await loadStudents();
        return true;
      } else {
        _setError('Không thể tạo sinh viên');
        return false;
      }
    } catch (e) {
      _setError('Đã xảy ra lỗi khi tạo sinh viên: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Get available periods sorted by academic year and semester (newest first)
  List<String> get availablePeriods {
    final periods = _tuitionService.periods.toList();
    periods.sort((a, b) {
      if (a.academicYear != b.academicYear) {
        return b.academicYear.compareTo(a.academicYear);
      }
      return b.semester.compareTo(a.semester);
    });
    return periods.map((p) => p.id).toList();
  }

  // Get period display name
  String getPeriodDisplayName(String periodId) {
    final period = _tuitionService.getTuitionPeriod(periodId);
    if (period == null) return 'Không xác định';
    return 'Học kỳ ${period.semester} - ${period.academicYearDisplay}';
  }

  // Select a specific period for viewing
  void selectPeriod(String? periodId) {
    _selectedPeriodId = periodId;
    notifyListeners();
  }

  // Get student tuitions filtered by selected period
  List<StudentTuition> _getFilteredStudentTuitions() {
    if (_selectedPeriodId == null) return _studentTuitions;
    return _studentTuitions
        .where((st) => st.periodId == _selectedPeriodId)
        .toList();
  }
}
