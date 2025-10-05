import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/create_tuition_period_provider.dart';
import '../providers/admin_tuition_provider.dart';
import '../providers/admin_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/major_icon.dart';

class CreateTuitionPeriodView extends ConsumerStatefulWidget {
  const CreateTuitionPeriodView({super.key});

  @override
  ConsumerState<CreateTuitionPeriodView> createState() =>
      _CreateTuitionPeriodViewState();
}

class _CreateTuitionPeriodViewState
    extends ConsumerState<CreateTuitionPeriodView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize amount controller with default value
    _amountController.text = '15000000';
    // Load majors when the view is initialized
    Future.microtask(() {
      final notifier = ref.read(createTuitionPeriodProvider.notifier);
      notifier.loadMajors();
      // Set success callback to switch to tuition tab
      notifier.setOnSuccessCallback(() {
        // Switch to tuition tab and set view mode to "all"
        ref.read(adminDashboardProvider.notifier).setTab(AdminViewTab.tuition);
        ref
            .read(adminTuitionProvider.notifier)
            .setViewMode(TuitionViewMode.all);
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createTuitionPeriodProvider);
    final notifier = ref.read(createTuitionPeriodProvider.notifier);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 36,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Tạo đợt đóng học phí',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tạo đợt đóng học phí mới cho sinh viên theo ngành học',
                  style: AppTextStyles.body1.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                // Form Card
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin đợt đóng học phí',
                              style: AppTextStyles.heading2,
                            ),
                            const SizedBox(height: 32),

                            // Form Fields in Grid Layout
                            Expanded(
                              child: Column(
                                children: [
                                  // First Row: Academic Year and Semester
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildAcademicYearField(state),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: _buildSemesterField(
                                          state,
                                          notifier,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Second Row: Major and Due Date
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildMajorField(
                                          state,
                                          notifier,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: _buildDueDateField(
                                          state,
                                          notifier,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Third Row: Tuition Amount (Full Width)
                                  _buildTuitionAmountField(state, notifier),
                                  const SizedBox(height: 40),

                                  // Action Buttons
                                  _buildActionButtons(state, notifier),

                                  // Messages
                                  if (state.error != null) ...[
                                    const SizedBox(height: 20),
                                    _buildErrorMessage(state.error!),
                                  ],

                                  if (state.isSuccess) ...[
                                    const SizedBox(height: 20),
                                    _buildSuccessMessage(),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAcademicYearField(CreateTuitionPeriodState state) {
    return TextFormField(
      initialValue: state.academicYear.toString(),
      decoration: const InputDecoration(
        labelText: 'Năm học',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: Icon(Icons.lock, color: Colors.grey),
      ),
      readOnly: true,
      style: TextStyle(color: Colors.grey[600]),
    );
  }

  Widget _buildSemesterField(
    CreateTuitionPeriodState state,
    CreateTuitionPeriodNotifier notifier,
  ) {
    return DropdownButtonFormField<int>(
      initialValue: state.selectedSemester,
      decoration: const InputDecoration(
        labelText: 'Học kỳ',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.school),
      ),
      items: const [
        DropdownMenuItem(value: 1, child: Text('Học kỳ 1')),
        DropdownMenuItem(value: 2, child: Text('Học kỳ 2')),
        DropdownMenuItem(value: 3, child: Text('Học kỳ 3')),
      ],
      onChanged: (value) {
        if (value != null) {
          notifier.setSelectedSemester(value);
        }
      },
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn học kỳ';
        }
        return null;
      },
    );
  }

  Widget _buildMajorField(
    CreateTuitionPeriodState state,
    CreateTuitionPeriodNotifier notifier,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: state.selectedMajorCode,
      decoration: const InputDecoration(
        labelText: 'Ngành học',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      hint: const Text('Chọn ngành học'),
      items: state.majors.map((major) {
        return DropdownMenuItem<String>(
          value: major.code,
          child: Row(
            children: [
              MajorIcon(majorCode: major.code, size: 20),
              const SizedBox(width: 12),
              Text(major.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        notifier.setSelectedMajor(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn ngành học';
        }
        return null;
      },
    );
  }

  Widget _buildTuitionAmountField(
    CreateTuitionPeriodState state,
    CreateTuitionPeriodNotifier notifier,
  ) {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Số tiền học phí',
        hintText: 'Nhập số tiền học phí',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.attach_money),
        suffixText: '₫',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số tiền học phí';
        }
        final amount = double.tryParse(value.replaceAll(',', ''));
        if (amount == null || amount <= 0) {
          return 'Số tiền phải lớn hơn 0';
        }
        return null;
      },
      onChanged: (value) {
        final amount = double.tryParse(value.replaceAll(',', ''));
        if (amount != null) {
          notifier.setTuitionAmount(amount);
        }
      },
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        ThousandsSeparatorInputFormatter(),
      ],
    );
  }

  Widget _buildDueDateField(
    CreateTuitionPeriodState state,
    CreateTuitionPeriodNotifier notifier,
  ) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Hạn đóng học phí',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.event),
        hintText: 'Chọn ngày hạn đóng',
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () => _selectDate(notifier),
        ),
      ),
      controller: TextEditingController(
        text: _selectedDate != null
            ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
            : '',
      ),
      validator: (value) {
        if (_selectedDate == null) {
          return 'Vui lòng chọn hạn đóng học phí';
        }
        final minDate = DateTime.now().add(const Duration(days: 7));
        if (_selectedDate!.isBefore(minDate)) {
          return 'Hạn đóng phải sau ít nhất 1 tuần kể từ hôm nay';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons(
    CreateTuitionPeriodState state,
    CreateTuitionPeriodNotifier notifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 160,
          child: OutlinedButton.icon(
            onPressed: state.isLoading ? null : () => _handleReset(notifier),
            icon: const Icon(Icons.refresh),
            label: const Text('Làm mới'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 160,
          child: ElevatedButton.icon(
            onPressed: state.isLoading ? null : () => _handleSubmit(notifier),
            icon: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(state.isLoading ? 'Đang xử lý...' : 'Ban hành'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tạo đợt đóng học phí thành công!',
              style: TextStyle(color: Colors.green[600]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(CreateTuitionPeriodNotifier notifier) async {
    final minDate = DateTime.now().add(const Duration(days: 7));
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: minDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
      notifier.setDueDate(selectedDate);
    }
  }

  Future<void> _handleSubmit(CreateTuitionPeriodNotifier notifier) async {
    if (!_formKey.currentState!.validate()) return;

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    final success = await notifier.createTuitionPeriod();

    if (success) {
      // Refresh tuition data if admin tuition provider is initialized
      try {
        final adminTuitionNotifier = ref.read(adminTuitionProvider.notifier);
        await adminTuitionNotifier.refreshTuitions();
      } catch (e) {
        // Admin tuition provider might not be initialized yet
        // Could not refresh tuition data: $e
      }

      // Reset form after success
      Future.delayed(const Duration(seconds: 2), () {
        _handleReset(notifier);
      });
    }
  }

  Future<bool> _showConfirmationDialog() async {
    final state = ref.read(createTuitionPeriodProvider);
    final major = state.majors.firstWhere(
      (m) => m.code == state.selectedMajorCode,
      orElse: () => throw Exception('Major not found'),
    );

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                const Text('Xác nhận tạo đợt đóng học phí'),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn có chắc chắn muốn tạo đợt đóng học phí với thông tin sau?',
                    style: AppTextStyles.body1,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        _buildConfirmationRow(
                          'Năm học:',
                          state.academicYear.toString(),
                        ),
                        _buildConfirmationRow(
                          'Học kỳ:',
                          'Học kỳ ${state.selectedSemester}',
                        ),
                        _buildConfirmationRow('Ngành học:', major.name),
                        _buildConfirmationRow(
                          'Hạn đóng:',
                          state.formattedDueDate,
                        ),
                        _buildConfirmationRow(
                          'Số tiền:',
                          '${NumberFormat('#,##0').format(state.tuitionAmount)} ₫',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
        ) ??
        false;
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleReset(CreateTuitionPeriodNotifier notifier) {
    setState(() {
      _selectedDate = null;
    });
    notifier.resetForm();
    _amountController.text = '15000000';
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Add thousands separators
    String formatted = _addThousandsSeparator(digitsOnly);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addThousandsSeparator(String value) {
    if (value.length <= 3) return value;

    String result = '';
    int count = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = ',$result';
        count = 0;
      }
      result = value[i] + result;
      count++;
    }

    return result;
  }
}
