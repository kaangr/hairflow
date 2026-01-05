import 'package:equatable/equatable.dart';

/// Role enum for 3-tier role system
enum RoleType {
  admin,   // Full system access
  expert,  // Content creation (tips, products)
  user,    // Personal routine management
}

/// Role entity
class Role extends Equatable {
  final int id;
  final String name;
  final String? description;
  final RoleType type;

  const Role({
    required this.id,
    required this.name,
    this.description,
    required this.type,
  });

  // Predefined roles
  static const Role admin = Role(
    id: 1,
    name: 'Admin',
    description: 'Sistem yöneticisi - Tam yetki',
    type: RoleType.admin,
  );

  static const Role expert = Role(
    id: 2,
    name: 'Expert',
    description: 'İçerik uzmanı - İpucu ve ürün yönetimi',
    type: RoleType.expert,
  );

  static const Role userRole = Role(
    id: 3,
    name: 'User',
    description: 'Normal kullanıcı - Kişisel rutin yönetimi',
    type: RoleType.user,
  );

  static const List<Role> allRoles = [admin, expert, userRole];

  static Role fromId(int id) {
    return allRoles.firstWhere(
      (role) => role.id == id,
      orElse: () => userRole,
    );
  }

  static Role fromType(RoleType type) {
    return allRoles.firstWhere(
      (role) => role.type == type,
      orElse: () => userRole,
    );
  }

  // Permission checks
  bool get canManageUsers => type == RoleType.admin;
  bool get canApproveContent => type == RoleType.admin;
  bool get canCreateContent => type == RoleType.admin || type == RoleType.expert;
  bool get canViewAllRoutines => type != RoleType.user;
  bool get canManageOwnRoutines => true; // All roles
  bool get canViewStatistics => true; // All roles (but scope differs)

  @override
  List<Object?> get props => [id, name, description, type];

  @override
  String toString() => name;
}

