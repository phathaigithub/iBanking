import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../models/tuition_payment_request.dart';
import '../services/student_service.dart';
import '../services/payment_service.dart';
import '../services/auth_service.dart';

enum PaymentStep { form, otp, success }

class PaymentViewModel extends ChangeNotifier {
  final StudentService _studentService = StudentService();
  final PaymentService _paymentService = PaymentService();
  final AuthService _authService = AuthService();

  // Callback to notify when user data is updated
  Function()? onUserUpdated;

  PaymentStep _currentStep = PaymentStep.form;
  PaymentStep get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Student? _selectedStudent;
  Student? get selectedStudent => _selectedStudent;

  String? _transactionId;
  String? get transactionId => _transactionId;

  TuitionPaymentRequest? _paymentRequest;
  TuitionPaymentRequest? get paymentRequest => _paymentRequest;

  bool _agreedToTerms = false;
  bool get agreedToTerms => _agreedToTerms;

  Future<void> searchStudent(String studentId) async {
    _setLoading(true);
    _clearError();

    // Reset previous search results
    _selectedStudent = null;
    _paymentRequest = null;
    _agreedToTerms = false;
    notifyListeners();

    try {
      final currentUser = _authService.currentUser;

      // Check if user is trying to pay for their own tuition
      if (currentUser != null &&
          !currentUser.isAdmin &&
          currentUser.studentId == studentId &&
          !_studentService.hasUnpaidTuition(studentId)) {
        _setError('Bạn không có học phí cần thanh toán');
        return;
      }

      final student = _studentService.getStudent(studentId);
      if (student != null) {
        final hasUnpaid = _studentService.hasUnpaidTuition(studentId);
        if (!hasUnpaid) {
          _setError('Sinh viên này không có học phí cần thanh toán');
        } else {
          _selectedStudent = student;
          _createPaymentRequest();
        }
      } else {
        _setError('Không tìm thấy thông tin sinh viên');
      }
    } catch (e) {
      _setError('Đã xảy ra lỗi khi tìm kiếm sinh viên: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _createPaymentRequest() {
    final currentUser = _authService.currentUser;
    if (currentUser != null && _selectedStudent != null) {
      final currentTuition = _studentService.getCurrentUnpaidTuition(
        _selectedStudent!.studentId,
      );
      if (currentTuition != null) {
        _paymentRequest = TuitionPaymentRequest(
          payerName: currentUser.fullName,
          payerPhone: currentUser.phoneNumber,
          payerEmail: currentUser.email,
          studentId: _selectedStudent!.studentId,
          studentName: _selectedStudent!.fullName,
          tuitionFeeId: currentTuition.id,
          tuitionAmount: currentTuition.amount,
          availableBalance: currentUser.availableBalance,
        );
        notifyListeners();
      }
    }
  }

  void setAgreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  bool get canProceedToOTP {
    return _selectedStudent != null &&
        _paymentRequest != null &&
        _paymentRequest!.canPay &&
        _agreedToTerms;
  }

  Future<void> initiatePayment() async {
    if (!canProceedToOTP || _paymentRequest == null) {
      _setError('Vui lòng kiểm tra lại thông tin');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final transactionId = await _paymentService.initiatePayment(
        _paymentRequest!,
      );
      if (transactionId != null) {
        _transactionId = transactionId;
        _currentStep = PaymentStep.otp;
      } else {
        _setError('Không thể khởi tạo giao dịch');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> confirmPayment(String otpCode) async {
    if (_transactionId == null || _paymentRequest == null) {
      _setError('Thông tin giao dịch không hợp lệ');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final success = await _paymentService.confirmPayment(
        _transactionId!,
        otpCode,
        _paymentRequest!,
      );

      if (success) {
        _currentStep = PaymentStep.success;
        // Notify that user data has been updated (balance changed)
        onUserUpdated?.call();
      } else {
        _setError('Xác thực OTP thất bại');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void cancelPayment() {
    if (_transactionId != null) {
      _paymentService.cancelPayment(_transactionId!);
    }
    reset();
  }

  void reset() {
    _currentStep = PaymentStep.form;
    _selectedStudent = null;
    _transactionId = null;
    _paymentRequest = null;
    _agreedToTerms = false;
    _clearError();
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

  void setError(String error) {
    _setError(error);
  }

  // Clear search results when input changes
  void clearSearchResults() {
    _selectedStudent = null;
    _paymentRequest = null;
    _agreedToTerms = false;
    _clearError();
    notifyListeners();
  }
}
