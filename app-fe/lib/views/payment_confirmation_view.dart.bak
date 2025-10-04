import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/payment_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class PaymentConfirmationView extends StatefulWidget {
  final PaymentViewModel paymentViewModel;

  const PaymentConfirmationView({super.key, required this.paymentViewModel});

  @override
  State<PaymentConfirmationView> createState() =>
      _PaymentConfirmationViewState();
}

class _PaymentConfirmationViewState extends State<PaymentConfirmationView> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.paymentViewModel.currentStep == PaymentStep.otp) {
          return await _showExitConfirmationDialog();
        }
        return false; // Don't allow back on success screen
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Xử lý thanh toán'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          leading: widget.paymentViewModel.currentStep == PaymentStep.otp
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    if (await _showExitConfirmationDialog()) {
                      Navigator.of(context).pop(false);
                    }
                  },
                )
              : null, // Don't show back button on success screen
        ),
        body: ChangeNotifierProvider.value(
          value: widget.paymentViewModel,
          child: Consumer<PaymentViewModel>(
            builder: (context, paymentVM, child) {
              switch (paymentVM.currentStep) {
                case PaymentStep.otp:
                  return _buildOTPForm(paymentVM);
                case PaymentStep.success:
                  return _buildSuccessView(paymentVM);
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOTPForm(PaymentViewModel paymentVM) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.security,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text('Xác thực OTP', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  const Text(
                    'Mã OTP đã được gửi đến email của bạn',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Payment summary
                  if (paymentVM.paymentRequest != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Thông tin giao dịch',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Sinh viên:',
                            paymentVM.paymentRequest!.studentName,
                          ),
                          _buildInfoRow(
                            'Số tiền:',
                            CurrencyFormatter.format(
                              paymentVM.paymentRequest!.tuitionAmount,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  TextFormField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: 'Mã OTP',
                      hintText: 'Nhập 6 ký tự số',
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateOTP,
                  ),

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
                          Icon(Icons.error_outline, color: Colors.red[700]),
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

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: paymentVM.isLoading
                          ? null
                          : () => _confirmOTP(paymentVM),
                      child: paymentVM.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Xác nhận'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(PaymentViewModel paymentVM) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 80, color: Colors.green),
                  const SizedBox(height: 16),
                  Text('Thanh toán thành công!', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  const Text(
                    'Giao dịch của bạn đã được xử lý thành công',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Transaction details
                  if (paymentVM.paymentRequest != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Chi tiết giao dịch',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Mã giao dịch:',
                            paymentVM.transactionId ?? 'N/A',
                          ),
                          _buildInfoRow(
                            'Sinh viên:',
                            paymentVM.paymentRequest!.studentName,
                          ),
                          _buildInfoRow(
                            'Số tiền:',
                            CurrencyFormatter.format(
                              paymentVM.paymentRequest!.tuitionAmount,
                            ),
                          ),
                          _buildInfoRow(
                            'Thời gian:',
                            DateFormatter.formatDateTime(DateTime.now()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Thanh toán mới'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmOTP(PaymentViewModel paymentVM) async {
    final otpCode = _otpController.text.trim();
    if (otpCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mã OTP')));
      return;
    }

    if (otpCode.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mã OTP phải có 6 ký tự')));
      return;
    }

    await paymentVM.confirmPayment(otpCode);
  }

  Future<bool> _showExitConfirmationDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Có muốn hủy giao dịch hiện tại?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Có'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      Navigator.of(context).pop(false); // Return false to indicate cancellation
      return true; // Confirm exit
    }
    return false; // Don't exit
  }
}
