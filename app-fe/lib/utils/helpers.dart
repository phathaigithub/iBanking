import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatWithoutSymbol(double amount) {
    return NumberFormat('#,###', 'vi_VN').format(amount);
  }
}

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}

class Validators {
  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mã số sinh viên';
    }
    if (value.length != 8) {
      return 'Mã số sinh viên phải có 8 ký tự';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Mã số sinh viên chỉ được chứa số';
    }
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mã OTP';
    }
    if (value.length != 6) {
      return 'Mã OTP phải có 6 ký tự';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Mã OTP chỉ được chứa số';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    return null;
  }
}
