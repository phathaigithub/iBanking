import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/student_service.dart';
import '../services/tuition_management_service.dart';
import '../models/student_tuition.dart';
import '../models/tuition_payment_period.dart';
import '../models/transaction.dart';
import '../utils/helpers.dart';
import '../utils/app_theme.dart';

class TuitionLookupView extends StatefulWidget {
  final bool initiallyShowMyTuition;

  const TuitionLookupView({Key? key, this.initiallyShowMyTuition = false})
    : super(key: key);

  @override
  State<TuitionLookupView> createState() => _TuitionLookupViewState();
}

class _TuitionLookupViewState extends State<TuitionLookupView>
    with AutomaticKeepAliveClientMixin {
  final StudentService _studentService = StudentService();
  final TuitionManagementService _tuitionService = TuitionManagementService();
  bool _showMyTuition = false;
  bool _showTransactionHistory = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.initiallyShowMyTuition) {
      _showMyTuition = true;
      _showTransactionHistory = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tra cứu thông tin', style: AppTextStyles.heading2),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showMyTuition = true;
                      _showTransactionHistory = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showMyTuition
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.7),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.school),
                  label: const Text('Học phí của tôi'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showMyTuition = false;
                      _showTransactionHistory = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showTransactionHistory
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.7),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.history),
                  label: const Text('Lịch sử thanh toán'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Content area
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_showMyTuition) {
      return _buildMyTuitionView();
    } else if (_showTransactionHistory) {
      return _buildTransactionHistoryView();
    } else {
      return _buildInitialView();
    }
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chọn một trong các tùy chọn trên để xem thông tin',
            style: AppTextStyles.body1.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMyTuitionView() {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        final currentUser = authVM.currentUser;
        if (currentUser == null) return const SizedBox();

        return FutureBuilder<List<StudentTuition>>(
          future: Future.value(
            _studentService.getStudentTuitions(currentUser.username),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            final tuitionFees = snapshot.data ?? [];

            // Sort tuition fees by academic year (descending) then by semester (descending)
            tuitionFees.sort((a, b) {
              final periodA = _tuitionService.getTuitionPeriod(a.periodId);
              final periodB = _tuitionService.getTuitionPeriod(b.periodId);

              if (periodA == null || periodB == null) return 0;

              // First sort by academic year (descending)
              final yearCompare = periodB.academicYear.compareTo(
                periodA.academicYear,
              );
              if (yearCompare != 0) return yearCompare;

              // Then sort by semester (descending)
              return periodB.semester.compareTo(periodA.semester);
            });

            if (tuitionFees.isEmpty) {
              return const Center(child: Text('Không có thông tin học phí'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Học phí của tôi', style: AppTextStyles.heading3),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: tuitionFees.length,
                    itemBuilder: (context, index) {
                      final tuition = tuitionFees[index];
                      final period = _tuitionService.getTuitionPeriod(
                        tuition.periodId,
                      );
                      final status = period != null
                          ? tuition.getStatus(period)
                          : null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            period != null
                                ? 'Năm học ${period.academicYearDisplay} - Học kỳ ${period.semester}'
                                : 'Thông tin học kỳ không có',
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Số tiền: ${CurrencyFormatter.format(tuition.amount)}',
                                style: AppTextStyles.body1.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (period != null) ...[
                                Text(
                                  'Thời gian: ${DateFormatter.formatDate(period.startDate)} - ${DateFormatter.formatDate(period.dueDate)}',
                                  style: AppTextStyles.body2,
                                ),
                              ],
                              if (tuition.paidDate != null)
                                Text(
                                  'Đã nộp: ${DateFormatter.formatDate(tuition.paidDate!)}',
                                  style: AppTextStyles.body2.copyWith(
                                    color: Colors.green[700],
                                  ),
                                ),
                            ],
                          ),
                          trailing: status != null
                              ? _buildStatusChip(status)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionHistoryView() {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        final currentUser = authVM.currentUser;
        if (currentUser == null) return const SizedBox();

        final transactions = List<Transaction>.from(
          currentUser.transactionHistory,
        )..sort((a, b) => b.date.compareTo(a.date));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lịch sử thanh toán', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('Chưa có giao dịch nào'))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: _buildTransactionIcon(transaction.type),
                            title: Text(transaction.description),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ngày: ${DateFormatter.formatDateTime(transaction.date)}',
                                ),
                                if (transaction.studentName != null)
                                  Text('Sinh viên: ${transaction.studentName}'),
                              ],
                            ),
                            trailing: Text(
                              CurrencyFormatter.format(transaction.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    transaction.type == TransactionType.deposit
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(TuitionPaymentStatus status) {
    Color color;
    String text;

    switch (status) {
      case TuitionPaymentStatus.paid:
        color = Colors.green;
        text = 'Đã đóng';
        break;
      case TuitionPaymentStatus.pending:
        color = Colors.orange;
        text = 'Chưa đóng';
        break;
      case TuitionPaymentStatus.notDue:
        color = Colors.blue;
        text = 'Chưa đến hạn';
        break;
      case TuitionPaymentStatus.overdue:
        color = Colors.red;
        text = 'Quá hạn';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.tuitionPayment:
        return const Icon(Icons.school, color: Colors.orange);
      case TransactionType.deposit:
        return const Icon(Icons.add_circle, color: Colors.green);
      case TransactionType.withdrawal:
        return const Icon(Icons.remove_circle, color: Colors.red);
    }
  }
}
