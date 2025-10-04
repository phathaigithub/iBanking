# Migration Guide - Flutter App to Riverpod & Backend Integration

## Overview

This document describes the migration from a wireframe Flutter app with hardcoded data to a production-ready application that integrates with microservice backends using Riverpod for state management.

## Major Changes

### 1. Dependencies Updated

**Added:**
- `flutter_riverpod` - State management
- `riverpod_annotation` - Riverpod code generation
- `http` - HTTP client for API calls
- `freezed_annotation` & `json_annotation` - JSON serialization
- Build tools: `build_runner`, `freezed`, `json_serializable`, `riverpod_generator`

**Removed:**
- `provider` - Replaced with Riverpod

### 2. New Configuration

Created `lib/config/api_config.dart` with all backend endpoints:
- Gateway Endpoint: `http://localhost:8086`
- User Service: `{gateway}/user-service/api`
- Student Service: `{gateway}/student-service/api`
- Tuition Service: `{gateway}/tuition-service/api`
- Payment Service: `{gateway}/payment-service/api`

### 3. New API Models

Created models in `lib/models/api/`:
- `AuthResponse` - Login response with token
- `UserResponse` - User profile from `/auth/me` endpoint
- `ApiError` - Standard error response format

### 4. API Services

Created in `lib/services/api/`:
- `ApiClient` - Base HTTP client with error handling
- `AuthApiService` - Authentication endpoints
  - `login(username, password)` - POST `/auth/login`
  - `getCurrentUser(token)` - GET `/auth/me`

### 5. Riverpod Providers

Created `lib/providers/auth_provider.dart`:
- `authProvider` - Main authentication state
- `currentUserProvider` - Current user data
- `isAuthenticatedProvider` - Authentication status
- `isAdminProvider` - Admin role check

### 6. Updated Views

**Refactored to use Riverpod:**
- `LoginView` - New professional login with API integration
- `UserDashboardView` - User dashboard with role-based navigation
- `PaymentView` - Simplified payment form (placeholder for backend API)
- `AccountInfoView` - User account information display
- `TuitionLookupView` - Student tuition lookup (placeholder)
- `AdminDashboardView` - Admin dashboard (placeholder)

**Backed up as .bak files:**
- `payment_view.dart.bak`
- `account_info_view.dart.bak`
- `tuition_lookup_view.dart.bak`
- `admin_dashboard_view.dart.bak`
- `add_student_view.dart.bak`
- `payment_confirmation_view.dart.bak`
- `tuition_management_view.dart.bak`

### 7. Main Changes

Updated `lib/main.dart`:
- Initialized `SharedPreferences` for token storage
- Wrapped app in `ProviderScope`
- Added `AuthWrapper` for automatic navigation based on auth state
- Removed old demo credential logs

## Authentication Flow

### 1. Login Process

```dart
// User enters username and password
// AuthNotifier.login() is called

1. POST /auth/login with credentials
   Response: { "token": "..." }

2. GET /auth/me with Bearer token
   Response: { "id", "username", "email", "fullName", "phone", "balance", "role" }

3. Save token to SharedPreferences
4. Update AuthState with token and user
5. Navigate to appropriate dashboard based on role
```

### 2. Auto-Login on App Start

```dart
1. Read token from SharedPreferences
2. If token exists, call GET /auth/me
3. If successful, restore user session
4. If failed, clear token and show login
```

### 3. Logout

```dart
1. Remove token from SharedPreferences
2. Clear AuthState
3. Navigate to login screen
```

## User Interface Changes

### Login View
- Professional design with better UX
- Clear error messages from backend
- Loading indicator during authentication
- Connection info display for development

### User Dashboard
- Shows user's full name in AppBar
- Three tabs: Payment, Lookup, Account Info
- Removed "Pay for me" button (as requested)
- Changed "My Tuition" to "Student Tuition Lookup"

### Account Info View
- Displays all user data from backend:
  - ID, Username, Full Name
  - Email, Phone
  - Balance (formatted as currency)
  - Role

### Payment & Lookup Views
- Placeholder implementations
- Ready for backend API integration
- Show development notices

## Backend Requirements

### Expected Endpoints

#### 1. Login
```http
POST /user-service/api/auth/login
Content-Type: application/json

{
  "username": "user1",
  "password": "123"
}

Response 200:
{
  "token": "eyJhbGciOiJIUzI1NiIs..."
}

Response 401:
{
  "status": 401,
  "errorCode": "INVALID_CREDENTIALS",
  "message": "Invalid username or password"
}
```

#### 2. Get Current User
```http
GET /user-service/api/auth/me
Authorization: Bearer {token}

Response 200:
{
  "id": 2,
  "username": "user1",
  "email": "user@example.com",
  "fullName": "User One",
  "phone": "0987654321",
  "balance": 100000,
  "role": "USER"
}

Response 401/500:
{
  "status": 401,
  "errorCode": "UNAUTHORIZED",
  "message": "Invalid or expired token"
}
```

## Running the Application

### Prerequisites
1. Flutter SDK installed
2. Backend microservices running on `localhost:8086`

### Steps

1. Install dependencies:
```bash
flutter pub get
```

2. Generate code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

3. Run the app:
```bash
flutter run
```

### Testing

1. Ensure backend is running on `localhost:8086`
2. Login with valid credentials from your backend
3. Verify role-based navigation:
   - `role: "USER"` → User Dashboard
   - `role: "ADMIN"` → Admin Dashboard

## Error Handling

The app handles various error scenarios:
- **Network errors**: "Cannot connect to server"
- **Invalid credentials**: Shows backend error message
- **Token expiration**: Auto-logout and redirect to login
- **Server errors**: Shows user-friendly error messages

## Next Steps

### To Complete Backend Integration:

1. **Payment Service Integration**
   - Implement student search API
   - Implement tuition payment flow
   - Add OTP verification

2. **Tuition Service Integration**
   - Implement tuition lookup API
   - Display tuition history
   - Show payment status

3. **Admin Features**
   - Student management
   - Tuition period creation
   - Payment statistics

4. **Additional Features**
   - Refresh token mechanism
   - Push notifications
   - Transaction history details

## File Structure

```
lib/
├── config/
│   └── api_config.dart                 # API endpoints configuration
├── models/
│   ├── api/
│   │   ├── auth_response.dart          # Login response model
│   │   ├── user_response.dart          # User profile model
│   │   └── api_error.dart              # Error response model
│   └── ... (old models preserved)
├── providers/
│   └── auth_provider.dart              # Riverpod authentication providers
├── services/
│   ├── api/
│   │   ├── api_client.dart             # Base HTTP client
│   │   └── auth_api_service.dart       # Auth API endpoints
│   └── ... (old services preserved for reference)
├── views/
│   ├── login_view.dart                 # Refactored login
│   ├── user_dashboard_view.dart        # Refactored dashboard
│   ├── payment_view.dart               # Simplified payment
│   ├── account_info_view.dart          # User info display
│   ├── tuition_lookup_view.dart        # Tuition lookup
│   ├── admin_dashboard_view.dart       # Admin placeholder
│   └── *.dart.bak                      # Backed up old files
├── utils/
│   ├── app_theme.dart                  # Theme configuration
│   └── helpers.dart                    # Utility functions
└── main.dart                           # App entry point
```

## Notes

- All old view files are backed up with `.bak` extension
- Old service files are preserved for reference
- The app uses `flutter_riverpod` 2.x (compatible with your SDK)
- Token is stored securely in `SharedPreferences`
- All API calls have 30-second timeout
- Network errors are handled gracefully

## Troubleshooting

### "Cannot connect to server"
- Verify backend is running on `localhost:8086`
- Check firewall settings
- Ensure all microservices are accessible through the gateway

### "Invalid token" errors
- Clear app data and login again
- Check token format from backend
- Verify `/auth/me` endpoint accepts Bearer tokens

### Build errors
- Run `flutter clean`
- Run `flutter pub get`
- Run `dart run build_runner build --delete-conflicting-outputs`

