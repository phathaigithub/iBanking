import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api/api_error.dart';
import '../services/api/api_client.dart';
import '../routes/auth_routes.dart';

/// Test widget để debug JSON parsing
class JsonParseTestWidget extends ConsumerStatefulWidget {
  const JsonParseTestWidget({super.key});

  @override
  ConsumerState<JsonParseTestWidget> createState() =>
      _JsonParseTestWidgetState();
}

class _JsonParseTestWidgetState extends ConsumerState<JsonParseTestWidget> {
  String? _testResult;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSON Parse Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testJsonParse,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test JSON Parse'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testApiCall,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test API Call'),
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

  Future<void> _testJsonParse() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      // Test JSON parsing với dữ liệu mẫu từ backend
      final testJson = {
        "status": 404,
        "errorCode": "USER_NOT_FOUND",
        "message": "User not found",
      };

      setState(() {
        _testResult =
            'Testing JSON Parse:\n'
            'Input JSON: $testJson\n\n';
      });

      final error = ApiError.fromJson(testJson);

      setState(() {
        _testResult =
            (_testResult ?? '') +
            'SUCCESS!\n'
                'Parsed ApiError:\n'
                'Status: ${error.status}\n'
                'ErrorCode: ${error.errorCode}\n'
                'Message: ${error.message}\n\n'
                'toString(): ${error.toString()}';
      });
    } catch (e) {
      setState(() {
        _testResult =
            (_testResult ?? '') +
            'FAILED!\n'
                'Error: $e\n'
                'Stack trace: ${StackTrace.current}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testApiCall() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      final apiClient = ApiClient();

      setState(() {
        _testResult =
            'Testing API Call:\n'
            'URL: ${AuthRoutes.login}\n\n';
      });

      // Test với thông tin sai để trigger error
      await apiClient.post(
        url: AuthRoutes.login,
        body: {'username': 'wrong_user', 'password': 'wrong_pass'},
      );

      setState(() {
        _testResult =
            (_testResult ?? '') +
            'UNEXPECTED: Should have thrown an exception!';
      });
    } on ApiException catch (e) {
      setState(() {
        _testResult =
            (_testResult ?? '') +
            'API EXCEPTION CAUGHT:\n'
                'Status: ${e.error.status}\n'
                'Error Code: ${e.error.errorCode}\n'
                'Message: ${e.error.message}\n\n'
                'toString(): ${e.toString()}';
      });
    } catch (e) {
      setState(() {
        _testResult = (_testResult ?? '') + 'GENERAL ERROR:\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
