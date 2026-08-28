import 'package:expense_tracker/core/currency/app_currency.dart';
import 'package:expense_tracker/features/auth/domain/models/forgot_password_result.dart';
import 'package:expense_tracker/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_load_result.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/i_expense_repository.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Auth implements IAuthRepository {
  @override
  Future<String> login(String email, String password) async => 'u1';

  @override
  Future<String> register(String email, String password) async => 'u1';

  @override
  Future<void> logout() async {}

  @override
  String? getCurrentUserId() => 'u1';

  @override
  String? getCurrentUserEmail() => 'u1@example.com';

  @override
  String? getCurrentUserRole() => null;

  @override
  Future<ForgotPasswordResult> requestPasswordReset(String email) async =>
      const ForgotPasswordResult(message: 'ok');

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {}
}

class _Repo implements IExpenseRepository {
  _Repo(this.count);

  final int count;

  @override
  Future<ExpenseLoadResult> getExpenses(String userId) async =>
      ExpenseLoadResult(
        expenses: [
          for (var i = 1; i <= count; i++)
            Expense(
              id: '$i',
              userId: 'u1',
              amount: i.toDouble(),
              currency: AppCurrency.tryLira,
              category: i.isEven ? 'Yemek' : 'Market',
              date: DateTime(2026, 1, i.clamp(1, 28)),
              description: 'item $i',
            ),
        ],
      );

  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}
}

void main() {
  late ExpenseController controller;

  setUp(() {
    Get.testMode = true;
    controller = ExpenseController(_Repo(25), _Auth());
  });

  tearDown(Get.reset);

  test('list is split into numbered pages of 10', () async {
    await controller.loadExpenses();

    expect(ExpenseController.listPageSize, 10);
    expect(controller.visibleExpenses, hasLength(25));
    expect(controller.pageCount, 3);
    expect(controller.currentPage.value, 1);
    expect(controller.pagedExpenses, hasLength(10));
    expect(controller.pagedExpenses.first.id, '25');

    controller.goToPage(2);
    expect(controller.currentPage.value, 2);
    expect(controller.pagedExpenses, hasLength(10));

    controller.goToPage(3);
    expect(controller.currentPage.value, 3);
    expect(controller.pagedExpenses, hasLength(5));

    controller.goToPage(99);
    expect(controller.currentPage.value, 3);
  });

  test('filters return to page 1', () async {
    await controller.loadExpenses();
    controller.goToPage(3);
    expect(controller.currentPage.value, 3);

    controller.setSearchQuery('Yemek');
    expect(controller.currentPage.value, 1);
    expect(controller.pagedExpenses.length, lessThanOrEqualTo(10));
  });
}
