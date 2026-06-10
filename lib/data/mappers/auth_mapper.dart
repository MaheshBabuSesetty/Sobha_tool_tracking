import 'package:power_tool_tracking/data/models/auth/login_response_model.dart';
import 'package:power_tool_tracking/domain/entities/user_entity.dart';

extension UserModelMapper on UserModel {
  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        name: name,
        role: role,
        phone: phone,
        profileImageUrl: profileImageUrl,
        department: department,
        permissions: permissions ?? [],
      );
}
