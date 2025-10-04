import '../../routes/tuition_routes.dart';
import '../../models/tuition_payment_period.dart';
import '../../models/student_tuition.dart';
import 'api_client.dart';

class TuitionApiService {
  final ApiClient _apiClient;

  TuitionApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  // Period Management
  Future<List<TuitionPaymentPeriod>> getAllPeriods() async {
    final response = await _apiClient.get(url: TuitionRoutes.getAllPeriods);
    final List<dynamic> periodsJson = response['data'] ?? [];
    return periodsJson
        .map((json) => TuitionPaymentPeriod.fromJson(json))
        .toList();
  }

  Future<TuitionPaymentPeriod?> getPeriodById(String periodId) async {
    try {
      final response = await _apiClient.get(
        url: TuitionRoutes.getPeriodUrl(periodId),
      );
      return TuitionPaymentPeriod.fromJson(response['data']);
    } catch (e) {
      if (e is ApiException && e.error.errorCode == 'PERIOD_NOT_FOUND') {
        return null;
      }
      rethrow;
    }
  }

  Future<TuitionPaymentPeriod> createPeriod({
    required int academicYear,
    required int semester,
    required DateTime startDate,
    required DateTime dueDate,
    required List<Map<String, dynamic>> studentTuitions,
  }) async {
    final response = await _apiClient.post(
      url: TuitionRoutes.createPeriod,
      body: {
        'academicYear': academicYear,
        'semester': semester,
        'startDate': startDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'studentTuitions': studentTuitions,
      },
    );
    return TuitionPaymentPeriod.fromJson(response['data']);
  }

  Future<List<TuitionPaymentPeriod>> getActivePeriods() async {
    final response = await _apiClient.get(url: TuitionRoutes.getActivePeriods);
    final List<dynamic> periodsJson = response['data'] ?? [];
    return periodsJson
        .map((json) => TuitionPaymentPeriod.fromJson(json))
        .toList();
  }

  // Student Tuition Management
  Future<List<StudentTuition>> getAllStudentTuitions() async {
    final response = await _apiClient.get(
      url: TuitionRoutes.getAllStudentTuitions,
    );
    final List<dynamic> tuitionsJson = response['data'] ?? [];
    return tuitionsJson.map((json) => StudentTuition.fromJson(json)).toList();
  }

  Future<List<StudentTuition>> getStudentTuitionsByPeriod(
    String periodId,
  ) async {
    final response = await _apiClient.get(
      url: TuitionRoutes.getStudentTuitionsByPeriodUrl(periodId),
    );
    final List<dynamic> tuitionsJson = response['data'] ?? [];
    return tuitionsJson.map((json) => StudentTuition.fromJson(json)).toList();
  }

  Future<List<StudentTuition>> getStudentTuitionsByStudent(
    String studentId,
  ) async {
    final response = await _apiClient.get(
      url: TuitionRoutes.getStudentTuitionsByStudentUrl(studentId),
    );
    final List<dynamic> tuitionsJson = response['data'] ?? [];
    return tuitionsJson.map((json) => StudentTuition.fromJson(json)).toList();
  }

  Future<StudentTuition> createStudentTuition({
    required String studentId,
    required String periodId,
    required double amount,
  }) async {
    final response = await _apiClient.post(
      url: TuitionRoutes.createStudentTuition,
      body: {'studentId': studentId, 'periodId': periodId, 'amount': amount},
    );
    return StudentTuition.fromJson(response['data']);
  }

  Future<bool> markTuitionPaid(String tuitionId, String transactionId) async {
    try {
      await _apiClient.post(
        url: TuitionRoutes.getMarkTuitionPaidUrl(tuitionId),
        body: {
          'transactionId': transactionId,
          'paidDate': DateTime.now().toIso8601String(),
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}
