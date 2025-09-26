class Validators {
  /// Validates email format
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Validates Vietnamese phone number
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$').hasMatch(phone);
  }

  /// Validates student ID (8 characters)
  static bool isValidStudentId(String studentId) {
    return RegExp(r'^[a-zA-Z0-9]{8}$').hasMatch(studentId);
  }

  /// Validates password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
