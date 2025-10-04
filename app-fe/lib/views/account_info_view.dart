import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class AccountInfoView extends ConsumerWidget {
  const AccountInfoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Center(child: Text('Không có thông tin người dùng'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thông tin tài khoản', style: AppTextStyles.heading2),
          const SizedBox(height: 24),

          // Account Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('ID:', user.id.toString()),
                  const SizedBox(height: 12),
                  _buildInfoRow('Tên đăng nhập:', user.username),
                  const SizedBox(height: 12),
                  _buildInfoRow('Họ và tên:', user.fullName),
                  const SizedBox(height: 12),
                  _buildInfoRow('Email:', user.email),
                  const SizedBox(height: 12),
                  _buildInfoRow('Số điện thoại:', user.phone),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Số dư:',
                    CurrencyFormatter.format(user.balance),
                    valueColor: AppColors.primary,
                    valueFontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Vai trò:', user.role),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Additional info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tài khoản đã xác thực',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Bạn đang đăng nhập với quyền: ${user.role}',
                  style: TextStyle(color: Colors.green[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueFontWeight,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body1.copyWith(
              color: valueColor,
              fontWeight: valueFontWeight,
            ),
          ),
        ),
      ],
    );
  }
}
