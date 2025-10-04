import '../../routes/student_routes.dart';
import '../../config/api_routes.dart';
import '../../models/student.dart';
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
