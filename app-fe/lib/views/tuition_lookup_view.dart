import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/tuition_inquiry_provider.dart';
import '../utils/app_theme.dart';

class TuitionLookupView extends ConsumerStatefulWidget {
  const TuitionLookupView({super.key});

  @override
  ConsumerState<TuitionLookupView> createState() => _TuitionLookupViewState();
}

class _TuitionLookupViewState extends ConsumerState<TuitionLookupView> {
  final _studentCodeController = TextEditingController();
  final _otpController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _studentCodeController.dispose();
    _otpController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inquiryState = ref.watch(tuitionInquiryProvider);

    // Listen for state changes to show/hide dialogs
    ref.listen<TuitionInquiryState>(tuitionInquiryProvider, (
      previous,
      current,
    ) {
      // Show OTP dialog when entering OTP verification step
      if (previous?.currentStep != InquiryStep.otpVerification &&
          current.currentStep == InquiryStep.otpVerification) {
        _showOtpDialog();
      }
      // Show result dialog when entering result step
      else if (previous?.currentStep != InquiryStep.result &&
          current.currentStep == InquiryStep.result) {
        Navigator.of(context).pop(); // Close OTP dialog if open
        _showResultDialog();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.search, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tra cứu học phí',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Function Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nhập mã số sinh viên để tra cứu thông tin học phí. OTP sẽ được gửi đến email sinh viên.',
                    style: TextStyle(fontSize: 14, color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Search Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tra cứu học phí sinh viên',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _studentCodeController,
                  decoration: InputDecoration(
                    labelText: 'Mã số sinh viên',
                    hintText: 'Nhập mã số sinh viên',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  ],
                  onChanged: (value) {
                    ref
                        .read(tuitionInquiryProvider.notifier)
                        .setStudentCode(value);
                  },
                ),
                if (inquiryState.error != null) ...[
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
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            inquiryState.error!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: inquiryState.isLoading
                        ? null
                        : () {
                            ref
                                .read(tuitionInquiryProvider.notifier)
                                .requestInquiry();
                          },
                    icon: inquiryState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                      inquiryState.isLoading ? 'Đang tra cứu...' : 'Tra cứu',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOtpDialog() {
    final inquiryState = ref.read(tuitionInquiryProvider);

    // Clear student code input for security
    _studentCodeController.clear();

    // Clear OTP fields
    _otpController.clear();
    for (var controller in _otpControllers) {
      controller.clear();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _OtpDialog(
        studentCode: inquiryState.studentCode,
        otpController: _otpController,
        otpControllers: _otpControllers,
        focusNodes: _focusNodes,
      ),
    );
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ResultDialog(),
    );
  }
}

// OTP Dialog Widget
class _OtpDialog extends ConsumerWidget {
  final String studentCode;
  final TextEditingController otpController;
  final List<TextEditingController> otpControllers;
  final List<FocusNode> focusNodes;

  const _OtpDialog({
    required this.studentCode,
    required this.otpController,
    required this.otpControllers,
    required this.focusNodes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiryState = ref.watch(tuitionInquiryProvider);

    // Auto-close dialog when timeout or max attempts exceeded
    if ((inquiryState.remainingSeconds <= 0 &&
            inquiryState.currentStep == InquiryStep.otpVerification) ||
        (inquiryState.error != null &&
            inquiryState.error!.contains('quá số lần cho phép'))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ref.read(tuitionInquiryProvider.notifier).reset();
      });
    }

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.lock_outline, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Xác thực OTP',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Message
              if (inquiryState.successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          inquiryState.successMessage!,
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Countdown Timer
              _CountdownTimer(),

              const SizedBox(height: 24),

              // OTP Input Field
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: otpController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    height: 1.2,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '------',
                    hintStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: Colors.grey[400],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    // Update individual controllers for compatibility
                    for (int i = 0; i < 6; i++) {
                      if (i < value.length) {
                        otpControllers[i].text = value[i];
                      } else {
                        otpControllers[i].clear();
                      }
                    }
                  },
                ),
              ),

              if (inquiryState.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          inquiryState.error!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: inquiryState.isLoading
                          ? null
                          : () {
                              ref
                                  .read(tuitionInquiryProvider.notifier)
                                  .backToSearch();
                              Navigator.of(context).pop();
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed:
                          inquiryState.isLoading ||
                              otpController.text.length != 6
                          ? null
                          : () {
                              ref
                                  .read(tuitionInquiryProvider.notifier)
                                  .verifyOtp(otpController.text);
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: inquiryState.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Xác thực'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Countdown Timer Widget
class _CountdownTimer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingSeconds = ref.watch(
      tuitionInquiryProvider.select((state) => state.remainingSeconds),
    );

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: remainingSeconds <= 30 ? Colors.orange[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 20,
            color: remainingSeconds <= 30
                ? Colors.orange[700]
                : Colors.grey[700],
          ),
          const SizedBox(width: 8),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: remainingSeconds <= 30
                  ? Colors.orange[700]
                  : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

// Result Dialog Widget
class _ResultDialog extends ConsumerWidget {
  const _ResultDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiryState = ref.watch(tuitionInquiryProvider);
    final result = inquiryState.inquiryResult;

    if (result == null) {
      return const SizedBox.shrink();
    }

    // Auto-close dialog when timeout
    if (inquiryState.remainingSeconds <= 0 &&
        inquiryState.currentStep == InquiryStep.result) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ref.read(tuitionInquiryProvider.notifier).reset();
      });
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with countdown
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Thông tin học phí',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _CountdownTimer(),
                  ],
                ),

                const SizedBox(height: 20),

                // Student Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Mã sinh viên:',
                        result.student.studentCode,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Họ và tên:', result.student.name),
                      const SizedBox(height: 8),
                      _buildInfoRow('Ngành:', result.student.majorName),
                      const SizedBox(height: 8),
                      _buildInfoRow('Email:', result.student.email),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tuitions List
                const Text(
                  'Lịch sử học phí:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (result.tuitions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Chưa có học phí nào'),
                    ),
                  )
                else
                  ...result.tuitions.map((tuition) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: tuition.isPaid
                                  ? Colors.green[200]!
                                  : Colors.orange[200]!,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tuition.semesterDisplay,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tuition.isPaid
                                          ? Colors.green[100]
                                          : Colors.orange[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      tuition.status,
                                      style: TextStyle(
                                        color: tuition.isPaid
                                            ? Colors.green[700]
                                            : Colors.orange[700],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Mã học phí: ${tuition.tuitionId}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Số tiền: ${currencyFormat.format(tuition.amount)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hạn đóng: ${_formatDate(tuition.dueDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 24,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: IconButton(
                              icon: Icon(
                                Icons.copy,
                                size: 18,
                                color: Colors.grey[700],
                              ),
                              tooltip: 'Sao chép mã học phí',
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: tuition.tuitionId),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã sao chép mã học phí'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                const SizedBox(height: 20),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(tuitionInquiryProvider.notifier).backToSearch();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
