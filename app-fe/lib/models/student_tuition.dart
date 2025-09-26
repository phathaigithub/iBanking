import 'tuition_payment_period.dart';

class StudentTuition {
  final String id;
  final String studentId;
  final String periodId; // Links to TuitionPaymentPeriod
  final double amount;
  final bool isPaid;
  final DateTime? paidDate;
  final String? transactionId;

  StudentTuition({
    required this.id,
    required this.studentId,
    required this.periodId,
    required this.amount,
    this.isPaid = false,
    this.paidDate,
    this.transactionId,
  });

  /// Get payment status based on period and payment state
  TuitionPaymentStatus getStatus(TuitionPaymentPeriod period) {
    if (isPaid) return TuitionPaymentStatus.paid;

    final now = DateTime.now();
    if (now.isBefore(period.startDate)) {
      return TuitionPaymentStatus.notDue;
    } else if (now.isAfter(period.dueDate)) {
      return TuitionPaymentStatus.overdue;
    } else {
      return TuitionPaymentStatus.pending;
    }
  }

  /// Check if the tuition is currently active (can be paid)
  bool isActiveForPeriod(TuitionPaymentPeriod period) {
    if (isPaid) return false;

    final status = getStatus(period);
    return status == TuitionPaymentStatus.pending ||
        status == TuitionPaymentStatus.overdue;
  }

  StudentTuition copyWith({
    String? id,
    String? studentId,
    String? periodId,
    double? amount,
    bool? isPaid,
    DateTime? paidDate,
    String? transactionId,
  }) {
    return StudentTuition(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      periodId: periodId ?? this.periodId,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'periodId': periodId,
      'amount': amount,
      'isPaid': isPaid,
      'paidDate': paidDate?.toIso8601String(),
      'transactionId': transactionId,
    };
  }

  factory StudentTuition.fromJson(Map<String, dynamic> json) {
    return StudentTuition(
      id: json['id'],
      studentId: json['studentId'],
      periodId: json['periodId'],
      amount: json['amount'].toDouble(),
      isPaid: json['isPaid'] ?? false,
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'])
          : null,
      transactionId: json['transactionId'],
    );
  }
}
