import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api/user_response.dart';
import '../services/api/auth_api_service.dart';
import '../services/api/api_client.dart';

// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Provider for AuthApiService
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApiService(apiClient: apiClient);
});

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

// Token storage keys
const String _tokenKey = 'auth_token';

// Auth State
class AuthState {
  final String? token;
  final UserResponse? user;
  final bool isLoading;
  final String? error;

  AuthState({this.token, this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => token != null && user != null;
  bool get isAdmin => user?.isAdmin ?? false;
  bool get isUser => user?.isUser ?? false;

  AuthState copyWith({
    String? token,
    UserResponse? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearToken = false,
    bool clearUser = false,
  }) {
    return AuthState(
      token: clearToken ? null : (token ?? this.token),
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiService _authApiService;
  final SharedPreferences _prefs;

  AuthNotifier(this._authApiService, this._prefs) : super(AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final token = _prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      try {
        state = state.copyWith(isLoading: true, clearError: true);
        final user = await _authApiService.getCurrentUser(token);
        state = state.copyWith(token: token, user: user, isLoading: false);
      } catch (e) {
        // Token is invalid, clear it
        await _prefs.remove(_tokenKey);
        state = state.copyWith(
          isLoading: false,
          clearToken: true,
          clearUser: true,
        );
      }
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Step 1: Get token
      final authResponse = await _authApiService.login(
        username: username,
        password: password,
      );

      // Step 2: Get user data
      final user = await _authApiService.getCurrentUser(authResponse.token);

      // Step 3: Save token
      await _prefs.setString(_tokenKey, authResponse.token);

      // Step 4: Update state
      state = state.copyWith(
        token: authResponse.token,
        user: user,
        isLoading: false,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.error.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Đã xảy ra lỗi không xác định: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authApiService = ref.watch(authApiServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(authApiService, prefs);
});

// Convenience providers
final currentUserProvider = Provider<UserResponse?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});
