import 'package:json_annotation/json_annotation.dart';

part 'create_tuition_period_response.g.dart';

@JsonSerializable()
class CreateTuitionPeriodResponse {
  final String semester;
  final String majorCode;
  final List<TuitionInfo> tuitions;

  CreateTuitionPeriodResponse({
    required this.semester,
    required this.majorCode,
    required this.tuitions,
  });

  factory CreateTuitionPeriodResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateTuitionPeriodResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTuitionPeriodResponseToJson(this);
}

@JsonSerializable()
class TuitionInfo {
  final String tuitionCode;
  final String studentCode;
  final String name;
  final String major;
  final double amount;
  final String status;

  TuitionInfo({
    required this.tuitionCode,
    required this.studentCode,
    required this.name,
    required this.major,
    required this.amount,
    required this.status,
  });

  factory TuitionInfo.fromJson(Map<String, dynamic> json) =>
      _$TuitionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TuitionInfoToJson(this);
}
