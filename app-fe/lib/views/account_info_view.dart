import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/auth_service.dart';
import '../models/transaction.dart';
import '../utils/helpers.dart';
import '../utils/app_theme.dart';

class AccountInfoView extends StatefulWidget {
  const AccountInfoView({Key? key}) : super(key: key);

  @override
  State<AccountInfoView> createState() => _AccountInfoViewState();
}

class _AccountInfoViewState extends State<AccountInfoView>
    with AutomaticKeepAliveClientMixin {
  final AuthService _authService = AuthService();
  final _depositController = TextEditingController();
  final _depositFormKey = GlobalKey<FormState>();
  bool _isProcessingDeposit = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        final currentUser = authVM.currentUser;
        if (currentUser == null) {
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
                      _buildInfoRow('Họ và tên:', currentUser.fullName),
                      const SizedBox(height: 12),
                      _buildInfoRow('Số điện thoại:', currentUser.phoneNumber),
                      const SizedBox(height: 12),
                      _buildInfoRow('Email:', currentUser.email),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Số dư khả dụng:',
                        CurrencyFormatter.format(currentUser.availableBalance),
                        valueColor: AppColors.primary,
                        valueFontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Deposit Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nạp tiền vào tài khoản',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _depositFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _depositController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Số tiền cần nạp',
                                prefixText: '₫ ',
                                helperText: 'Số tiền tối thiểu: 100,000 VND',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập số tiền';
                                }
                                final amount = double.tryParse(
                                  value.replaceAll(',', ''),
                                );
                                if (amount == null || amount <= 0) {
                                  return 'Số tiền không hợp lệ';
                                }
                                if (amount < 100000) {
                                  return 'Số tiền tối thiểu là 100,000 VND';
                                }
                                if (amount > 1000000000) {
                                  return 'Số tiền tối đa là 1,000,000,000 VND';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isProcessingDeposit
                                    ? null
                                    : _processDeposit,
                                icon: _isProcessingDeposit
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add_circle),
                                label: Text(
                                  _isProcessingDeposit
                                      ? 'Đang xử lý...'
                                      : 'Nạp tiền',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Lưu ý:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                            // TODO: Xóa ở production
                            if (kDebugMode) ...[
                              const SizedBox(height: 4),
                              Text(
                                '• Chức năng nạp tiền hiện tại chỉ mô phỏng\n'
                                '• TODO: Tích hợp với cổng thanh toán thực tế\n'
                                '• TODO: Xác thực OTP cho giao dịch nạp tiền\n'
                                '• TODO: Kết nối với hệ thống ngân hàng',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  Future<void> _processDeposit() async {
    if (!_depositFormKey.currentState!.validate()) return;

    setState(() {
      _isProcessingDeposit = true;
    });

    try {
      final amountText = _depositController.text.replaceAll(',', '');
      final amount = double.parse(amountText);

      // TODO: Integrate with actual payment gateway
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing

      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Create deposit transaction
        final transaction = Transaction(
          id: 'deposit_${DateTime.now().millisecondsSinceEpoch}',
          date: DateTime.now(),
          amount: amount,
          type: TransactionType.deposit,
          description: 'Nạp tiền vào tài khoản',
        );

        // Update user balance and transaction history
        final updatedTransactions = List<Transaction>.from(
          currentUser.transactionHistory,
        )..add(transaction);

        final updatedUser = currentUser.copyWith(
          availableBalance: currentUser.availableBalance + amount,
          transactionHistory: updatedTransactions,
        );

        _authService.updateCurrentUser(updatedUser);

        // Update UI
        final authVM = Provider.of<AuthViewModel>(context, listen: false);
        authVM.clearError(); // This will trigger a rebuild

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Nạp tiền thành công: ${CurrencyFormatter.format(amount)}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Clear form
        _depositController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi nạp tiền: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingDeposit = false;
        });
      }
    }
  }
}
