import '../../routes/auth_routes.dart';
import '../../config/api_routes.dart';
import '../../models/api/auth_response.dart';
import '../../models/api/user_response.dart';
import 'api_client.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.post(
      url: AuthRoutes.login,
      body: {'username': username, 'password': password},
    );

    return AuthResponse.fromJson(response);
  }

  Future<UserResponse> getCurrentUser(String token) async {
    final response = await _apiClient.get(
      url: AuthRoutes.me,
      headers: ApiRoutes.authHeaders(token),
    );

    return UserResponse.fromJson(response);
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      url: AuthRoutes.refresh,
      body: {'refreshToken': refreshToken},
    );

    return AuthResponse.fromJson(response);
  }

  Future<void> logout(String token) async {
    await _apiClient.post(
      url: AuthRoutes.logout,
      headers: ApiRoutes.authHeaders(token),
      body: {},
    );
  }

  void dispose() {
    _apiClient.dispose();
  }
}
