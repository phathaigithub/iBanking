import 'package:json_annotation/json_annotation.dart';

part 'tuition_response.g.dart';

@JsonSerializable()
class TuitionResponse {
  final String tuitionCode;
  final String studentCode;
  final String semester;
  final double amount;
  final String status;

  TuitionResponse({
    required this.tuitionCode,
    required this.studentCode,
    required this.semester,
    required this.amount,
    required this.status,
  });

  factory TuitionResponse.fromJson(Map<String, dynamic> json) =>
      _$TuitionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TuitionResponseToJson(this);

  // Helper getters
  bool get isPaid => status.toLowerCase().contains('đã thanh toán');
  bool get isUnpaid => status.toLowerCase().contains('chưa thanh toán');

  // Parse semester info
  int get semesterNumber {
    if (semester.isEmpty) return 1;

    // Try to extract semester number from different formats
    // Format 1: "1-2025" or "2-2025"
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

    // Format 2: "12025" or "22025" (semester + year)
    if (semester.length >= 5) {
      final semesterPart = semester.substring(0, 1);
      final parsed = int.tryParse(semesterPart);
      if (parsed != null && parsed >= 1 && parsed <= 3) {
        return parsed;
      }
    }

    // Format 3: Try to find a number in the string
    final regex = RegExp(r'[1-3]');
    final match = regex.firstMatch(semester);
    if (match != null) {
      return int.parse(match.group(0)!);
    }

    // Default fallback
    return 1;
  }

  int get academicYear {
    if (semester.isEmpty) return DateTime.now().year;

    // Try to extract year from different formats
    // Format 1: "1-2025" or "2-2025"
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

    // Format 2: "12025" or "22025" (semester + year)
    if (semester.length >= 5) {
      final yearPart = semester.substring(1);
      final parsed = int.tryParse(yearPart);
      if (parsed != null && parsed >= 2020 && parsed <= 2030) {
        return parsed;
      }
    }

    // Format 3: Try to find a 4-digit year in the string
    final regex = RegExp(r'20[2-3][0-9]');
    final match = regex.firstMatch(semester);
    if (match != null) {
      return int.parse(match.group(0)!);
    }

    // Default fallback
    return DateTime.now().year;
  }

  String get semesterDisplay {
    // If semester is already formatted or contains readable separators, use it directly
    if (semester.contains('HK') ||
        semester.contains('-') ||
        semester.contains('/')) {
      return semester;
    }

    // Check if semester is all numbers (e.g., "32025")
    if (RegExp(r'^\d+$').hasMatch(semester)) {
      return 'HK$semesterNumber/$academicYear';
    }

    // Otherwise, format it as HK{Semester}-{Year}
    return 'HK$semesterNumber-$academicYear';
  }
}
