import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_payment_provider.dart';
import '../utils/helpers.dart';

class PaymentSuccessPage extends ConsumerWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(userPaymentProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Kết quả thanh toán'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green[200]!, width: 4),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Success Title
                  const Text(
                    'Thanh toán thành công!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Success Message
                  Text(
                    'Giao dịch của bạn đã được xử lý thành công',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Transaction Details Card
                  if (paymentState.payment != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chi tiết giao dịch',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Mã giao dịch',
                            '#${paymentState.payment!.id}',
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Mã học phí',
                            paymentState.payment!.tuitionCode,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Số tiền',
                            CurrencyFormatter.format(
                              paymentState.payment!.amount,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Trạng thái',
                            'Thành công',
                            valueColor: Colors.green,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Thời gian',
                            DateFormatter.formatDateTime(
                              DateTime.parse(paymentState.payment!.updatedAt),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(userPaymentProvider.notifier).reset();
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Tiếp tục'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
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

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
