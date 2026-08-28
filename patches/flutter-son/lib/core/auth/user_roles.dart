/// Canonical API role names. Keep in sync with ExpenseTracker.Api `UserRoles`.
abstract final class UserRoles {
  static const user = 'user';
  static const admin = 'admin';

  /// Same mailbox as ExpenseTracker.Api `AuthBootstrapDefaults.DevelopmentAdminEmail`.
  static const bootstrapAdminEmail = 'boss@test.com';

  static String normalize(String? role) {
    final value = role?.trim().toLowerCase();
    return (value == null || value.isEmpty) ? user : value;
  }

  static bool isAdmin(String? role) => normalize(role) == admin;

  static bool isValid(String? role) {
    final value = normalize(role);
    return value == user || value == admin;
  }
}
