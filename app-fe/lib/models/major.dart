import 'package:json_annotation/json_annotation.dart';

part 'major.g.dart';

@JsonSerializable()
class Major {
  final int id;
  final String code;
  final String name;

  Major({required this.id, required this.code, required this.name});

  factory Major.fromJson(Map<String, dynamic> json) => _$MajorFromJson(json);

  Map<String, dynamic> toJson() => _$MajorToJson(this);
}
