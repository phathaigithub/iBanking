import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tui_ibank/providers/add_student_dialog_provider.dart';
import 'package:tui_ibank/providers/admin_provider.dart';
import 'package:tui_ibank/services/api/student_api_service.dart';
import 'package:tui_ibank/services/api/api_client.dart';
import 'package:tui_ibank/models/major.dart';
import 'package:tui_ibank/widgets/major_icon.dart';
import 'package:tui_ibank/widgets/refresh_button.dart';

/// Add Student Dialog Widget - Single Responsibility Principle
class AddStudentDialog extends ConsumerStatefulWidget {
  const AddStudentDialog({super.key});

  @override
  ConsumerState<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends ConsumerState<AddStudentDialog> {
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialogState = ref.watch(addStudentDialogProvider);
    final majors = ref.watch(
      adminDashboardProvider.select((state) => state.majors),
    );
    final isLoadingMajors = ref.watch(
      adminDashboardProvider.select((state) => state.isLoadingMajors),
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Thêm sinh viên mới'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStudentCodeField(ref, dialogState),
              const SizedBox(height: 12),
              _buildNameField(ref, dialogState),
              const SizedBox(height: 12),
              _buildAgeField(ref, dialogState),
              const SizedBox(height: 12),
              _buildEmailField(ref, dialogState),
              const SizedBox(height: 12),
              _buildPhoneField(ref, dialogState),
              const SizedBox(height: 12),
              _buildMajorDropdown(ref, dialogState, majors, isLoadingMajors),
              if (dialogState.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dialogState.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _handleClearData(context, ref, dialogState),
          child: const Text('Xóa dữ liệu'),
        ),
        ElevatedButton(
          onPressed: dialogState.isValid && !dialogState.isLoading
              ? () => _handleAdd(context, ref)
              : null,
          child: dialogState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Thêm'),
        ),
      ],
    );
  }

  Widget _buildStudentCodeField(WidgetRef ref, AddStudentDialogState state) {
    return TextFormField(
      initialValue: state.studentCode,
      decoration: const InputDecoration(
        labelText: 'Mã số sinh viên',
        hintText: 'Nhập 8 ký tự',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.badge),
      ),
      maxLength: 8,
      onChanged: (value) {
        ref.read(addStudentDialogProvider.notifier).updateStudentCode(value);
        ref.read(addStudentDialogProvider.notifier).clearError();
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập mã số sinh viên';
        }
        if (value.length != 8) {
          return 'Mã số sinh viên phải có đúng 8 ký tự';
        }
        return null;
      },
    );
  }

  Widget _buildNameField(WidgetRef ref, AddStudentDialogState state) {
    return TextFormField(
      initialValue: state.name,
      decoration: const InputDecoration(
        labelText: 'Tên sinh viên',
        hintText: 'Nhập họ và tên',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      onChanged: (value) {
        ref.read(addStudentDialogProvider.notifier).updateName(value);
        ref.read(addStudentDialogProvider.notifier).clearError();
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập tên sinh viên';
        }
        return null;
      },
    );
  }

  Widget _buildAgeField(WidgetRef ref, AddStudentDialogState state) {
    // Update controller when state changes
    if (_ageController.text != state.age.toString()) {
      _ageController.text = state.age.toString();
    }

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: 'Tuổi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cake),
            ),
            keyboardType: TextInputType.number,
            readOnly: true,
            onTap: () {
              // Show number picker dialog
              _showAgePicker(ref, state.age);
            },
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            IconButton(
              onPressed: () {
                ref.read(addStudentDialogProvider.notifier).incrementAge();
                ref.read(addStudentDialogProvider.notifier).clearError();
              },
              icon: const Icon(Icons.add),
              tooltip: 'Tăng tuổi',
            ),
            IconButton(
              onPressed: () {
                ref.read(addStudentDialogProvider.notifier).decrementAge();
                ref.read(addStudentDialogProvider.notifier).clearError();
              },
              icon: const Icon(Icons.remove),
              tooltip: 'Giảm tuổi',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField(WidgetRef ref, AddStudentDialogState state) {
    return TextFormField(
      initialValue: state.email,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'example@email.com',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        ref.read(addStudentDialogProvider.notifier).updateEmail(value);
        ref.read(addStudentDialogProvider.notifier).clearError();
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Email không hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(WidgetRef ref, AddStudentDialogState state) {
    return TextFormField(
      initialValue: state.phone,
      decoration: const InputDecoration(
        labelText: 'Số điện thoại',
        hintText: '0987654321',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.phone),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onChanged: (value) {
        ref.read(addStudentDialogProvider.notifier).updatePhone(value);
        ref.read(addStudentDialogProvider.notifier).clearError();
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số điện thoại';
        }
        if (!RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$').hasMatch(value)) {
          return 'Số điện thoại không hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildMajorDropdown(
    WidgetRef ref,
    AddStudentDialogState state,
    List<Major> majors,
    bool isLoadingMajors,
  ) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: state.selectedMajorCode,
            decoration: const InputDecoration(
              labelText: 'Ngành học',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.school),
            ),
            hint: const Text('Chọn ngành học'),
            items: majors.map((major) {
              return DropdownMenuItem<String>(
                value: major.code,
                child: IntrinsicWidth(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MajorIcon(majorCode: major.code, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              major.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              major.code,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            selectedItemBuilder: (BuildContext context) {
              return majors.map<Widget>((major) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    major.name,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList();
            },
            onChanged: (value) {
              ref
                  .read(addStudentDialogProvider.notifier)
                  .updateSelectedMajor(value);
              ref.read(addStudentDialogProvider.notifier).clearError();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng chọn ngành học';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8),
        RefreshButton(
          isLoading: isLoadingMajors,
          onPressed: () {
            ref.read(adminDashboardProvider.notifier).loadMajors();
          },
          tooltip: 'Làm mới danh sách ngành học',
        ),
      ],
    );
  }

  void _showAgePicker(WidgetRef ref, int currentAge) {
    // This could be enhanced with a proper number picker dialog
    // For now, we'll use the increment/decrement buttons
  }

  void _handleClearData(
    BuildContext context,
    WidgetRef ref,
    AddStudentDialogState state,
  ) {
    if (state.hasAnyData) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa tất cả dữ liệu đã nhập?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                ref.read(addStudentDialogProvider.notifier).reset();
              },
              child: const Text('Xóa'),
            ),
          ],
        ),
      );
    } else {
      // No data to clear, just show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có dữ liệu để xóa'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleAdd(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(addStudentDialogProvider.notifier);
    final request = notifier.toRequest();

    notifier.setLoading(true);
    notifier.clearError();

    try {
      // Create API service and call API
      final apiClient = ApiClient();
      final studentApiService = StudentApiService(apiClient: apiClient);

      await studentApiService.createStudentDetail(request);

      // Refresh students list
      ref.read(adminDashboardProvider.notifier).loadStudents();

      if (context.mounted) {
        Navigator.of(context).pop();
        notifier.reset();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm sinh viên thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      notifier.setError('Không thể thêm sinh viên: ${e.toString()}');
    } finally {
      notifier.setLoading(false);
    }
  }
}
