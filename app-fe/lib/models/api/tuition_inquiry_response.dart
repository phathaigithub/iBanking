import 'package:json_annotation/json_annotation.dart';

part 'tuition_inquiry_response.g.dart';

@JsonSerializable()
class TuitionInquiryResponse {
  final StudentInfo student;
  final List<TuitionInfo> tuitions;

  TuitionInquiryResponse({required this.student, required this.tuitions});

  factory TuitionInquiryResponse.fromJson(Map<String, dynamic> json) =>
      _$TuitionInquiryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TuitionInquiryResponseToJson(this);
}

@JsonSerializable()
class StudentInfo {
  final String studentCode;
  final String name;
  final String majorCode;
  final String majorName;
  final String email;

  StudentInfo({
    required this.studentCode,
    required this.name,
    required this.majorCode,
    required this.majorName,
    required this.email,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) =>
      _$StudentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$StudentInfoToJson(this);
}

@JsonSerializable()
class TuitionInfo {
  final String tuitionId;
  final String semester;
  final double amount;
  final String status;
  final String dueDate;
  final String createdAt;

  TuitionInfo({
    required this.tuitionId,
    required this.semester,
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.createdAt,
  });

  factory TuitionInfo.fromJson(Map<String, dynamic> json) =>
      _$TuitionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TuitionInfoToJson(this);

  // Helper getters
  bool get isPaid => status.toLowerCase().contains('đã thanh toán');
  bool get isUnpaid => status.toLowerCase().contains('chưa thanh toán');

  // Parse semester info similar to TuitionResponse
  int get semesterNumber {
    if (semester.isEmpty) return 1;

    if (semester.contains('-')) {
      final parts = semester.split('-');
      if (parts.isNotEmpty) {
        final semesterPart = parts[0].trim();
        final parsed = int.tryParse(semesterPart);
        if (parsed != null && parsed >= 1 && parsed <= 3) {
          return parsed;
        }
      }
    }

    if (semester.length >= 5) {
      final semesterPart = semester.substring(0, 1);
      final parsed = int.tryParse(semesterPart);
      if (parsed != null && parsed >= 1 && parsed <= 3) {
        return parsed;
      }
    }

    final regex = RegExp(r'[1-3]');
    final match = regex.firstMatch(semester);
    if (match != null) {
      return int.parse(match.group(0)!);
    }

    return 1;
  }

  int get academicYear {
    if (semester.isEmpty) return DateTime.now().year;

    if (semester.contains('-')) {
      final parts = semester.split('-');
      if (parts.length >= 2) {
        final yearPart = parts[1].trim();
        final parsed = int.tryParse(yearPart);
        if (parsed != null && parsed >= 2020 && parsed <= 2030) {
          return parsed;
        }
      }
    }

    if (semester.length >= 5) {
      final yearPart = semester.substring(1);
      final parsed = int.tryParse(yearPart);
      if (parsed != null && parsed >= 2020 && parsed <= 2030) {
        return parsed;
      }
    }

    final regex = RegExp(r'20[2-3][0-9]');
    final match = regex.firstMatch(semester);
    if (match != null) {
      return int.parse(match.group(0)!);
    }

    return DateTime.now().year;
  }

  String get semesterDisplay {
    if (semester.contains('HK') ||
        semester.contains('-') ||
        semester.contains('/')) {
      return semester;
    }

    if (RegExp(r'^\d+$').hasMatch(semester)) {
      return 'HK$semesterNumber/$academicYear';
    }

    return 'HK$semesterNumber-$academicYear';
  }
}
