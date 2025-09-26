import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.currentUser != null;
  bool get isAdmin => _authService.currentUser?.isAdmin ?? false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String studentCode, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.login(studentCode, password);
      if (user != null) {
        notifyListeners();
        return true;
      } else {
        _setError('Mã số sinh viên hoặc mật khẩu không đúng');
        return false;
      }
    } catch (e) {
      _setError('Đã xảy ra lỗi khi đăng nhập: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Method to notify UI when user data is updated
  void notifyUserUpdated() {
    notifyListeners();
  }
}
