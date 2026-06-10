import 'package:json_annotation/json_annotation.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  final UserModel user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}

@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.profileImageUrl,
    this.department,
    this.permissions,
  });

  final String id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  final String? department;
  final List<String>? permissions;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
