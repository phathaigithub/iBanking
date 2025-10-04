import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../routes/student_routes.dart';
import '../../config/api_routes.dart';
import '../../models/student.dart';
import '../../models/student_detail.dart';
import '../../models/student_tuition.dart';
import 'api_client.dart';

class StudentApiService {
  final ApiClient _apiClient;

  StudentApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Student>> getAllStudents() async {
    final response = await _apiClient.get(url: StudentRoutes.getAllStudents);
    final List<dynamic> studentsJson = response['data'] ?? [];
    return studentsJson.map((json) => Student.fromJson(json)).toList();
  }

  Future<List<StudentDetail>> getAllStudentDetails() async {
    try {
      // Try direct HTTP call first since API returns List directly
      return await _getStudentsDirect();
    } catch (e) {
      // Fallback to ApiClient if direct call fails
      try {
        final response = await _apiClient.get(
          url: '${ApiRoutes.studentServiceEndpoint}/students',
        );

        // ApiClient returns Map, extract data field
        final List<dynamic> studentsJson =
            response['data'] as List<dynamic>? ?? [];
        return studentsJson
            .map((json) => StudentDetail.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e2) {
        throw Exception('Failed to load students: $e');
      }
    }
  }

  Future<List<StudentDetail>> _getStudentsDirect() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.studentServiceEndpoint}/students'),
        headers: ApiRoutes.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> studentsJson =
            jsonDecode(response.body) as List<dynamic>;
        return studentsJson
            .map((json) => StudentDetail.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load students: $e');
    }
  }

  Future<Student?> getStudentById(String studentId) async {
    try {
      final response = await _apiClient.get(
        url: StudentRoutes.getStudentUrl(studentId),
      );
      return Student.fromJson(response['data']);
    } catch (e) {
      // If student not found, return null instead of throwing
      if (e is ApiException && e.error.errorCode == 'STUDENT_NOT_FOUND') {
        return null;
      }
      rethrow;
    }
  }

  Future<Student> createStudent({
    required String studentId,
    required String password,
    required String fullName,
    required String email,
  }) async {
    final response = await _apiClient.post(
      url: StudentRoutes.createStudent,
      body: {
        'studentId': studentId,
        'password': password,
        'fullName': fullName,
        'email': email,
      },
    );
    return Student.fromJson(response['data']);
  }

  Future<Student> updateStudent(
    String studentId,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiClient.post(
      url: StudentRoutes.updateStudent,
      body: {'studentId': studentId, ...updates},
    );
    return Student.fromJson(response['data']);
  }

  Future<void> deleteStudent(String studentId) async {
    await _apiClient.post(
      url: StudentRoutes.deleteStudent,
      body: {'studentId': studentId},
    );
  }

  Future<List<StudentTuition>> getStudentTuitions(String studentId) async {
    final response = await _apiClient.get(
      url: StudentRoutes.getStudentTuitionsUrl(studentId),
    );
    final List<dynamic> tuitionsJson = response['data'] ?? [];
    return tuitionsJson.map((json) => StudentTuition.fromJson(json)).toList();
  }

  Future<List<Student>> searchStudents(String query) async {
    final response = await _apiClient.get(
      url: StudentRoutes.searchStudents,
      headers: {...ApiRoutes.defaultHeaders, 'query': query},
    );
    final List<dynamic> studentsJson = response['data'] ?? [];
    return studentsJson.map((json) => Student.fromJson(json)).toList();
  }

  void dispose() {
    _apiClient.dispose();
  }
}
