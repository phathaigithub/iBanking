import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tui_ibank/models/user.dart';
import '../viewmodels/payment_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../views/payment_confirmation_view.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key, this.onPaymentSuccess});

  final VoidCallback? onPaymentSuccess;

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _otpController = TextEditingController();
  final _ballanceController = TextEditingController();
  late User _currentUser;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _studentIdController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return ChangeNotifierProvider(
      create: (context) {
        final paymentVM = PaymentViewModel();
        // Setup callback to notify AuthViewModel when user data is updated
        paymentVM.onUserUpdated = () {
          final authVM = Provider.of<AuthViewModel>(context, listen: false);
          authVM.notifyUserUpdated();
        };
        return paymentVM;
      },
      child: Consumer<PaymentViewModel>(
        builder: (context, paymentVM, child) {
          // Only show form in this view, OTP and success will be in separate view
          return _buildPaymentForm(paymentVM);
        },
      ),
    );
  }

  Widget _buildPaymentForm(PaymentViewModel paymentVM) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payer info section
                Consumer<AuthViewModel>(
                  builder: (context, authVM, child) {
                    final currentUser = authVM.currentUser;
                    if (currentUser == null) return const SizedBox();
                    _currentUser = currentUser;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Người nộp tiền', style: AppTextStyles.heading3),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                          label: 'Họ và tên',
                          value: _currentUser.fullName,
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          label: 'Số điện thoại',
                          value: _currentUser.phoneNumber,
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          label: 'Email',
                          value: _currentUser.email,
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          controller: _ballanceController,
                          label: 'Số dư khả dụng',
                          value: CurrencyFormatter.format(
                            _currentUser.availableBalance,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Student info section
                Text('Thông tin người nộp', style: AppTextStyles.heading3),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Mã số sinh viên',
                    hintText: 'Nhập 8 ký tự số',
                  ),
                  validator: Validators.validateStudentId,
                  onChanged: (value) {
                    // Clear previous search results when input changes
                    paymentVM.clearSearchResults();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _searchForMe(paymentVM),
                        icon: const Icon(Icons.person),
                        label: const Text('Đóng cho tôi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _searchStudent(paymentVM),
                        icon: const Icon(Icons.search),
                        label: const Text('Tìm kiếm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Payment info section
                if (paymentVM.paymentRequest != null &&
                    paymentVM.errorMessage == null) ...[
                  Text('Thông tin thanh toán', style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    label: 'Họ tên sinh viên',
                    value: paymentVM.selectedStudent!.fullName,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    label: 'Số tiền cần nộp',
                    value: paymentVM.paymentRequest != null
                        ? CurrencyFormatter.format(
                            paymentVM.paymentRequest!.tuitionAmount,
                          )
                        : 'N/A',
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text(
                      'Tôi đồng ý với các điều khoản và điều kiện',
                    ),
                    value: paymentVM.agreedToTerms,
                    onChanged: (value) =>
                        paymentVM.setAgreedToTerms(value ?? false),
                  ),
                ],

                const SizedBox(height: 24),

                // Error display
                if (paymentVM.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            paymentVM.errorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Submit button (only show when there's a valid payment request)
                if (paymentVM.paymentRequest != null &&
                    paymentVM.errorMessage == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          paymentVM.canProceedToOTP && !paymentVM.isLoading
                          ? () => _navigateToConfirmation(paymentVM)
                          : null,
                      child: paymentVM.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Xác nhận giao dịch'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToConfirmation(PaymentViewModel paymentVM) async {
    // First initiate payment to get OTP
    await paymentVM.initiatePayment();

    if (paymentVM.currentStep == PaymentStep.otp && mounted) {
      // Navigate to confirmation view
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PaymentConfirmationView(paymentViewModel: paymentVM),
        ),
      );

      // Handle result
      if (result == true) {
        // Payment successful - clear data
        paymentVM.reset();
        _studentIdController.clear();

        _ballanceController.text = CurrencyFormatter.format(
          _currentUser.availableBalance,
        );

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Thanh toán thành công! Vui lòng kiểm tra lịch sử giao dịch.',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Call callback to switch tab after short delay
          if (widget.onPaymentSuccess != null) {
            Future.delayed(const Duration(milliseconds: 500), () {
              widget.onPaymentSuccess!();
            });
          }
        }
      } else if (result == false) {
        // User cancelled - keep data as is
        // paymentVM will still have the form data
      }
    }
  }

  void _searchForMe(PaymentViewModel paymentVM) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authVM.currentUser;

    if (currentUser != null) {
      _studentIdController.text = currentUser.username;
      _searchStudent(paymentVM);
    }
  }

  void _searchStudent(PaymentViewModel paymentVM) {
    final studentId = _studentIdController.text.trim();

    if (studentId.isEmpty) {
      paymentVM.setError('Vui lòng nhập mã số sinh viên bao gồm 8 ký tự');
      return;
    }

    if (studentId.length != 8) {
      paymentVM.setError('Vui lòng nhập mã số sinh viên bao gồm 8 ký tự');
      return;
    }

    // Clear any previous error
    paymentVM.clearError();
    paymentVM.searchStudent(studentId);
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    TextEditingController? controller,
  }) {
    if (controller != null) {
      controller.text = value;
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        readOnly: true,
      );
    } else {
      return TextFormField(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        readOnly: true,
      );
    }
  }
}
