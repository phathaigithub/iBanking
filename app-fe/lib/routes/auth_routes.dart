import '../config/api_routes.dart';

/// Authentication API Routes
/// Contains all authentication-related endpoints and their specific error codes
class AuthRoutes {
  static const String _baseUrl = ApiRoutes.userServiceEndpoint;

  // Authentication Endpoints
  static const String login = '$_baseUrl/auth/login';
  static const String me = '$_baseUrl/auth/me';
  static const String refresh = '$_baseUrl/auth/refresh';
  static const String logout = '$_baseUrl/auth/logout';

  // Authentication Error Codes
  static const Map<String, String> errorCodes = {
    'USER_NOT_FOUND': 'Người dùng không tồn tại',
    'INVALID_CREDENTIALS': 'Tên đăng nhập hoặc mật khẩu không đúng',
    'ACCOUNT_LOCKED': 'Tài khoản đã bị khóa',
    'ACCOUNT_DISABLED': 'Tài khoản đã bị vô hiệu hóa',
    'TOKEN_EXPIRED': 'Token đã hết hạn',
    'TOKEN_INVALID': 'Token không hợp lệ',
    'INVALID_TOKEN_FORMAT': 'Định dạng token không hợp lệ',
    'REFRESH_TOKEN_EXPIRED': 'Refresh token đã hết hạn',
    'UNAUTHORIZED': 'Không có quyền truy cập',
    'FORBIDDEN': 'Bị cấm truy cập',
  };

  // Helper method to get error message by code
  static String getErrorMessage(String errorCode) {
    return errorCodes[errorCode] ?? 'Lỗi xác thực không xác định';
  }
}
