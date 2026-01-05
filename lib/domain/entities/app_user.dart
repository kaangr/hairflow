import 'package:equatable/equatable.dart';
import 'role.dart';

/// Application User entity (with role system)
class AppUser extends Equatable {
  final int? id;
  final String email;
  final String? uid; // Firebase UID
  final String? fullName;
  final Role role;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;

  const AppUser({
    this.id,
    required this.email,
    this.uid,
    this.fullName,
    required this.role,
    this.isActive = true,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
  });

  // Check permissions
  bool get isAdmin => role.type == RoleType.admin;
  bool get isExpert => role.type == RoleType.expert;
  bool get isUser => role.type == RoleType.user;

  bool get canManageUsers => role.canManageUsers;
  bool get canApproveContent => role.canApproveContent;
  bool get canCreateContent => role.canCreateContent;
  bool get canViewAllRoutines => role.canViewAllRoutines;

  AppUser copyWith({
    int? id,
    String? email,
    String? uid,
    String? fullName,
    Role? role,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        uid,
        fullName,
        role,
        isActive,
        emailVerified,
        createdAt,
        updatedAt,
        lastLogin,
      ];
}

