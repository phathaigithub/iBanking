import 'package:flutter/material.dart';

/// Placeholder for Add Student View
/// TODO: Refactor this view to use Riverpod and backend API
class AddStudentView extends StatelessWidget {
  const AddStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm sinh viên mới')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Chức năng đang được phát triển',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Vui lòng chờ cập nhật từ backend API',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
