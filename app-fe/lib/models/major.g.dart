// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'major.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Major _$MajorFromJson(Map<String, dynamic> json) => Major(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$MajorToJson(Major instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
};
