import '../models/student.dart';
import '../models/student_tuition.dart';
import 'tuition_management_service.dart';

class StudentService {
  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;
  StudentService._internal();

  final TuitionManagementService _tuitionService = TuitionManagementService();

  // Static data for demo - TODO: Replace with backend database
  final Map<String, Student> _students = {
    '52200001': Student(studentId: '52200001', fullName: 'Nguyễn Văn An'),
    '52200002': Student(studentId: '52200002', fullName: 'Trần Thị Bảo'),
    '52200003': Student(studentId: '52200003', fullName: 'Lê Hoàng Châu'),
    '52200004': Student(studentId: '52200004', fullName: 'Phạm Minh Đức'),
    '52200005': Student(studentId: '52200005', fullName: 'Vũ Thị Hoa'),
  };

  List<Student> getAllStudents() {
    return _students.values.toList();
  }

  Student? getStudent(String studentId) {
    return _students[studentId];
  }

  Student? getStudentById(String studentId) {
    return _students[studentId];
  }

  List<StudentTuition> getStudentTuitions(String studentId) {
    final student = getStudent(studentId);
    if (student == null) return [];
    return _tuitionService.getStudentTuitionsForStudent(student.studentId);
  }

  StudentTuition? getCurrentUnpaidTuition(String studentId) {
    final student = getStudent(studentId);
    if (student == null) return null;
    return _tuitionService.getCurrentUnpaidTuition(student.studentId);
  }

  bool hasUnpaidTuition(String studentId) {
    return getCurrentUnpaidTuition(studentId) != null;
  }

  Future<bool> payTuition(
    String studentId,
    String tuitionId,
    String transactionId,
  ) async {
    return await _tuitionService.markTuitionAsPaid(tuitionId, transactionId);
  }

  Future<bool> createStudent({
    required String studentId,
    required String password,
    required String fullName,
    required String email,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Check if student already exists
      if (_students.containsKey(studentId)) {
        return false; // Student already exists
      }

      // Create the student
      final student = Student(studentId: studentId, fullName: fullName);

      // Add to students map
      _students[studentId] = student;

      // TODO: In a real app, this would also:
      // 1. Create user account in AuthService
      // 2. Send welcome email
      // 3. Save to database

      return true;
    } catch (e) {
      return false;
    }
  }
}
