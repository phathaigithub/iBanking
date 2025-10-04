import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api/tuition_response.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class TuitionTable extends ConsumerWidget {
  final List<TuitionResponse> tuitions;
  final bool isLoading;
  final String? error;

  const TuitionTable({
    super.key,
    required this.tuitions,
    required this.isLoading,
    this.error,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Lỗi tải dữ liệu',
                style: AppTextStyles.heading3.copyWith(color: Colors.red[700]),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: AppTextStyles.body2.copyWith(color: Colors.red[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (tuitions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Không có dữ liệu học phí',
                style: AppTextStyles.heading3.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Chưa có học phí nào được tìm thấy',
                style: AppTextStyles.body2.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              _buildHeaderCell('STT', 60),
              _buildHeaderCell('Mã học phí', 150),
              _buildHeaderCell('Mã sinh viên', 120),
              _buildHeaderCell('Học kỳ', 120),
              _buildHeaderCell('Số tiền', 150),
              _buildHeaderCell('Trạng thái', 150),
            ],
          ),
        ),
        const Divider(height: 1),
        // Table Content
        Expanded(
          child: ListView.separated(
            itemCount: tuitions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tuition = tuitions[index];
              return _buildTuitionRow(tuition, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTuitionRow(TuitionResponse tuition, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildCell(index.toString(), 60),
          _buildCell(tuition.tuitionCode, 150),
          _buildCell(tuition.studentCode, 120),
          _buildCell(tuition.semesterDisplay, 120),
          _buildAmountCell(tuition.amount, 150),
          _buildStatusCell(tuition.status, 150),
        ],
      ),
    );
  }

  Widget _buildCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAmountCell(double amount, double width) {
    return SizedBox(
      width: width,
      child: Text(
        CurrencyFormatter.format(amount),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusCell(String status, double width) {
    return SizedBox(width: width, child: _buildStatusChip(status));
  }

  Widget _buildStatusChip(String status) {
    final isPaid = status.toLowerCase().contains('đã thanh toán');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            size: 14,
            color: isPaid ? Colors.green[700] : Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isPaid ? Colors.green[700] : Colors.orange[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
