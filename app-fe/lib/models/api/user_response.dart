import 'package:json_annotation/json_annotation.dart';

part 'user_response.g.dart';

@JsonSerializable()
class UserResponse {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final double balance;
  final String role;

  UserResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.balance,
    required this.role,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);

  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isUser => role.toUpperCase() == 'USER';
}
