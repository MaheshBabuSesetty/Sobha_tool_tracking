import 'package:power_tool_tracking/features/auth/data/models/login_response_model.dart';
import 'package:power_tool_tracking/features/auth/domain/entities/user_entity.dart';

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
