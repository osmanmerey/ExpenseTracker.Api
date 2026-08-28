/// Named route paths used with GetX [Get.toNamed] / [Get.offAllNamed].
abstract final class AppRoutes {
  static const auth = '/auth';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const expenses = '/expenses';
  static const expenseForm = '/expenses/form';
  static const budgets = '/budgets';
  static const settings = '/settings';
  static const notificationSettings = '/settings/notifications';
  static const languageSettings = '/settings/language';
  static const admin = '/admin';
  static const adminUsers = '/admin/users';
  static const adminRoles = '/admin/roles';
  static const adminUserDetail = '/admin/users/detail';
}
