# Testing Guide - TUI iBanking Flutter App

## Quick Start

### 1. Prerequisites
- Flutter SDK 3.9.0 or higher
- Backend microservices running on `http://localhost:8086`
- Android Emulator / iOS Simulator / Chrome browser for web

### 2. Setup

```bash
# Navigate to project directory
cd app-fe

# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### 3. Test Login

The app will show a professional login screen with:
- Username field (e.g., "user1")
- Password field (e.g., "123")
- Connection info at the bottom

**Test with your backend credentials:**

#### For Regular User (role: "USER")
- Username: user1
- Password: 123
- Expected: Navigate to User Dashboard with 3 tabs

#### For Admin (role: "ADMIN")
- Username: admin
- Password: admin123
- Expected: Navigate to Admin Dashboard

### 4. Expected User Flow

#### Login Process
1. Enter username and password
2. Click "Đăng nhập" (Login)
3. Loading indicator appears
4. On success: Auto-navigate based on role
5. On error: Error message displayed in red box

#### User Dashboard (role: "USER")
**Tab 1 - Thanh toán (Payment)**
- Shows user info: name, phone, email, balance
- Payment form (placeholder)
- Info note about backend integration

**Tab 2 - Tra cứu (Lookup)**
- "Tra cứu học phí sinh viên" (Student Tuition Lookup)
- Search form (placeholder)
- Info note about backend integration

**Tab 3 - Thông tin (Account Info)**
- Complete user profile display:
  - ID, Username, Full Name
  - Email, Phone
  - Balance (formatted as VND)
  - Role
- Verified account status

#### Admin Dashboard (role: "ADMIN")
- Welcome message with admin name
- Admin info card
- Placeholder for admin features
- Development notice

### 5. Test Scenarios

#### Scenario 1: Successful Login
```
1. Open app
2. Enter valid credentials
3. Click login
4. ✓ Should navigate to appropriate dashboard
5. ✓ Should show user name in app bar
6. ✓ Should display user balance
```

#### Scenario 2: Invalid Credentials
```
1. Open app
2. Enter invalid credentials
3. Click login
4. ✓ Should show error message from backend
5. ✓ Should keep user on login screen
6. ✓ Should clear loading state
```

#### Scenario 3: Network Error
```
1. Stop backend services
2. Try to login
3. ✓ Should show "Cannot connect to server" error
4. ✓ Should handle timeout gracefully
```

#### Scenario 4: Token Persistence
```
1. Login successfully
2. Close app (don't logout)
3. Reopen app
4. ✓ Should auto-login with saved token
5. ✓ Should fetch user data
6. ✓ Should navigate to dashboard
```

#### Scenario 5: Logout
```
1. From dashboard, click logout icon
2. Confirm logout dialog
3. ✓ Should clear token
4. ✓ Should return to login screen
5. ✓ Trying to go back should not work
```

#### Scenario 6: Invalid Token (Expired)
```
1. Login successfully
2. Manually expire token in backend
3. Restart app
4. ✓ Should detect invalid token
5. ✓ Should auto-logout
6. ✓ Should show login screen
```

### 6. API Endpoints to Test

Make sure your backend supports these endpoints:

#### POST /user-service/api/auth/login
```json
Request:
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

#### GET /user-service/api/auth/me
```json
Headers:
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

Response 401:
{
  "status": 401,
  "errorCode": "UNAUTHORIZED",
  "message": "Invalid or expired token"
}
```

### 7. Debugging

#### Check Console Logs
The app logs useful information:
```
I/flutter: Attempting login for user: user1
I/flutter: Login successful, fetching user data
I/flutter: User data loaded: User One (USER)
```

#### Common Issues

**"Cannot connect to server"**
- Check if backend is running: `curl http://localhost:8086/user-service/api/health`
- Verify gateway is properly routing requests
- Check firewall/antivirus settings

**"Invalid username or password"**
- Verify credentials exist in your user database
- Check backend logs for authentication errors

**App crashes on startup**
- Run `flutter clean`
- Run `flutter pub get`
- Rebuild: `dart run build_runner build --delete-conflicting-outputs`

**Token not persisting**
- Check SharedPreferences is working
- Clear app data and try again
- Check device/emulator storage permissions

### 8. Testing Checklist

- [ ] Login with valid USER credentials
- [ ] Login with valid ADMIN credentials
- [ ] Login with invalid credentials
- [ ] Test network error handling
- [ ] Verify token persistence (close/reopen app)
- [ ] Test logout functionality
- [ ] Verify role-based navigation
- [ ] Check user data display in Account Info tab
- [ ] Test balance formatting
- [ ] Verify all 3 tabs in User Dashboard work
- [ ] Verify Admin Dashboard displays correctly
- [ ] Test on different screen sizes
- [ ] Test on different platforms (Android/iOS/Web)

### 9. Performance Testing

```bash
# Run in release mode for performance testing
flutter run --release

# Profile mode for debugging performance
flutter run --profile
```

### 10. Next Steps After Basic Testing

Once basic authentication works:
1. Implement student search API in Payment tab
2. Implement tuition lookup API in Lookup tab
3. Add payment flow with OTP
4. Implement admin features
5. Add transaction history

## Notes

- The app uses port 8086 by default (configured in `api_config.dart`)
- All API calls have 30-second timeout
- Token is stored in SharedPreferences
- Errors are displayed in Vietnamese
- UI is responsive and works on all screen sizes

## Support

If you encounter issues:
1. Check backend logs
2. Check Flutter console output
3. Verify API endpoints with Postman/Bruno
4. Review MIGRATION_GUIDE.md for architecture details

