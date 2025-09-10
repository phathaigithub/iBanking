import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/tuition_payment_request.dart';
import 'auth_service.dart';
import 'student_service.dart';
import 'otp_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final _uuid = const Uuid();
  final _authService = AuthService();
  final _studentService = StudentService();
  final _otpService = OTPService();

  // TODO: Add proper transaction locking mechanism when connecting to backend
  final Set<String> _lockedAccounts = <String>{};

  Future<String?> initiatePayment(TuitionPaymentRequest request) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return null;

    // Check if account is locked (to prevent concurrent transactions)
    if (_lockedAccounts.contains(currentUser.id)) {
      throw Exception('Tài khoản đang được xử lý giao dịch khác');
    }

    // Validate payment
    if (!request.canPay) {
      throw Exception('Số dư không đủ để thực hiện giao dịch');
    }

    // Check if student exists and has unpaid tuition
    final student = _studentService.getStudent(request.studentId);
    if (student == null) {
      throw Exception('Không tìm thấy thông tin sinh viên');
    }

    final hasUnpaid = _studentService.hasUnpaidTuition(request.studentId);
    if (!hasUnpaid) {
      throw Exception('Sinh viên không có học phí cần thanh toán');
    }

    // Generate transaction ID
    final transactionId = _uuid.v4();

    // TODO: Lock account in database to prevent concurrent transactions
    _lockAccount(currentUser.id);

    try {
      // Generate and send OTP
      await _otpService.generateOTP(transactionId);
      return transactionId;
    } catch (e) {
      _unlockAccount(currentUser.id);
      rethrow;
    }
  }

  Future<bool> confirmPayment(
    String transactionId,
    String otpCode,
    TuitionPaymentRequest request,
  ) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    try {
      // Verify OTP
      final isOTPValid = await _otpService.verifyOTP(transactionId, otpCode);
      if (!isOTPValid) {
        throw Exception('Mã OTP không hợp lệ hoặc đã hết hạn');
      }

      // Process payment
      await _processPayment(currentUser, request, transactionId);

      // TODO: Send confirmation email
      await _sendConfirmationEmail(currentUser.email, request);

      return true;
    } catch (e) {
      rethrow;
    } finally {
      _unlockAccount(currentUser.id);
    }
  }

  Future<void> _processPayment(
    User user,
    TuitionPaymentRequest request,
    String transactionId,
  ) async {
    // Deduct amount from user balance
    final newBalance = user.availableBalance - request.tuitionAmount;

    // Create transaction record
    final transaction = Transaction(
      id: transactionId,
      date: DateTime.now(),
      amount: request.tuitionAmount,
      type: TransactionType.tuitionPayment,
      description: 'Thanh toán học phí cho sinh viên ${request.studentName}',
      studentId: request.studentId,
      studentName: request.studentName,
    );

    // Update user (in real app, this would be done in backend)
    final updatedTransactions = List<Transaction>.from(user.transactionHistory)
      ..add(transaction);
    final updatedUser = user.copyWith(
      availableBalance: newBalance,
      transactionHistory: updatedTransactions,
    );

    // TODO: Update user in backend database
    _authService.updateCurrentUser(updatedUser);

    // Mark student tuition as paid
    await _studentService.payTuition(
      request.studentId,
      request.tuitionFeeId,
      transactionId,
    );
  }

  // TODO: Replace with actual email service
  Future<void> _sendConfirmationEmail(
    String email,
    TuitionPaymentRequest request,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    print('Confirmation email sent to: $email');
    print('Payment confirmed for student: ${request.studentName}');
  }

  void _lockAccount(String userId) {
    _lockedAccounts.add(userId);
  }

  void _unlockAccount(String userId) {
    _lockedAccounts.remove(userId);
  }

  void cancelPayment(String transactionId) {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _unlockAccount(currentUser.id);
    }
  }
}
