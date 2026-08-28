import '../../../core/auth/user_roles.dart';

/// Directory row for admin user management. Financial fields are never stored.
class AdminDirectoryUser {
  const AdminDirectoryUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String role;

  bool get isAdmin => UserRoles.isAdmin(role);

  String displayName(String unnamedFallback) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? unnamedFallback : trimmed;
  }

  factory AdminDirectoryUser.fromJson(Map<dynamic, dynamic> json) {
    return AdminDirectoryUser(
      id: '${json['id'] ?? ''}',
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      role: UserRoles.normalize((json['role'] ?? json['Role'])?.toString()),
    );
  }
}
