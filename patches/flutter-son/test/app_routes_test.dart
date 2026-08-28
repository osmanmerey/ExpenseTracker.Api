import 'package:expense_tracker/core/currency/app_currency.dart';
import 'package:expense_tracker/core/routes/admin_app_pages.dart';
import 'package:expense_tracker/core/routes/app_pages.dart';
import 'package:expense_tracker/core/routes/app_routes.dart';
import 'package:expense_tracker/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/auth_page.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/expense_form_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  test(
    'user AppPages has no admin screens',
    () {
      final names = AppPages.pages.map((p) => p.name).toSet();
      expect(
        names,
        containsAll([
          AppRoutes.auth,
          AppRoutes.forgotPassword,
          AppRoutes.resetPassword,
          AppRoutes.expenses,
          AppRoutes.expenseForm,
          AppRoutes.budgets,
          AppRoutes.settings,
          AppRoutes.notificationSettings,
          AppRoutes.languageSettings,
        ]),
      );
      expect(names, isNot(contains(AppRoutes.admin)));
    },
  );

  test('admin entrypoint registers only auth and admin screens', () {
    final names = AdminAppPages.pages.map((p) => p.name).toSet();
    expect(
      names,
      containsAll([
        AppRoutes.auth,
        AppRoutes.admin,
        AppRoutes.adminUsers,
        AppRoutes.adminRoles,
        AppRoutes.adminUserDetail,
        AppRoutes.forgotPassword,
        AppRoutes.resetPassword,
      ]),
    );
    expect(names, isNot(contains(AppRoutes.expenses)));
    expect(
      AdminAppPages.pages
          .firstWhere((p) => p.name == AppRoutes.admin)
          .page(),
      isA<AdminDashboardPage>(),
    );
    expect(
      AdminAppPages.pages
          .firstWhere((p) => p.name == AppRoutes.auth)
          .page(),
      isA<AuthPage>(),
    );
  });

  test('expense form page factory reads Expense arguments', () {
    Get.testMode = true;
    final expense = Expense(
      id: '1',
      userId: 'u',
      amount: 10,
      currency: AppCurrency.usd,
      category: 'Yemek',
      date: DateTime(2026, 1, 1),
      description: 'x',
    );
    Get.routing.args = expense;

    final page = AppPages.pages
        .firstWhere((p) => p.name == AppRoutes.expenseForm)
        .page();

    expect(page, isA<ExpenseFormPage>());
    expect((page as ExpenseFormPage).expenseToEdit?.currency, AppCurrency.usd);

    Get.reset();
  });
}
