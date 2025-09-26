import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tuition_management_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../utils/config.dart';

class TuitionManagementView extends StatefulWidget {
  const TuitionManagementView({Key? key}) : super(key: key);

  @override
  State<TuitionManagementView> createState() => _TuitionManagementViewState();
}

class _TuitionManagementViewState extends State<TuitionManagementView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TuitionManagementViewModel()..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tạo đợt đóng học phí'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
        body: Consumer<TuitionManagementViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNextPeriodInfo(viewModel),
                  const SizedBox(height: 24),
                  _buildStudentTuitionList(viewModel),
                  const SizedBox(height: 24),
                  _buildActionButtons(viewModel),
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(viewModel.errorMessage!),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNextPeriodInfo(TuitionManagementViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đợt đóng học phí tiếp theo', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            _buildAcademicYearSelector(viewModel),
            const SizedBox(height: 16),
            _buildSemesterField(viewModel),
            const SizedBox(height: 16),
            _buildDateFields(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicYearSelector(TuitionManagementViewModel viewModel) {
    final availableYears = viewModel.getAvailableAcademicYears();

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            'Năm học:',
            style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: viewModel.nextAcademicYear,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: availableYears.map((year) {
              return DropdownMenuItem<int>(
                value: year,
                child: Text('$year-${year + 1}'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.updateAcademicYear(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterField(TuitionManagementViewModel viewModel) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            'Học kỳ:',
            style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: TextFormField(
            initialValue: viewModel.nextSemester?.toString() ?? '',
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: 'Nhập học kỳ (1, 2, 3...)',
            ),
            onChanged: (value) {
              final semester = int.tryParse(value);
              if (semester != null) {
                viewModel.updateSemester(semester);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateFields(TuitionManagementViewModel viewModel) {
    return Column(
      children: [
        _buildDateField(
          'Ngày bắt đầu:',
          viewModel.nextStartDate,
          (date) => viewModel.updateStartDate(date),
        ),
        const SizedBox(height: 12),
        _buildDateField(
          'Ngày hết hạn:',
          viewModel.nextDueDate,
          (date) => viewModel.updateDueDate(date),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? DateFormatter.formatDate(selectedDate)
                          : 'Chọn ngày',
                      style: selectedDate != null
                          ? AppTextStyles.body1
                          : AppTextStyles.body1.copyWith(
                              color: Colors.grey[600],
                            ),
                    ),
                  ),
                  Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentTuitionList(TuitionManagementViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danh sách sinh viên và học phí',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 16),
            ...viewModel.students.map((student) {
              final currentAmount =
                  viewModel.studentTuitionAmounts[student.studentId] ??
                  AppConfig.defaultTuitionFee;
              return _buildStudentTuitionRow(
                viewModel,
                student.studentId,
                student.fullName,
                currentAmount,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTuitionRow(
    TuitionManagementViewModel viewModel,
    String studentId,
    String studentName,
    double currentAmount,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studentName, style: AppTextStyles.body1),
                Text('MSSV: $studentId', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: CurrencyFormatter.formatWithoutSymbol(
                currentAmount,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Học phí',
                suffixText: 'VND',
                isDense: true,
              ),
              onChanged: (value) {
                final amount = double.tryParse(value.replaceAll(',', '')) ?? 0;
                viewModel.updateStudentTuitionAmount(studentId, amount);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TuitionManagementViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: viewModel.isLoading
                ? null
                : () => _showSaveConfirmationDialog(viewModel),
            icon: viewModel.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              viewModel.isLoading ? 'Đang xử lý...' : 'Lưu và ban hành',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  Future<void> _showSaveConfirmationDialog(
    TuitionManagementViewModel viewModel,
  ) async {
    // Validate required fields
    if (viewModel.nextAcademicYear == null ||
        viewModel.nextSemester == null ||
        viewModel.nextStartDate == null ||
        viewModel.nextDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin kỳ học'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận ban hành'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc chắn muốn ban hành đợt đóng học phí sau:'),
            const SizedBox(height: 8),
            Text('• Năm học: ${viewModel.nextAcademicYearDisplay}'),
            Text('• Học kỳ: ${viewModel.nextSemester}'),
            Text(
              '• Thời hạn: ${DateFormatter.formatDate(viewModel.nextStartDate!)} - ${DateFormatter.formatDate(viewModel.nextDueDate!)}',
            ),
            const SizedBox(height: 8),
            const Text(
              'Sau khi ban hành, sinh viên sẽ có thể thanh toán học phí trong thời gian quy định.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await viewModel.createNewTuitionPeriod();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ban hành đợt đóng học phí thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return success to admin dashboard
      }
    }
  }
}
