import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api/auth_api_service.dart';
import '../services/api/api_client.dart';
import '../routes/auth_routes.dart';

/// Test widget để kiểm tra API call trực tiếp
class ApiTestWidget extends ConsumerStatefulWidget {
  const ApiTestWidget({super.key});

  @override
  ConsumerState<ApiTestWidget> createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends ConsumerState<ApiTestWidget> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _testResult;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test Login'),
            ),
            const SizedBox(height: 16),
            if (_testResult != null)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _testResult!,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      final authService = AuthApiService();

      // Test direct API call
      final result = await authService.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      setState(() {
        _testResult = 'SUCCESS!\nToken: ${result.token}';
      });
    } on ApiException catch (e) {
      setState(() {
        _testResult =
            'API EXCEPTION:\n'
            'Status: ${e.error.status}\n'
            'Error Code: ${e.error.errorCode}\n'
            'Message: ${e.error.message}\n'
            'URL: ${AuthRoutes.login}';
      });
    } catch (e) {
      setState(() {
        _testResult = 'GENERAL ERROR:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
