import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_payment_provider.dart';
import '../utils/app_theme.dart';

class PaymentFailedPage extends ConsumerWidget {
  const PaymentFailedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(userPaymentProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Kết quả thanh toán'),
          backgroundColor: Colors.red,
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
                  // Failed Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[200]!, width: 4),
                    ),
                    child: const Icon(Icons.error, size: 80, color: Colors.red),
                  ),

                  const SizedBox(height: 24),

                  // Failed Title
                  const Text(
                    'Thanh toán thất bại',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Error Message
                  Text(
                    paymentState.error ?? 'Giao dịch thất bại do quá thời hạn',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

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
                        backgroundColor: AppColors.primary,
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
}
