import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.designation,
    this.siteName,
    this.profileImageUrl,
    this.department,
    this.permissions = const [],
  });

  final String id;
  final String email;
  final String name;
  final String role;
  final String? phone;
  final String? designation;
  final String? siteName;
  final String? profileImageUrl;
  final String? department;
  final List<String> permissions;

  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get isManager => role == 'manager' || isAdmin;
  bool get isTechnician => role == 'technician';

  bool hasPermission(String permission) => permissions.contains(permission);

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [id, email, name, role, phone, designation, siteName, profileImageUrl, department];
}
