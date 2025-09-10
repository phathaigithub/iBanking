import 'package:uuid/uuid.dart';
import '../models/tuition_payment_period.dart';
import '../models/student_tuition.dart';
import '../utils/config.dart';

class TuitionManagementService {
  static final TuitionManagementService _instance =
      TuitionManagementService._internal();
  factory TuitionManagementService() => _instance;
  TuitionManagementService._internal();

  final _uuid = const Uuid();

  // Static data for demo - TODO: Replace with backend database
  final List<TuitionPaymentPeriod> _periods = [];
  final List<StudentTuition> _studentTuitions = [];

  List<TuitionPaymentPeriod> get periods => List.unmodifiable(_periods);
  List<StudentTuition> get studentTuitions =>
      List.unmodifiable(_studentTuitions);

  /// Initialize with some sample data
  void initializeSampleData() {
    if (_periods.isEmpty) {
      // Create some historical periods
      final period1 = TuitionPaymentPeriod(
        id: 'period_2024_1',
        academicYear: 2024,
        semester: 1,
        startDate: DateTime(2024, 9, 1),
        dueDate: DateTime(2024, 9, 15),
        createdAt: DateTime(2024, 8, 15),
      );

      final period2 = TuitionPaymentPeriod(
        id: 'period_2024_2',
        academicYear: 2024,
        semester: 2,
        startDate: DateTime(2025, 2, 1),
        dueDate: DateTime(2025, 2, 15),
        createdAt: DateTime(2025, 1, 15),
      );

      _periods.addAll([period1, period2]);

      // Create sample student tuitions
      _createSampleStudentTuitions();
    }
  }

  void _createSampleStudentTuitions() {
    final studentIds = [
      '52200001',
      '52200002',
      '52200003',
      '52200004',
      '52200005',
    ];

    for (final period in _periods) {
      for (final studentId in studentIds) {
        final tuition = StudentTuition(
          id: '${period.id}_$studentId',
          studentId: studentId,
          periodId: period.id,
          amount: AppConfig.defaultTuitionFee,
          isPaid: period.id == 'period_2024_1', // Mark first period as paid
          paidDate: period.id == 'period_2024_1' ? DateTime(2024, 9, 10) : null,
        );
        _studentTuitions.add(tuition);
      }
    }
  }

  /// Get the next academic year and semester based on current date
  Map<String, int> getNextPeriodInfo() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Find the latest period
    TuitionPaymentPeriod? latestPeriod;
    if (_periods.isNotEmpty) {
      _periods.sort((a, b) {
        final yearCompare = a.academicYear.compareTo(b.academicYear);
        if (yearCompare != 0) return yearCompare;
        return a.semester.compareTo(b.semester);
      });
      latestPeriod = _periods.last;
    }

    int nextAcademicYear;
    int nextSemester;

    if (latestPeriod == null) {
      // No previous periods, determine based on current date
      if (currentMonth >= AppConfig.newYearMonth) {
        nextAcademicYear = currentYear;
        nextSemester = 1;
      } else {
        nextAcademicYear = currentYear - 1;
        nextSemester = currentMonth <= 2 ? 2 : 3;
      }
    } else {
      // Determine next period based on latest period
      if (currentMonth >= AppConfig.newYearMonth &&
          latestPeriod.academicYear < currentYear) {
        // New academic year
        nextAcademicYear = currentYear;
        nextSemester = 1;
      } else if (latestPeriod.semester < 3) {
        // Same academic year, next semester
        nextAcademicYear = latestPeriod.academicYear;
        nextSemester = latestPeriod.semester + 1;
      } else {
        // Next academic year, first semester
        nextAcademicYear = latestPeriod.academicYear + 1;
        nextSemester = 1;
      }
    }

    return {'academicYear': nextAcademicYear, 'semester': nextSemester};
  }

  /// Create dates for a semester
  Map<String, DateTime> createSemesterDates(int academicYear, int semester) {
    final config = AppConfig.semesterDueDates[semester]!;
    final baseYear = academicYear + config.yearOffset;

    return {
      'startDate': DateTime(baseYear, config.startMonth, config.startDay),
      'dueDate': DateTime(baseYear, config.endMonth, config.endDay),
    };
  }

  /// Create a new tuition payment period
  Future<TuitionPaymentPeriod> createNewPeriod({
    required int academicYear,
    required int semester,
    required List<StudentTuitionData> studentTuitions,
  }) async {
    // TODO: Add validation to prevent duplicate periods

    final dates = createSemesterDates(academicYear, semester);
    final period = TuitionPaymentPeriod(
      id: _uuid.v4(),
      academicYear: academicYear,
      semester: semester,
      startDate: dates['startDate']!,
      dueDate: dates['dueDate']!,
      createdAt: DateTime.now(),
    );

    _periods.add(period);

    // Create student tuitions for this period
    for (final studentData in studentTuitions) {
      final tuition = StudentTuition(
        id: _uuid.v4(),
        studentId: studentData.studentId,
        periodId: period.id,
        amount: studentData.amount,
      );
      _studentTuitions.add(tuition);
    }

    // TODO: Save to backend database
    return period;
  }

  /// Create a new tuition payment period with custom dates
  Future<TuitionPaymentPeriod> createNewPeriodWithCustomDates({
    required int academicYear,
    required int semester,
    required DateTime startDate,
    required DateTime dueDate,
    required List<StudentTuitionData> studentTuitions,
  }) async {
    // TODO: Add validation to prevent duplicate periods

    final period = TuitionPaymentPeriod(
      // id: _uuid.v4(),
      id: 'period_${semester}_$academicYear',
      academicYear: academicYear,
      semester: semester,
      startDate: startDate,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );

    _periods.add(period);

    // Create student tuitions for this period
    for (final studentData in studentTuitions) {
      final tuition = StudentTuition(
        id: _uuid.v4(),
        studentId: studentData.studentId,
        periodId: period.id,
        amount: studentData.amount,
      );
      _studentTuitions.add(tuition);
    }

    // TODO: Save to backend database
    return period;
  }

  /// Get student tuitions for a specific period
  List<StudentTuition> getStudentTuitionsForPeriod(String periodId) {
    return _studentTuitions.where((t) => t.periodId == periodId).toList();
  }

  /// Get student tuitions for a specific student
  List<StudentTuition> getStudentTuitionsForStudent(String studentId) {
    return _studentTuitions.where((t) => t.studentId == studentId).toList();
  }

  /// Get current unpaid tuition for a student
  StudentTuition? getCurrentUnpaidTuition(String studentId) {
    final tuitions = getStudentTuitionsForStudent(studentId);
    // TODO: Delete this at production
    print(
      'Tuition for student: ${tuitions.map((t) => '${t.amount}->${t.periodId}->${t.isPaid}').toList()}',
    );
    for (final tuition in tuitions) {
      if (!tuition.isPaid) {
        final period = _periods.firstWhere((p) => p.id == tuition.periodId);
        final status = tuition.getStatus(period);
        if (status == TuitionPaymentStatus.pending) {
          return tuition;
        }
      }
    }
    return null;
  }

  /// Mark tuition as paid
  Future<bool> markTuitionAsPaid(String tuitionId, String transactionId) async {
    final index = _studentTuitions.indexWhere((t) => t.id == tuitionId);
    if (index != -1) {
      _studentTuitions[index] = _studentTuitions[index].copyWith(
        isPaid: true,
        paidDate: DateTime.now(),
        transactionId: transactionId,
      );
      // TODO: Save to backend database
      return true;
    }
    return false;
  }

  /// Get period by ID
  TuitionPaymentPeriod? getPeriodById(String periodId) {
    try {
      return _periods.firstWhere((p) => p.id == periodId);
    } catch (e) {
      return null;
    }
  }

  /// Get all student tuitions
  List<StudentTuition> getAllStudentTuitions() {
    return List.unmodifiable(_studentTuitions);
  }

  /// Get tuition period (alias for getPeriodById)
  TuitionPaymentPeriod? getTuitionPeriod(String periodId) {
    return getPeriodById(periodId);
  }
}

class StudentTuitionData {
  final String studentId;
  final double amount;

  StudentTuitionData({required this.studentId, required this.amount});
}
