import 'package:json_annotation/json_annotation.dart';

part 'payment_history_response.g.dart';

@JsonSerializable()
class PaymentHistoryResponse {
  final int id;
  final int paymentId;
  final String tuitionCode;
  final double amount;
  final String status;
  final String message;
  final String createdAt;
  final double tuitionAmount;
  final String semester;

  PaymentHistoryResponse({
    required this.id,
    required this.paymentId,
    required this.tuitionCode,
    required this.amount,
    required this.status,
    required this.message,
    required this.createdAt,
    required this.tuitionAmount,
    required this.semester,
  });

  factory PaymentHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentHistoryResponseToJson(this);

  // Helper getters
  bool get isSuccess => status == 'SUCCESS';
  bool get isPending => status == 'PENDING';
  bool get isFailed => status == 'FAILED';

  DateTime get createdDate => DateTime.parse(createdAt);

  // Semester display
  String get semesterDisplay {
    if (semester.isEmpty) return '';

    // Format: "12025" -> "HK1/2025"
    if (semester.length >= 5) {
      final semesterNum = semester.substring(0, 1);
      final year = semester.substring(1);
      return 'HK$semesterNum/$year';
    }

    return semester;
  }
}
