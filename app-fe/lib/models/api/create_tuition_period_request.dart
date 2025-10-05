import 'package:json_annotation/json_annotation.dart';

part 'create_tuition_period_request.g.dart';

@JsonSerializable()
class CreateTuitionPeriodRequest {
  final String semester;
  final String majorCode;
  final double amount;
  final String dueDate;

  CreateTuitionPeriodRequest({
    required this.semester,
    required this.majorCode,
    required this.amount,
    required this.dueDate,
  });

  factory CreateTuitionPeriodRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTuitionPeriodRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTuitionPeriodRequestToJson(this);
}
