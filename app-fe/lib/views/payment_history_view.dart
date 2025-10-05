import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/payment_history_provider.dart';
import '../models/api/payment_history_response.dart';
import '../utils/app_theme.dart';

class PaymentHistoryView extends ConsumerStatefulWidget {
  const PaymentHistoryView({super.key});

  @override
  ConsumerState<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends ConsumerState<PaymentHistoryView> {
  @override
  void initState() {
    super.initState();
    // Load history when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(paymentHistoryProvider.notifier).loadHistory(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final historyState = ref.watch(paymentHistoryProvider);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.history,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Lịch sử hoạt động',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // Refresh button
                IconButton(
                  onPressed: historyState.isLoading
                      ? null
                      : () {
                          ref
                              .read(paymentHistoryProvider.notifier)
                              .refresh(user.id);
                        },
                  icon: Icon(
                    Icons.refresh,
                    color: historyState.isLoading
                        ? Colors.grey
                        : AppColors.primary,
                  ),
                  tooltip: 'Làm mới',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // History Card - Remove horizontal padding to make it full width
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loading state
                if (historyState.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                // Error state
                else if (historyState.error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            historyState.error!,
                            style: TextStyle(color: Colors.red[700]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                // Empty state
                else if (historyState.history.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history_outlined,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có giao dịch nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                // History list
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: historyState.sortedHistory.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = historyState.sortedHistory[index];
                      return _buildHistoryItem(item);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(PaymentHistoryResponse item) {
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    Color backgroundColor;

    if (item.isSuccess) {
      statusColor = Colors.green[700]!;
      statusIcon = Icons.check_circle;
      backgroundColor = Colors.green[50]!;
    } else if (item.isPending) {
      statusColor = Colors.orange[700]!;
      statusIcon = Icons.schedule;
      backgroundColor = Colors.orange[50]!;
    } else {
      statusColor = Colors.red[700]!;
      statusIcon = Icons.cancel;
      backgroundColor = Colors.red[50]!;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getStatusText(item.status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                '#${item.id}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Amount
          Text(
            currencyFormat.format(item.amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          // Tuition info
          Text(
            'Mã học phí: ${item.tuitionCode}',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),

          const SizedBox(height: 4),

          // Date
          Text(
            '${item.semesterDisplay} - ${dateFormat.format(item.createdDate)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),

          // Message (if not success)
          if (!item.isSuccess) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.message,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'SUCCESS':
        return 'Thành công';
      case 'PENDING':
        return 'Đang chờ';
      case 'FAILED':
        return 'Thất bại';
      default:
        return status;
    }
  }
}
