import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api/add_student_request.dart';

/// State for Add Student Dialog
class AddStudentDialogState {
  final String studentCode;
  final String name;
  final int age;
  final String email;
  final String phone;
  final String? selectedMajorCode;
  final bool isLoading;
  final String? error;

  AddStudentDialogState({
    this.studentCode = '',
    this.name = '',
    this.age = 18,
    this.email = '',
    this.phone = '',
    this.selectedMajorCode,
    this.isLoading = false,
    this.error,
  });

  AddStudentDialogState copyWith({
    String? studentCode,
    String? name,
    int? age,
    String? email,
    String? phone,
    String? selectedMajorCode,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AddStudentDialogState(
      studentCode: studentCode ?? this.studentCode,
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      selectedMajorCode: selectedMajorCode ?? this.selectedMajorCode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isValid {
    return studentCode.length == 8 &&
        name.isNotEmpty &&
        age >= 15 &&
        age <= 80 &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        selectedMajorCode != null;
  }

  bool get hasAnyData {
    return studentCode.isNotEmpty ||
        name.isNotEmpty ||
        email.isNotEmpty ||
        phone.isNotEmpty ||
        selectedMajorCode != null;
  }
}

/// Notifier for Add Student Dialog
class AddStudentDialogNotifier extends StateNotifier<AddStudentDialogState> {
  AddStudentDialogNotifier() : super(AddStudentDialogState());

  void updateStudentCode(String value) {
    state = state.copyWith(studentCode: value);
  }

  void updateName(String value) {
    state = state.copyWith(name: value);
  }

  void updateAge(int value) {
    state = state.copyWith(age: value);
  }

  void incrementAge() {
    if (state.age < 80) {
      state = state.copyWith(age: state.age + 1);
    }
  }

  void decrementAge() {
    if (state.age > 15) {
      state = state.copyWith(age: state.age - 1);
    }
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value);
  }

  void updateSelectedMajor(String? majorCode) {
    state = state.copyWith(selectedMajorCode: majorCode);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = AddStudentDialogState();
  }

  AddStudentRequest toRequest() {
    return AddStudentRequest(
      studentCode: state.studentCode,
      name: state.name,
      age: state.age,
      email: state.email,
      phone: state.phone,
      majorCode: state.selectedMajorCode!,
    );
  }
}

/// Provider for Add Student Dialog
final addStudentDialogProvider =
    StateNotifierProvider<AddStudentDialogNotifier, AddStudentDialogState>(
      (ref) => AddStudentDialogNotifier(),
    );
