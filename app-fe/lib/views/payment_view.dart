import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/user_payment_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../utils/payment_config.dart';
import 'otp_verification_page.dart';
import 'payment_success_page.dart';
import 'payment_failed_page.dart';

class PaymentView extends ConsumerStatefulWidget {
  const PaymentView({super.key});

  @override
  ConsumerState<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends ConsumerState<PaymentView> {
  final _tuitionCodeController = TextEditingController();
  PaymentStep? _lastNavigatedStep;

  @override
  void dispose() {
    _tuitionCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final paymentState = ref.watch(userPaymentProvider);

    if (user == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Không có thông tin người dùng',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Handle navigation based on payment step - only navigate once per step
    if (paymentState.currentStep != PaymentStep.search &&
        paymentState.currentStep != _lastNavigatedStep) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _lastNavigatedStep = paymentState.currentStep;

        if (paymentState.currentStep == PaymentStep.otpVerification) {
          // Clear tuition code input when navigating to OTP page
          _tuitionCodeController.clear();
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const OtpVerificationPage(),
                ),
              )
              .then((_) {
                // Reset navigation tracking when returning
                if (mounted) {
                  setState(() {
                    _lastNavigatedStep = null;
                  });
                }
              });
        } else if (paymentState.currentStep == PaymentStep.success) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const PaymentSuccessPage(),
                ),
              )
              .then((_) {
                if (mounted) {
                  setState(() {
                    _lastNavigatedStep = null;
                  });
                }
              });
        } else if (paymentState.currentStep == PaymentStep.failed) {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const PaymentFailedPage(),
                ),
              )
              .then((_) {
                if (mounted) {
                  setState(() {
                    _lastNavigatedStep = null;
                  });
                }
              });
        }
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.payment, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thanh toán học phí',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Function Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nhập mã học phí để thanh toán. Thông tin học phí sẽ hiển thị trong ${PaymentConfig.tuitionCardDisplayDuration} giây sau khi tìm thấy.',
                    style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tìm kiếm học phí',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tuitionCodeController,
                  decoration: InputDecoration(
                    labelText: 'Mã học phí',
                    hintText: 'Nhập mã học phí',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.school),
                  ),
                  onChanged: (value) {
                    ref
                        .read(userPaymentProvider.notifier)
                        .setTuitionCode(value);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: paymentState.isLoading
                        ? null
                        : () {
                            ref
                                .read(userPaymentProvider.notifier)
                                .searchTuition();
                          },
                    icon: paymentState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      paymentState.isLoading ? 'Đang tìm kiếm...' : 'Tìm kiếm',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Error Message
          if (paymentState.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      paymentState.error!,
                      style: TextStyle(color: Colors.red[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

          // Tuition Information Card (with countdown)
          if (paymentState.hasActiveTuition)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thông tin học phí',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              paymentState.remainingSeconds >
                                  PaymentConfig.timeRunningOutThreshold
                              ? Colors.green[50]
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                paymentState.remainingSeconds >
                                    PaymentConfig.timeRunningOutThreshold
                                ? Colors.green[200]!
                                : Colors.orange[200]!,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer,
                              size: 16,
                              color:
                                  paymentState.remainingSeconds >
                                      PaymentConfig.timeRunningOutThreshold
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${paymentState.remainingSeconds}s',
                              style: TextStyle(
                                color:
                                    paymentState.remainingSeconds >
                                        PaymentConfig.timeRunningOutThreshold
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Mã sinh viên',
                    paymentState.tuition!.studentCode,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Học kỳ',
                    paymentState.tuition!.semesterDisplay,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Số tiền',
                    CurrencyFormatter.format(paymentState.tuition!.amount),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Trạng thái', paymentState.tuition!.status),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: paymentState.canProceedToPayment
                          ? () => _showConfirmationDialog(context, ref)
                          : null,
                      icon: const Icon(Icons.payment),
                      label: const Text('Thanh toán'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final paymentState = ref.read(userPaymentProvider);
    final user = ref.read(currentUserProvider);

    if (paymentState.tuition == null || user == null) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Xác nhận thanh toán',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Bạn có chắc chắn muốn thanh toán học phí?',
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),

                  const SizedBox(height: 20),

                  // Payment details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Column(
                      children: [
                        _buildConfirmationRow(
                          'Mã sinh viên',
                          paymentState.tuition!.studentCode,
                        ),
                        const SizedBox(height: 12),
                        _buildConfirmationRow(
                          'Học kỳ',
                          paymentState.tuition!.semesterDisplay,
                        ),
                        const SizedBox(height: 12),
                        _buildConfirmationRow(
                          'Số tiền',
                          CurrencyFormatter.format(
                            paymentState.tuition!.amount,
                          ),
                          isAmount: true,
                        ),
                        const Divider(height: 24),
                        _buildConfirmationRow(
                          'Số dư hiện tại',
                          CurrencyFormatter.format(user.balance),
                        ),
                        const SizedBox(height: 8),
                        _buildConfirmationRow(
                          'Số dư sau thanh toán',
                          CurrencyFormatter.format(
                            user.balance - paymentState.tuition!.amount,
                          ),
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text(
                            'Xác nhận',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result == true && mounted) {
      await ref.read(userPaymentProvider.notifier).initiatePayment();
    }
  }

  Widget _buildConfirmationRow(
    String label,
    String value, {
    bool isAmount = false,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        // Fixed width for label
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Flexible for value to prevent overflow
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isAmount ? 18 : 14,
              fontWeight: isAmount || isHighlight
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: isAmount
                  ? Colors.green[700]
                  : isHighlight
                  ? Colors.blue[700]
                  : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
