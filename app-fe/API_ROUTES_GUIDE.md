# API Routes Documentation

## Tổng quan

Hệ thống API routes đã được tách thành các file riêng biệt để dễ dàng quản lý exception và mã lỗi cụ thể cho từng endpoint.

## Cấu trúc thư mục

```
lib/
├── config/
│   ├── api_routes.dart          # Base configuration
│   └── api_config.dart          # Deprecated - use api_routes.dart
├── routes/
│   ├── auth_routes.dart         # Authentication endpoints & errors
│   ├── student_routes.dart      # Student endpoints & errors
│   ├── tuition_routes.dart      # Tuition endpoints & errors
│   └── payment_routes.dart      # Payment endpoints & errors
└── services/api/
    ├── api_client.dart          # Enhanced with route-specific error handling
    ├── auth_api_service.dart    # Authentication service
    ├── student_api_service.dart # Student service
    ├── tuition_api_service.dart # Tuition service
    └── payment_api_service.dart # Payment service
```

## Cách sử dụng

### 1. Authentication Routes

```dart
import '../routes/auth_routes.dart';

// Sử dụng endpoint
final response = await apiClient.post(
  url: AuthRoutes.login,
  body: {'username': username, 'password': password},
);

// Xử lý lỗi cụ thể
try {
  await authService.login(username, password);
} on ApiException catch (e) {
  if (e.error.errorCode == 'USER_NOT_FOUND') {
    // Xử lý khi người dùng không tồn tại
    showError('Người dùng không tồn tại');
  } else if (e.error.errorCode == 'INVALID_CREDENTIALS') {
    // Xử lý khi sai thông tin đăng nhập
    showError('Tên đăng nhập hoặc mật khẩu không đúng');
  }
}
```

### 2. Student Routes

```dart
import '../routes/student_routes.dart';

// Tìm kiếm sinh viên
final student = await studentService.getStudentById('52200001');

// Xử lý lỗi sinh viên
try {
  await studentService.createStudent(studentData);
} on ApiException catch (e) {
  if (e.error.errorCode == 'STUDENT_ALREADY_EXISTS') {
    showError('Sinh viên đã tồn tại');
  } else if (e.error.errorCode == 'INVALID_STUDENT_ID') {
    showError('Mã số sinh viên không hợp lệ');
  }
}
```

### 3. Tuition Routes

```dart
import '../routes/tuition_routes.dart';

// Lấy học phí sinh viên
final tuitions = await tuitionService.getStudentTuitionsByStudent('52200001');

// Xử lý lỗi học phí
try {
  await tuitionService.markTuitionPaid(tuitionId, transactionId);
} on ApiException catch (e) {
  if (e.error.errorCode == 'STUDENT_TUITION_ALREADY_PAID') {
    showError('Học phí đã được thanh toán');
  } else if (e.error.errorCode == 'STUDENT_TUITION_NOT_DUE') {
    showError('Học phí chưa đến hạn thanh toán');
  }
}
```

### 4. Payment Routes

```dart
import '../routes/payment_routes.dart';

// Khởi tạo thanh toán
final payment = await paymentService.initiatePayment(paymentData);

// Xử lý lỗi thanh toán
try {
  await paymentService.confirmPayment(paymentId, otpCode);
} on ApiException catch (e) {
  if (e.error.errorCode == 'INSUFFICIENT_BALANCE') {
    showError('Số dư không đủ để thực hiện giao dịch');
  } else if (e.error.errorCode == 'OTP_INVALID') {
    showError('Mã OTP không hợp lệ');
  } else if (e.error.errorCode == 'OTP_EXPIRED') {
    showError('Mã OTP đã hết hạn');
  }
}
```

## Mã lỗi cụ thể

### Authentication Errors
- `USER_NOT_FOUND`: Người dùng không tồn tại
- `INVALID_CREDENTIALS`: Tên đăng nhập hoặc mật khẩu không đúng
- `ACCOUNT_LOCKED`: Tài khoản đã bị khóa
- `TOKEN_EXPIRED`: Token đã hết hạn
- `UNAUTHORIZED`: Không có quyền truy cập

### Student Errors
- `STUDENT_NOT_FOUND`: Không tìm thấy sinh viên
- `STUDENT_ALREADY_EXISTS`: Sinh viên đã tồn tại
- `INVALID_STUDENT_ID`: Mã số sinh viên không hợp lệ
- `STUDENT_NOT_ACTIVE`: Sinh viên không còn hoạt động

### Tuition Errors
- `PERIOD_NOT_FOUND`: Không tìm thấy đợt đóng học phí
- `STUDENT_TUITION_ALREADY_PAID`: Học phí đã được thanh toán
- `STUDENT_TUITION_NOT_DUE`: Học phí chưa đến hạn thanh toán
- `STUDENT_TUITION_OVERDUE`: Học phí đã quá hạn thanh toán

### Payment Errors
- `INSUFFICIENT_BALANCE`: Số dư không đủ để thực hiện giao dịch
- `OTP_INVALID`: Mã OTP không hợp lệ
- `OTP_EXPIRED`: Mã OTP đã hết hạn
- `PAYMENT_GATEWAY_ERROR`: Lỗi cổng thanh toán
- `DAILY_LIMIT_EXCEEDED`: Đã vượt quá giới hạn giao dịch hàng ngày

## Lợi ích

1. **Tách biệt rõ ràng**: Mỗi domain có file route riêng
2. **Xử lý lỗi cụ thể**: Mỗi endpoint có mã lỗi và thông báo riêng
3. **Dễ bảo trì**: Thêm/sửa endpoint chỉ cần chỉnh sửa file tương ứng
4. **Type safety**: Sử dụng enum và constant để tránh lỗi typo
5. **Tái sử dụng**: Các service có thể sử dụng chung các route
6. **Documentation**: Mỗi route có documentation rõ ràng

## Migration từ ApiConfig

Thay vì:
```dart
// Cũ
import '../config/api_config.dart';
final url = ApiConfig.loginEndpoint;
```

Sử dụng:
```dart
// Mới
import '../routes/auth_routes.dart';
final url = AuthRoutes.login;
```

## Ví dụ thực tế

```dart
// Login với xử lý lỗi cụ thể
Future<bool> loginUser(String username, String password) async {
  try {
    final authResponse = await authService.login(
      username: username,
      password: password,
    );
    return true;
  } on ApiException catch (e) {
    switch (e.error.errorCode) {
      case 'USER_NOT_FOUND':
        showSnackBar('Người dùng không tồn tại');
        break;
      case 'INVALID_CREDENTIALS':
        showSnackBar('Tên đăng nhập hoặc mật khẩu không đúng');
        break;
      case 'ACCOUNT_LOCKED':
        showSnackBar('Tài khoản đã bị khóa. Vui lòng liên hệ admin');
        break;
      default:
        showSnackBar(e.error.message);
    }
    return false;
  }
}
```
