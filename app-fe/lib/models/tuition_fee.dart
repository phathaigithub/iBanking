class TuitionFee {
  final String id;
  final String semester;
  final String academicYear;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? transactionId;

  TuitionFee({
    required this.id,
    required this.semester,
    required this.academicYear,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    this.transactionId,
  });

  TuitionFee copyWith({
    String? id,
    String? semester,
    String? academicYear,
    double? amount,
    DateTime? dueDate,
    DateTime? paidDate,
    String? transactionId,
  }) {
    return TuitionFee(
      id: id ?? this.id,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semester': semester,
      'academicYear': academicYear,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'transactionId': transactionId,
    };
  }

  factory TuitionFee.fromJson(Map<String, dynamic> json) {
    return TuitionFee(
      id: json['id'],
      semester: json['semester'],
      academicYear: json['academicYear'],
      amount: json['amount'].toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'])
          : null,
      transactionId: json['transactionId'],
    );
  }
}
