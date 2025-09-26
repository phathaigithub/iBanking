class TuitionPaymentRequest {
  final String payerName;
  final String payerPhone;
  final String payerEmail;
  final String studentId;
  final String studentName;
  final String tuitionFeeId;
  final double tuitionAmount;
  final double availableBalance;

  TuitionPaymentRequest({
    required this.payerName,
    required this.payerPhone,
    required this.payerEmail,
    required this.studentId,
    required this.studentName,
    required this.tuitionFeeId,
    required this.tuitionAmount,
    required this.availableBalance,
  });

  bool get canPay => availableBalance >= tuitionAmount;
}
