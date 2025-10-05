import 'package:json_annotation/json_annotation.dart';

part 'api_error.g.dart';

@JsonSerializable()
class ApiError {
  final int status;
  final String errorCode;
  final String message;

  ApiError({
    required this.status,
    required this.errorCode,
    required this.message,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  @override
  String toString() => '$message ($status, $errorCode)';
}
