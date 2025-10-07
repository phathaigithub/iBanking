import 'package:shared_preferences/shared_preferences.dart';

/// API Routes configuration for microservice endpoints
/// This file centralizes all API endpoints and their error codes
class ApiRoutes {
  // Storage key for custom gateway endpoint
  static const String _gatewayEndpointKey = 'gateway_endpoint';

  // Default Gateway Endpoint
  static const String defaultGatewayEndpoint = 'http://localhost:8086';

  // Current gateway endpoint (can be changed at runtime)
  static String _gatewayEndpoint = defaultGatewayEndpoint;

  // Getter for current gateway endpoint
  static String get gatewayEndpoint => _gatewayEndpoint;

  // Service Base Endpoints (computed dynamically)
  static String get userServiceEndpoint => '$_gatewayEndpoint/user-service/api';
  static String get studentServiceEndpoint =>
      '$_gatewayEndpoint/student-service/api';
  static String get tuitionServiceEndpoint =>
      '$_gatewayEndpoint/tuition-service/api';
  static String get paymentServiceEndpoint =>
      '$_gatewayEndpoint/payment-service/api';

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  /// Initialize API endpoint from storage
  static Future<void> initialize(SharedPreferences prefs) async {
    _gatewayEndpoint =
        prefs.getString(_gatewayEndpointKey) ?? defaultGatewayEndpoint;
  }

  /// Update gateway endpoint
  static Future<void> setGatewayEndpoint(
    SharedPreferences prefs,
    String endpoint,
  ) async {
    // Remove trailing slash if exists
    final cleanEndpoint = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;

    _gatewayEndpoint = cleanEndpoint;
    await prefs.setString(_gatewayEndpointKey, cleanEndpoint);
  }

  /// Reset to default endpoint
  static Future<void> resetToDefault(SharedPreferences prefs) async {
    _gatewayEndpoint = defaultGatewayEndpoint;
    await prefs.remove(_gatewayEndpointKey);
  }
}
