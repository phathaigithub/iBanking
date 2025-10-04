import '../config/api_routes.dart';

/// Student API Routes
/// Contains all student-related endpoints and their specific error codes
class StudentRoutes {
  static const String _baseUrl = ApiRoutes.studentServiceEndpoint;

  // Student Endpoints
  static const String getAllStudents = '$_baseUrl/students';
  static const String getStudentById =
      '$_baseUrl/students'; // GET /students/{id}
  static const String createStudent = '$_baseUrl/students';
  static const String updateStudent =
      '$_baseUrl/students'; // PUT /students/{id}
  static const String deleteStudent =
      '$_baseUrl/students'; // DELETE /students/{id}
  static const String getStudentTuitions =
      '$_baseUrl/students'; // GET /students/{id}/tuitions
  static const String searchStudents = '$_baseUrl/students/search';

  // Student Error Codes
  static const Map<String, String> errorCodes = {
    'STUDENT_NOT_FOUND': 'Không tìm thấy sinh viên',
    'STUDENT_ALREADY_EXISTS': 'Sinh viên đã tồn tại',
    'INVALID_STUDENT_ID': 'Mã số sinh viên không hợp lệ',
    'STUDENT_ID_DUPLICATE': 'Mã số sinh viên đã được sử dụng',
    'STUDENT_DATA_INVALID': 'Dữ liệu sinh viên không hợp lệ',
    'STUDENT_NOT_ACTIVE': 'Sinh viên không còn hoạt động',
    'STUDENT_GRADUATED': 'Sinh viên đã tốt nghiệp',
    'STUDENT_SUSPENDED': 'Sinh viên đã bị đình chỉ',
    'NO_TUITION_RECORDS': 'Không có bản ghi học phí',
    'TUITION_NOT_FOUND': 'Không tìm thấy thông tin học phí',
  };

  // Helper method to get error message by code
  static String getErrorMessage(String errorCode) {
    return errorCodes[errorCode] ?? 'Lỗi sinh viên không xác định';
  }

  // Helper method to build student-specific URLs
  static String getStudentUrl(String studentId) =>
      '$_baseUrl/students/$studentId';
  static String getStudentTuitionsUrl(String studentId) =>
      '$_baseUrl/students/$studentId/tuitions';
}
