import '../../routes/tuition_routes.dart';
import '../../config/api_routes.dart';
import '../../models/tuition_payment_period.dart';
import '../../models/student_tuition.dart';
import '../../models/api/tuition_response.dart';
import '../../models/api/create_tuition_period_request.dart';
import '../../models/api/create_tuition_period_response.dart';
import '../../models/api/tuition_inquiry_response.dart';
import 'api_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  // Admin Tuition Management
  Future<List<TuitionResponse>> getAllTuitions() async {
    try {
      // Try direct HTTP call first since API returns List directly
      return await _getAllTuitionsDirect();
    } catch (e) {
      // Fallback to ApiClient if direct call fails
      try {
        final response = await _apiClient.get(
          url: '${ApiRoutes.tuitionServiceEndpoint}/tuition',
        );
        final List<dynamic> tuitionsJson = response['data'] ?? response;
        return tuitionsJson
            .map((json) => TuitionResponse.fromJson(json))
            .toList();
      } catch (e2) {
        throw Exception('Failed to load tuitions: $e');
      }
    }
  }

  Future<List<TuitionResponse>> _getAllTuitionsDirect() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.tuitionServiceEndpoint}/tuition'),
        headers: ApiRoutes.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> tuitionsJson =
            jsonDecode(response.body) as List<dynamic>;
        return tuitionsJson
            .map(
              (json) => TuitionResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load tuitions: $e');
    }
  }

  Future<List<TuitionResponse>> searchTuitions({
    String? majorCode,
    String? semester,
  }) async {
    try {
      // Try direct HTTP call first since API returns List directly
      return await _searchTuitionsDirect(
        majorCode: majorCode,
        semester: semester,
      );
    } catch (e) {
      // Fallback to ApiClient if direct call fails
      try {
        final queryParams = <String, String>{};
        if (majorCode != null && majorCode.isNotEmpty) {
          queryParams['code'] = majorCode;
        }
        if (semester != null && semester.isNotEmpty) {
          queryParams['semester'] = semester;
        }

        final queryString = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');

        final url = queryString.isNotEmpty
            ? '${ApiRoutes.tuitionServiceEndpoint}/tuition/search?$queryString'
            : '${ApiRoutes.tuitionServiceEndpoint}/tuition/search';

        final response = await _apiClient.get(url: url);
        final List<dynamic> tuitionsJson = response['data'] ?? response;
        return tuitionsJson
            .map((json) => TuitionResponse.fromJson(json))
            .toList();
      } catch (e2) {
        throw Exception('Failed to search tuitions: $e');
      }
    }
  }

  Future<List<TuitionResponse>> _searchTuitionsDirect({
    String? majorCode,
    String? semester,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (majorCode != null && majorCode.isNotEmpty) {
        queryParams['code'] = majorCode;
      }
      if (semester != null && semester.isNotEmpty) {
        queryParams['semester'] = semester;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final url = queryString.isNotEmpty
          ? '${ApiRoutes.tuitionServiceEndpoint}/tuition/search?$queryString'
          : '${ApiRoutes.tuitionServiceEndpoint}/tuition/search';

      final response = await http.get(
        Uri.parse(url),
        headers: ApiRoutes.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> tuitionsJson =
            jsonDecode(response.body) as List<dynamic>;
        return tuitionsJson
            .map(
              (json) => TuitionResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to search tuitions: $e');
    }
  }

  // Create Tuition Period by Major
  Future<CreateTuitionPeriodResponse> createTuitionPeriodByMajor(
    CreateTuitionPeriodRequest request,
  ) async {
    final response = await _apiClient.post(
      url: '${ApiRoutes.tuitionServiceEndpoint}/tuition/create-by-major',
      body: request.toJson(),
    );

    return CreateTuitionPeriodResponse.fromJson(response);
  }

  // Get Tuition by Code
  Future<TuitionResponse> getTuitionByCode(String tuitionCode) async {
    final response = await _apiClient.get(
      url: '${ApiRoutes.tuitionServiceEndpoint}/tuition/$tuitionCode',
    );
    return TuitionResponse.fromJson(response);
  }

  // Tuition Inquiry - Request OTP
  Future<String> requestTuitionInquiryOtp(String studentCode) async {
    final response = await _apiClient.post(
      url: '${ApiRoutes.tuitionServiceEndpoint}/tuition/inquiry/request',
      body: {'studentCode': studentCode},
    );
    return response['message'] as String;
  }

  // Tuition Inquiry - Verify OTP
  Future<TuitionInquiryResponse> verifyTuitionInquiryOtp({
    required String studentCode,
    required String otpCode,
  }) async {
    final response = await _apiClient.post(
      url: '${ApiRoutes.tuitionServiceEndpoint}/tuition/inquiry/verify',
      body: {'studentCode': studentCode, 'otpCode': otpCode},
    );
    return TuitionInquiryResponse.fromJson(response);
  }

  void dispose() {
    _apiClient.dispose();
  }
}
