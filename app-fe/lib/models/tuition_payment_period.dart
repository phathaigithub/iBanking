enum TuitionPaymentStatus {
  notDue, // Chưa đến hạn đóng
  pending, // Chưa đóng (trong hạn)
  overdue, // Quá hạn đóng
  paid, // Đã đóng
}

class TuitionPaymentPeriod {
  final String id;
  final int academicYear; // Năm học (VD: 2025 means 2025-2026)
  final int semester; // Học kỳ (1, 2, 3)
  final DateTime startDate; // Ngày bắt đầu có thể đóng
  final DateTime dueDate; // Hạn cuối đóng
  final DateTime createdAt; // Ngày ban hành
  final bool isActive; // Đợt đóng có đang hoạt động không

  TuitionPaymentPeriod({
    required this.id,
    required this.academicYear,
    required this.semester,
    required this.startDate,
    required this.dueDate,
    required this.createdAt,
    this.isActive = true,
  });

  /// Get the academic year display string (e.g., "2025-2026")
  String get academicYearDisplay => '$academicYear-${academicYear + 1}';

  /// Get semester display string
  String get semesterDisplay => 'Học kỳ $semester';

  /// Get full period display string
  String get fullDisplay => '$semesterDisplay - $academicYearDisplay';

  /// Check if this period is currently open for payment
  bool get isOpenForPayment {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate.subtract(const Duration(days: 1))) &&
        now.isBefore(dueDate.add(const Duration(days: 1)));
  }

  /// Check if this period is overdue
  bool get isOverdue {
    final now = DateTime.now();
    return isActive && now.isAfter(dueDate);
  }

  TuitionPaymentPeriod copyWith({
    String? id,
    int? academicYear,
    int? semester,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return TuitionPaymentPeriod(
      id: id ?? this.id,
      academicYear: academicYear ?? this.academicYear,
      semester: semester ?? this.semester,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academicYear': academicYear,
      'semester': semester,
      'startDate': startDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory TuitionPaymentPeriod.fromJson(Map<String, dynamic> json) {
    return TuitionPaymentPeriod(
      id: json['id'],
      academicYear: json['academicYear'],
      semester: json['semester'],
      startDate: DateTime.parse(json['startDate']),
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}
