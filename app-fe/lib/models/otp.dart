class OTP {
  final String id;
  final String code;
  final DateTime expiryTime;
  final String transactionId;
  final bool isUsed;

  OTP({
    required this.id,
    required this.code,
    required this.expiryTime,
    required this.transactionId,
    this.isUsed = false,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);
  bool get isValid => !isUsed && !isExpired;

  OTP copyWith({
    String? id,
    String? code,
    DateTime? expiryTime,
    String? transactionId,
    bool? isUsed,
  }) {
    return OTP(
      id: id ?? this.id,
      code: code ?? this.code,
      expiryTime: expiryTime ?? this.expiryTime,
      transactionId: transactionId ?? this.transactionId,
      isUsed: isUsed ?? this.isUsed,
    );
  }
}
