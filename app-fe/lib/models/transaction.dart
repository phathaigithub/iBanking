enum TransactionType { tuitionPayment, deposit, withdrawal }

class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final TransactionType type;
  final String description;
  final String? studentId;
  final String? studentName;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    this.studentId,
    this.studentName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'type': type.name,
      'description': description,
      'studentId': studentId,
      'studentName': studentName,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: json['amount'].toDouble(),
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'],
      studentId: json['studentId'],
      studentName: json['studentName'],
    );
  }
}
