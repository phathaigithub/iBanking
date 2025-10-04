import 'package:json_annotation/json_annotation.dart';

part 'tuition_inquiry_request.g.dart';

@JsonSerializable()
class TuitionInquiryRequest {
  final String studentCode;

  TuitionInquiryRequest({required this.studentCode});

  factory TuitionInquiryRequest.fromJson(Map<String, dynamic> json) =>
      _$TuitionInquiryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TuitionInquiryRequestToJson(this);
}
