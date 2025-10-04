/// API Configuration for microservice endpoints
/// This file is deprecated - use api_routes.dart instead
@Deprecated('Use ApiRoutes from api_routes.dart instead')
class ApiConfig {
  // Base Gateway Endpoint
  static const String gatewayEndpoint = 'http://localhost:8086';

  // Service Endpoints
  static const String userServiceEndpoint = '$gatewayEndpoint/user-service/api';
  static const String studentServiceEndpoint =
      '$gatewayEndpoint/student-service/api';
  static const String tuitionServiceEndpoint =
      '$gatewayEndpoint/tuition-service/api';
  static const String paymentServiceEndpoint =
      '$gatewayEndpoint/payment-service/api';

  // Auth Endpoints
  static const String loginEndpoint = '$userServiceEndpoint/auth/login';
  static const String meEndpoint = '$userServiceEndpoint/auth/me';

  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
