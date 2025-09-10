import 'transaction.dart';

class User {
  final String id;
  final String username;
  final String fullName;
  final String phoneNumber;
  final String email;
  double availableBalance;
  final List<Transaction> transactionHistory;
  final bool isAdmin;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.availableBalance,
    required this.transactionHistory,
    this.isAdmin = false,
  });

  // Extract student ID from email (e.g., "52200001@student.tdtu.edu.vn" -> "52200001")
  String? get studentId {
    if (email.contains('@student.tdtu.edu.vn')) {
      return email.split('@')[0];
    }
    return null;
  }

  User copyWith({
    String? id,
    String? username,
    String? fullName,
    String? phoneNumber,
    String? email,
    double? availableBalance,
    List<Transaction>? transactionHistory,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      availableBalance: availableBalance ?? this.availableBalance,
      transactionHistory: transactionHistory ?? this.transactionHistory,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'availableBalance': availableBalance,
      'transactionHistory': transactionHistory.map((t) => t.toJson()).toList(),
      'isAdmin': isAdmin,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      availableBalance: json['availableBalance'].toDouble(),
      transactionHistory: (json['transactionHistory'] as List<dynamic>)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      isAdmin: json['isAdmin'] ?? false,
    );
  }
}
