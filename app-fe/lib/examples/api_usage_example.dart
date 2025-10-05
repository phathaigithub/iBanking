import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api/auth_api_service.dart';
import '../services/api/student_api_service.dart';
import '../services/api/tuition_api_service.dart';
import '../services/api/payment_api_service.dart';
import '../services/api/api_client.dart';

/// Example usage of the new API routes system with specific error handling
class ApiUsageExample {
  final AuthApiService _authService = AuthApiService();
  final StudentApiService _studentService = StudentApiService();
  final TuitionApiService _tuitionService = TuitionApiService();
  final PaymentApiService _paymentService = PaymentApiService();

  /// Example 1: Login with specific error handling
  Future<bool> loginUser(String username, String password) async {
    try {
      final authResponse = await _authService.login(
        username: username,
        password: password,
      );

      // Success - get user data
      final user = await _authService.getCurrentUser(authResponse.token);
      print('Login successful: ${user.fullName}');
      return true;
    } on ApiException catch (e) {
      // Handle specific authentication errors
      switch (e.error.errorCode) {
        case 'USER_NOT_FOUND':
          print('Error: Người dùng không tồn tại');
          break;
        case 'INVALID_CREDENTIALS':
          print('Error: Tên đăng nhập hoặc mật khẩu không đúng');
          break;
        case 'ACCOUNT_LOCKED':
          print('Error: Tài khoản đã bị khóa');
          break;
        case 'ACCOUNT_DISABLED':
          print('Error: Tài khoản đã bị vô hiệu hóa');
          break;
        case 'TOKEN_EXPIRED':
          print('Error: Token đã hết hạn');
          break;
        default:
          print('Auth Error: ${e.error.message}');
      }
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }

  /// Example 2: Get student with error handling
  Future<void> getStudentInfo(String studentId) async {
    try {
      final student = await _studentService.getStudentById(studentId);
      if (student != null) {
        print('Student found: ${student.fullName}');
      } else {
        print('Student not found');
      }
    } on ApiException catch (e) {
      switch (e.error.errorCode) {
        case 'STUDENT_NOT_FOUND':
          print('Error: Không tìm thấy sinh viên');
          break;
        case 'INVALID_STUDENT_ID':
          print('Error: Mã số sinh viên không hợp lệ');
          break;
        case 'STUDENT_NOT_ACTIVE':
          print('Error: Sinh viên không còn hoạt động');
          break;
        case 'STUDENT_SUSPENDED':
          print('Error: Sinh viên đã bị đình chỉ');
          break;
        default:
          print('Student Error: ${e.error.message}');
      }
    }
  }

  /// Example 3: Get tuition with error handling
  Future<void> getStudentTuitions(String studentId) async {
    try {
      final tuitions = await _tuitionService.getStudentTuitionsByStudent(
        studentId,
      );
      print('Found ${tuitions.length} tuition records');

      for (final tuition in tuitions) {
        print('Tuition: ${tuition.amount} - Paid: ${tuition.isPaid}');
      }
    } on ApiException catch (e) {
      switch (e.error.errorCode) {
        case 'STUDENT_TUITION_NOT_FOUND':
          print('Error: Không tìm thấy học phí sinh viên');
          break;
        case 'NO_TUITION_RECORDS':
          print('Error: Không có bản ghi học phí');
          break;
        case 'PERIOD_NOT_FOUND':
          print('Error: Không tìm thấy đợt đóng học phí');
          break;
        default:
          print('Tuition Error: ${e.error.message}');
      }
    }
  }

  /// Example 4: Payment with comprehensive error handling
  Future<bool> processPayment({
    required String studentId,
    required String tuitionId,
    required double amount,
    required String payerId,
    required String otpCode,
  }) async {
    try {
      // Step 1: Initiate payment
      final payment = await _paymentService.initiatePayment(
        studentId: studentId,
        tuitionId: tuitionId,
        amount: amount,
        payerId: payerId,
      );

      print('Payment initiated: ${payment.paymentId}');

      // Step 2: Confirm payment with OTP
      final success = await _paymentService.confirmPayment(
        paymentId: payment.paymentId,
        otpCode: otpCode,
      );

      if (success) {
        print('Payment confirmed successfully');
        return true;
      } else {
        print('Payment confirmation failed');
        return false;
      }
    } on ApiException catch (e) {
      switch (e.error.errorCode) {
        // Payment initiation errors
        case 'INSUFFICIENT_BALANCE':
          print('Error: Số dư không đủ để thực hiện giao dịch');
          break;
        case 'PAYMENT_AMOUNT_INVALID':
          print('Error: Số tiền thanh toán không hợp lệ');
          break;
        case 'PAYMENT_METHOD_NOT_SUPPORTED':
          print('Error: Phương thức thanh toán không được hỗ trợ');
          break;
        case 'DAILY_LIMIT_EXCEEDED':
          print('Error: Đã vượt quá giới hạn giao dịch hàng ngày');
          break;
        case 'MONTHLY_LIMIT_EXCEEDED':
          print('Error: Đã vượt quá giới hạn giao dịch hàng tháng');
          break;

        // OTP errors
        case 'OTP_INVALID':
          print('Error: Mã OTP không hợp lệ');
          break;
        case 'OTP_EXPIRED':
          print('Error: Mã OTP đã hết hạn');
          break;
        case 'OTP_ALREADY_USED':
          print('Error: Mã OTP đã được sử dụng');
          break;
        case 'OTP_LIMIT_EXCEEDED':
          print('Error: Đã vượt quá số lần nhập OTP cho phép');
          break;

        // Payment status errors
        case 'PAYMENT_ALREADY_PROCESSED':
          print('Error: Giao dịch đã được xử lý');
          break;
        case 'PAYMENT_CANCELLED':
          print('Error: Giao dịch đã bị hủy');
          break;
        case 'PAYMENT_EXPIRED':
          print('Error: Giao dịch đã hết hạn');
          break;
        case 'TRANSACTION_LOCKED':
          print('Error: Giao dịch đang được xử lý');
          break;

        // Gateway errors
        case 'PAYMENT_GATEWAY_ERROR':
          print('Error: Lỗi cổng thanh toán');
          break;
        case 'PAYMENT_TIMEOUT':
          print('Error: Giao dịch quá thời gian chờ');
          break;

        default:
          print('Payment Error: ${e.error.message}');
      }
      return false;
    } catch (e) {
      print('Unexpected payment error: $e');
      return false;
    }
  }

  /// Example 5: Create student with validation
  Future<bool> createNewStudent({
    required String studentId,
    required String password,
    required String fullName,
    required String email,
  }) async {
    try {
      final student = await _studentService.createStudent(
        studentId: studentId,
        password: password,
        fullName: fullName,
        email: email,
      );

      print('Student created successfully: ${student.fullName}');
      return true;
    } on ApiException catch (e) {
      switch (e.error.errorCode) {
        case 'STUDENT_ALREADY_EXISTS':
          print('Error: Sinh viên đã tồn tại');
          break;
        case 'STUDENT_ID_DUPLICATE':
          print('Error: Mã số sinh viên đã được sử dụng');
          break;
        case 'STUDENT_DATA_INVALID':
          print('Error: Dữ liệu sinh viên không hợp lệ');
          break;
        case 'INVALID_STUDENT_ID':
          print('Error: Mã số sinh viên không hợp lệ');
          break;
        default:
          print('Student Creation Error: ${e.error.message}');
      }
      return false;
    }
  }

  /// Example 6: Mark tuition as paid
  Future<bool> markTuitionPaid(String tuitionId, String transactionId) async {
    try {
      final success = await _tuitionService.markTuitionPaid(
        tuitionId,
        transactionId,
      );

      if (success) {
        print('Tuition marked as paid successfully');
        return true;
      } else {
        print('Failed to mark tuition as paid');
        return false;
      }
    } on ApiException catch (e) {
      switch (e.error.errorCode) {
        case 'STUDENT_TUITION_NOT_FOUND':
          print('Error: Không tìm thấy học phí sinh viên');
          break;
        case 'STUDENT_TUITION_ALREADY_PAID':
          print('Error: Học phí đã được thanh toán');
          break;
        case 'STUDENT_TUITION_NOT_DUE':
          print('Error: Học phí chưa đến hạn thanh toán');
          break;
        case 'STUDENT_TUITION_OVERDUE':
          print('Error: Học phí đã quá hạn thanh toán');
          break;
        default:
          print('Tuition Payment Error: ${e.error.message}');
      }
      return false;
    }
  }

  /// Cleanup resources
  void dispose() {
    _authService.dispose();
    _studentService.dispose();
    _tuitionService.dispose();
    _paymentService.dispose();
  }
}

/// Widget example showing how to use the API routes in UI
class ApiUsageExampleWidget extends ConsumerWidget {
  const ApiUsageExampleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final example = ApiUsageExample();

    return Scaffold(
      appBar: AppBar(title: const Text('API Routes Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => example.loginUser('user1', 'password123'),
              child: const Text('Test Login'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => example.getStudentInfo('52200001'),
              child: const Text('Get Student Info'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => example.getStudentTuitions('52200001'),
              child: const Text('Get Student Tuitions'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => example.processPayment(
                studentId: '52200001',
                tuitionId: 'tuition_123',
                amount: 15000000,
                payerId: 'user_123',
                otpCode: '123456',
              ),
              child: const Text('Process Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
