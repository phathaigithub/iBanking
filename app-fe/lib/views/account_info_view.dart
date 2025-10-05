import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class AccountInfoView extends ConsumerStatefulWidget {
  const AccountInfoView({super.key});

  @override
  ConsumerState<AccountInfoView> createState() => _AccountInfoViewState();
}

class _AccountInfoViewState extends ConsumerState<AccountInfoView> {
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return Padding(
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
                child: Icon(Icons.person, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thông tin tài khoản',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Account Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildInfoRow('Họ và tên:', user.fullName),
                const SizedBox(height: 12),
                _buildInfoRow('Email:', user.email),
                const SizedBox(height: 12),
                _buildInfoRow('Số điện thoại:', user.phone),
              ],
            ),
          ),

          // const SizedBox(height: 20),

          // // Deposit Card
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: Colors.grey[200]!),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(
          //             Icons.account_balance_wallet,
          //             color: AppColors.primary,
          //             size: 20,
          //           ),
          //           const SizedBox(width: 8),
          //           const Text(
          //             'Nạp tiền vào tài khoản',
          //             style: TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 16),
          //       TextField(
          //         controller: _amountController,
          //         decoration: const InputDecoration(
          //           labelText: 'Số tiền nạp',
          //           hintText: 'Nhập số tiền muốn nạp',
          //           border: OutlineInputBorder(),
          //           prefixIcon: Icon(Icons.attach_money),
          //           suffixText: 'VNĐ',
          //         ),
          //         keyboardType: TextInputType.number,
          //       ),
          //       const SizedBox(height: 16),
          //       SizedBox(
          //         width: double.infinity,
          //         child: ElevatedButton.icon(
          //           onPressed: () {
          //             if (_amountController.text.isEmpty) {
          //               ScaffoldMessenger.of(context).showSnackBar(
          //                 const SnackBar(
          //                   content: Text('Vui lòng nhập số tiền cần nạp'),
          //                   backgroundColor: Colors.orange,
          //                 ),
          //               );
          //               return;
          //             }
          //             ScaffoldMessenger.of(context).showSnackBar(
          //               const SnackBar(
          //                 content: Text(
          //                   'Chức năng nạp tiền đang được phát triển. Vui lòng chờ cập nhật API.',
          //                 ),
          //               ),
          //             );
          //           },
          //           icon: const Icon(Icons.add_card),
          //           label: const Text('Nạp tiền'),
          //           style: ElevatedButton.styleFrom(
          //             padding: const EdgeInsets.symmetric(vertical: 12),
          //             backgroundColor: Colors.green,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
