import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class TuitionLookupView extends ConsumerStatefulWidget {
  const TuitionLookupView({super.key});

  @override
  ConsumerState<TuitionLookupView> createState() => _TuitionLookupViewState();
}

class _TuitionLookupViewState extends ConsumerState<TuitionLookupView> {
  final _studentIdController = TextEditingController();

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Center(child: Text('Không có thông tin người dùng'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tra cứu học phí sinh viên', style: AppTextStyles.heading2),
          const SizedBox(height: 24),

          // Search Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tra cứu thông tin', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Mã số sinh viên',
                      hintText: 'Nhập mã số sinh viên (8 ký tự)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Chức năng đang được phát triển. Vui lòng liên hệ với backend để tích hợp API.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Tra cứu'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Info message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Lưu ý:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '• Chức năng tra cứu đang được tích hợp với backend\n'
                  '• API endpoints đang được phát triển\n'
                  '• Vui lòng chờ cập nhật',
                  style: TextStyle(color: Colors.blue[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
