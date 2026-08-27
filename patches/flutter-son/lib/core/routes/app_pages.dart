import 'package:get/get.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/presentation/pages/expense_form_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/notifications/presentation/pages/notification_settings_page.dart';
import '../../features/settings/presentation/pages/language_settings_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'app_routes.dart';

/// User-app routes. Admin screens live in [AdminAppPages] / `main_admin.dart`.
abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.auth, page: () => const AuthPage()),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordPage(),
    ),
    GetPage(name: AppRoutes.expenses, page: () => const ExpensesPage()),
    GetPage(
      name: AppRoutes.expenseForm,
      page: () {
        final args = Get.arguments;
        final expense = args is Expense ? args : null;
        return ExpenseFormPage(expenseToEdit: expense);
      },
    ),
    GetPage(name: AppRoutes.budgets, page: () => const BudgetsPage()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsPage()),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsPage(),
    ),
    GetPage(
      name: AppRoutes.languageSettings,
      page: () => const LanguageSettingsPage(),
    ),
  ];
}
