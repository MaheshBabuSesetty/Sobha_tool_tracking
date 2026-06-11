import 'package:json_annotation/json_annotation.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel {
  const LoginRequestModel({
    required this.email,
    required this.password,
    this.deviceId,
    this.fcmToken,
  });

  final String email;
  final String password;
  @JsonKey(name: 'device_id')
  final String? deviceId;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}
