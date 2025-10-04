import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class PaymentHistoryView extends ConsumerWidget {
  const PaymentHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

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
                child: Icon(Icons.history, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Lịch sử hoạt động',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Payment History Section
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
                const SizedBox(height: 16),
                _buildPaymentHistoryItem(
                  type: 'Thanh toán học phí',
                  date: '04/09/2025 10:22',
                  amount: -15000000,
                  student: 'Nguyễn Văn An',
                  icon: Icons.school,
                  iconColor: Colors.orange,
                ),
                const Divider(height: 24),
                _buildPaymentHistoryItem(
                  type: 'Nạp tiền vào tài khoản',
                  date: '05/08/2025 10:22',
                  amount: 20000000,
                  icon: Icons.add_circle,
                  iconColor: Colors.green,
                ),
                const Divider(height: 24),
                _buildPaymentHistoryItem(
                  type: 'Thanh toán học phí',
                  date: '15/07/2025 14:30',
                  amount: -12000000,
                  student: 'Trần Thị Bình',
                  icon: Icons.school,
                  iconColor: Colors.orange,
                ),
                const Divider(height: 24),
                _buildPaymentHistoryItem(
                  type: 'Nạp tiền vào tài khoản',
                  date: '01/07/2025 09:15',
                  amount: 5000000,
                  icon: Icons.add_circle,
                  iconColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryItem({
    required String type,
    required String date,
    required double amount,
    String? student,
    required IconData icon,
    required Color iconColor,
  }) {
    final isNegative = amount < 0;
    final amountText =
        '${isNegative ? '-' : '+'} ${amount.abs().toStringAsFixed(0)} đ';
    final amountColor = isNegative ? Colors.red : Colors.green;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ngày: $date',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              if (student != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Sinh viên: $student',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
        Text(
          amountText,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
