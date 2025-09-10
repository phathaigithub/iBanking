import 'package:flutter/foundation.dart';
import '../models/tuition_payment_period.dart';
import '../models/student_tuition.dart';
import '../models/student.dart';
import '../services/tuition_management_service.dart';
import '../services/student_service.dart';
import '../utils/config.dart';

class TuitionManagementViewModel extends ChangeNotifier {
  final TuitionManagementService _tuitionService = TuitionManagementService();
  final StudentService _studentService = StudentService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<TuitionPaymentPeriod> _periods = [];
  List<TuitionPaymentPeriod> get periods => _periods;

  List<Student> _students = [];
  List<Student> get students => _students;

  Map<String, double> _studentTuitionAmounts = {};
  Map<String, double> get studentTuitionAmounts => _studentTuitionAmounts;

  // Next period info (editable)
  int? _nextAcademicYear;
  int? _nextSemester;
  DateTime? _nextStartDate;
  DateTime? _nextDueDate;

  int? get nextAcademicYear => _nextAcademicYear;
  int? get nextSemester => _nextSemester;
  DateTime? get nextStartDate => _nextStartDate;
  DateTime? get nextDueDate => _nextDueDate;

  String get nextAcademicYearDisplay => _nextAcademicYear != null
      ? '$_nextAcademicYear-${_nextAcademicYear! + 1}'
      : '';

  // Methods to update period info
  void updateAcademicYear(int year) {
    _nextAcademicYear = year;
    notifyListeners();
  }

  void updateSemester(int semester) {
    _nextSemester = semester;
    notifyListeners();
  }

  void updateStartDate(DateTime date) {
    _nextStartDate = date;
    notifyListeners();
  }

  void updateDueDate(DateTime date) {
    _nextDueDate = date;
    notifyListeners();
  }

  // Get available academic years (current year and next few years)
  List<int> getAvailableAcademicYears() {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - 1 + index);
  }

  Future<void> initialize() async {
    _setLoading(true);
    try {
      _tuitionService.initializeSampleData();
      await _loadData();
      _calculateNextPeriod();
    } catch (e) {
      _setError('Lỗi khởi tạo: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadData() async {
    _periods = _tuitionService.periods;
    _students = _studentService.getAllStudents();

    // Initialize default tuition amounts
    _studentTuitionAmounts.clear();
    for (final student in _students) {
      _studentTuitionAmounts[student.studentId] = AppConfig.defaultTuitionFee;
    }
  }

  void _calculateNextPeriod() {
    final nextInfo = _tuitionService.getNextPeriodInfo();
    _nextAcademicYear = nextInfo['academicYear'];
    _nextSemester = nextInfo['semester'];

    if (_nextAcademicYear != null && _nextSemester != null) {
      final dates = _tuitionService.createSemesterDates(
        _nextAcademicYear!,
        _nextSemester!,
      );
      _nextStartDate = dates['startDate'];
      _nextDueDate = dates['dueDate'];
    }
  }

  void updateStudentTuitionAmount(String studentId, double amount) {
    _studentTuitionAmounts[studentId] = amount;
    notifyListeners();
  }

  Future<bool> createNewTuitionPeriod() async {
    if (_nextAcademicYear == null ||
        _nextSemester == null ||
        _nextStartDate == null ||
        _nextDueDate == null) {
      _setError('Vui lòng điền đầy đủ thông tin kỳ học');
      return false;
    }

    _setLoading(true);
    try {
      final studentTuitions = _students.map((student) {
        return StudentTuitionData(
          studentId: student.studentId,
          amount:
              _studentTuitionAmounts[student.studentId] ??
              AppConfig.defaultTuitionFee,
        );
      }).toList();

      await _tuitionService.createNewPeriodWithCustomDates(
        academicYear: _nextAcademicYear!,
        semester: _nextSemester!,
        startDate: _nextStartDate!,
        dueDate: _nextDueDate!,
        studentTuitions: studentTuitions,
      );

      // Reload data and recalculate next period
      await _loadData();
      _calculateNextPeriod();

      _clearError();
      return true;
    } catch (e) {
      _setError('Lỗi tạo đợt đóng học phí: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<StudentTuition> getStudentTuitionsForPeriod(String periodId) {
    return _tuitionService.getStudentTuitionsForPeriod(periodId);
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
}
