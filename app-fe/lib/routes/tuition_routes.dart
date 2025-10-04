import '../config/api_routes.dart';

/// Tuition API Routes
/// Contains all tuition-related endpoints and their specific error codes
class TuitionRoutes {
  static const String _baseUrl = ApiRoutes.tuitionServiceEndpoint;

  // Tuition Period Endpoints
  static const String getAllPeriods = '$_baseUrl/periods';
  static const String getPeriodById = '$_baseUrl/periods'; // GET /periods/{id}
  static const String createPeriod = '$_baseUrl/periods';
  static const String updatePeriod = '$_baseUrl/periods'; // PUT /periods/{id}
  static const String deletePeriod =
      '$_baseUrl/periods'; // DELETE /periods/{id}
  static const String getActivePeriods = '$_baseUrl/periods/active';

  // Student Tuition Endpoints
  static const String getAllStudentTuitions = '$_baseUrl/student-tuitions';
  static const String getStudentTuitionsByPeriod =
      '$_baseUrl/student-tuitions/period'; // GET /student-tuitions/period/{periodId}
  static const String getStudentTuitionsByStudent =
      '$_baseUrl/student-tuitions/student'; // GET /student-tuitions/student/{studentId}
  static const String createStudentTuition = '$_baseUrl/student-tuitions';
  static const String updateStudentTuition =
      '$_baseUrl/student-tuitions'; // PUT /student-tuitions/{id}
  static const String markTuitionPaid =
      '$_baseUrl/student-tuitions'; // PUT /student-tuitions/{id}/paid

  // Tuition Error Codes
  static const Map<String, String> errorCodes = {
    'PERIOD_NOT_FOUND': 'Không tìm thấy đợt đóng học phí',
    'PERIOD_ALREADY_EXISTS': 'Đợt đóng học phí đã tồn tại',
    'PERIOD_NOT_ACTIVE': 'Đợt đóng học phí không còn hoạt động',
    'PERIOD_EXPIRED': 'Đợt đóng học phí đã hết hạn',
    'PERIOD_NOT_STARTED': 'Đợt đóng học phí chưa bắt đầu',
    'INVALID_PERIOD_DATES': 'Ngày tháng đợt đóng học phí không hợp lệ',
    'STUDENT_TUITION_NOT_FOUND': 'Không tìm thấy học phí sinh viên',
    'STUDENT_TUITION_ALREADY_PAID': 'Học phí đã được thanh toán',
    'STUDENT_TUITION_NOT_DUE': 'Học phí chưa đến hạn thanh toán',
    'STUDENT_TUITION_OVERDUE': 'Học phí đã quá hạn thanh toán',
    'INVALID_TUITION_AMOUNT': 'Số tiền học phí không hợp lệ',
    'TUITION_CALCULATION_ERROR': 'Lỗi tính toán học phí',
  };

  // Helper method to get error message by code
  static String getErrorMessage(String errorCode) {
    return errorCodes[errorCode] ?? 'Lỗi học phí không xác định';
  }

  // Helper method to build tuition-specific URLs
  static String getPeriodUrl(String periodId) => '$_baseUrl/periods/$periodId';
  static String getStudentTuitionsByPeriodUrl(String periodId) =>
      '$_baseUrl/student-tuitions/period/$periodId';
  static String getStudentTuitionsByStudentUrl(String studentId) =>
      '$_baseUrl/student-tuitions/student/$studentId';
  static String getStudentTuitionUrl(String tuitionId) =>
      '$_baseUrl/student-tuitions/$tuitionId';
  static String getMarkTuitionPaidUrl(String tuitionId) =>
      '$_baseUrl/student-tuitions/$tuitionId/paid';
}
