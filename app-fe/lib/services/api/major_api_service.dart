import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_routes.dart';
import '../../models/major.dart';
import 'api_client.dart';

class MajorApiService {
  final ApiClient _apiClient;

  MajorApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Major>> getAllMajors() async {
    try {
      // Try direct HTTP call first since API returns List directly
      return await _getMajorsDirect();
    } catch (e) {
      // Fallback to ApiClient if direct call fails
      try {
        final response = await _apiClient.get(
          url: '${ApiRoutes.studentServiceEndpoint}/majors',
        );

        // ApiClient returns Map, extract data field
        final List<dynamic> majorsJson =
            response['data'] as List<dynamic>? ?? [];
        return majorsJson
            .map((json) => Major.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e2) {
        throw Exception('Failed to load majors: $e');
      }
    }
  }

  Future<List<Major>> _getMajorsDirect() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiRoutes.studentServiceEndpoint}/majors'),
        headers: ApiRoutes.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> majorsJson =
            jsonDecode(response.body) as List<dynamic>;
        return majorsJson
            .map((json) => Major.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load majors: $e');
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}
