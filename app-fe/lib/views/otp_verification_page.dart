import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_payment_provider.dart';
import '../utils/app_theme.dart';
import '../utils/payment_config.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get otpCode => _otpControllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    // Only watch error and isLoading states for rebuild efficiency
    final error = ref.watch(userPaymentProvider.select((state) => state.error));
    final isLoading = ref.watch(
      userPaymentProvider.select((state) => state.isLoading),
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Xác thực giao dịch'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Timer Circle - separate widget to avoid rebuilding entire page
                  _CountdownTimer(),

                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'Nhập mã OTP',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    'Mã OTP đã được gửi đến email của bạn',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 40,
                        height: 60,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }

                            // Auto-submit when all fields are filled
                            if (index == 5 && value.isNotEmpty) {
                              _submitOtp();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Error Message
                  if (error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
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
                              error,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading || otpCode.length != 6
                          ? null
                          : _submitOtp,
                      icon: isLoading
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
                          : const Icon(Icons.check_circle),
                      label: Text(isLoading ? 'Đang xác thực...' : 'Xác nhận'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final shouldCancel = await showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.red[700],
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Xác nhận hủy giao dịch'),
                                    ],
                                  ),
                                  content: const Text(
                                    'Bạn có chắc chắn muốn hủy giao dịch này không? Quá trình thanh toán sẽ bị dừng lại.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text(
                                        'Giữ lại',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[700],
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Hủy giao dịch'),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldCancel == true) {
                                ref
                                    .read(userPaymentProvider.notifier)
                                    .backToSearch();
                                Navigator.of(context).pop();
                              }
                            },
                      child: const Text('Hủy giao dịch'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitOtp() {
    if (otpCode.length == 6) {
      ref.read(userPaymentProvider.notifier).verifyOtp(otpCode);
    }
  }
}

// Separate widget for countdown timer to prevent full page rebuild
class _CountdownTimer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch remainingSeconds to minimize rebuilds
    final remainingSeconds = ref.watch(
      userPaymentProvider.select((state) => state.remainingSeconds),
    );

    final isTimeRunningOut =
        remainingSeconds <= PaymentConfig.timeRunningOutThreshold;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isTimeRunningOut ? Colors.orange[50] : Colors.green[50],
        border: Border.all(
          color: isTimeRunningOut ? Colors.orange[200]! : Colors.green[200]!,
          width: 4,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer,
              size: 32,
              color: isTimeRunningOut ? Colors.orange[700] : Colors.green[700],
            ),
            const SizedBox(height: 4),
            Text(
              '${remainingSeconds}s',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isTimeRunningOut
                    ? Colors.orange[700]
                    : Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
