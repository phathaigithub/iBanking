/// API Routes configuration for microservice endpoints
/// This file centralizes all API endpoints and their error codes
class ApiRoutes {
  // Base Gateway Endpoint
  static const String gatewayEndpoint = 'http://localhost:8086';

  // Service Base Endpoints
  static const String userServiceEndpoint = '$gatewayEndpoint/user-service/api';
  static const String studentServiceEndpoint =
      '$gatewayEndpoint/student-service/api';
  static const String tuitionServiceEndpoint =
      '$gatewayEndpoint/tuition-service/api';
  static const String paymentServiceEndpoint =
      '$gatewayEndpoint/payment-service/api';

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
