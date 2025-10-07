import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class TermsAndConditionsView extends StatelessWidget {
  const TermsAndConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều khoản và Điều kiện'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTitle('1. Giới thiệu'),
            _Paragraph(
              'Trang này mô tả điều khoản và điều kiện sử dụng chức năng thanh toán học phí qua hệ thống iBanking. Bằng việc tiếp tục, bạn xác nhận đã đọc, hiểu và đồng ý tuân thủ các điều khoản này.',
            ),
            _SectionTitle('2. Thông tin học phí'),
            _Paragraph(
              'Người dùng chịu trách nhiệm kiểm tra tính chính xác của thông tin học phí trước khi thanh toán (mã học phí, học kỳ, số tiền). Khoản thanh toán thực hiện sẽ được ghi nhận theo mã học phí đã cung cấp.',
            ),
            _SectionTitle('3. Bảo mật và OTP'),
            _Paragraph(
              'Hệ thống có thể yêu cầu xác thực OTP để hoàn tất giao dịch. Không chia sẻ mã OTP cho bất kỳ ai. Mọi rủi ro phát sinh do lộ OTP thuộc trách nhiệm của người dùng.',
            ),
            _SectionTitle('4. Phí và giới hạn giao dịch'),
            _Paragraph(
              'Một số giao dịch có thể phát sinh phí theo chính sách của ngân hàng. Giới hạn giao dịch và thời gian xử lý có thể thay đổi theo quy định hiện hành.',
            ),
            _SectionTitle('5. Hoàn/huỷ giao dịch'),
            _Paragraph(
              'Sau khi xác nhận, giao dịch không thể huỷ. Việc hoàn tiền (nếu có) tuỳ thuộc vào chính sách của nhà trường và ngân hàng, và có thể yêu cầu thời gian xử lý.',
            ),
            _SectionTitle('6. Trách nhiệm người dùng'),
            _Paragraph(
              'Bạn cam kết sử dụng dịch vụ đúng mục đích, cung cấp thông tin chính xác, và chịu trách nhiệm với mọi giao dịch thực hiện dưới tài khoản của mình.',
            ),
            _SectionTitle('7. Điều khoản khác'),
            _Paragraph(
              'Nhà cung cấp có quyền thay đổi điều khoản mà không cần thông báo trước. Tiếp tục sử dụng dịch vụ đồng nghĩa với việc bạn chấp nhận các thay đổi đó.',
            ),
            SizedBox(height: 16),
            _Paragraph(
              'Nếu bạn có câu hỏi, vui lòng liên hệ bộ phận hỗ trợ để được giải đáp.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
    );
  }
}
