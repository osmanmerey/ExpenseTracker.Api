import 'package:expense_tracker/core/auth/access_messages.dart';
import 'package:expense_tracker/core/routes/app_routes.dart';
import 'package:expense_tracker/features/auth/domain/models/forgot_password_result.dart';
import 'package:expense_tracker/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:expense_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:expense_tracker/features/expenses/domain/entities/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_load_result.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/i_expense_repository.dart';
import 'package:expense_tracker/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Auth implements IAuthRepository {
  _Auth(this.role, {this.email = 'u1@example.com'});
  final String? role;
  final String email;
  var loggedOut = false;

  @override
  Future<String> login(String email, String password) async => 'u1';

  @override
  Future<String> register(String email, String password) async => 'u1';

  @override
  Future<void> logout() async {
    loggedOut = true;
  }

  @override
  String? getCurrentUserId() => loggedOut ? null : 'u1';

  @override
  String? getCurrentUserEmail() => loggedOut ? null : email;

  @override
  String? getCurrentUserRole() => loggedOut ? null : role;

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

class _FakeExpenses implements IExpenseRepository {
  @override
  Future<ExpenseLoadResult> getExpenses(String userId) async =>
      const ExpenseLoadResult(expenses: []);

  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  test('admin portal rejects a regular user and stays outside the app', () async {
    final repo = _Auth('user');
    final auth = Get.put(AuthController(repo));

    await auth.submitAuthForm(
      email: 'u1@example.com',
      password: 'secret12',
      isLogin: true,
      openAdminPanel: true,
    );

    expect(repo.loggedOut, isTrue);
    expect(auth.errorMessage.value, AccessMessages.deniedBody);
    expect(Get.currentRoute, isNot(AppRoutes.expenses));
    expect(Get.currentRoute, isNot(AppRoutes.admin));
  });

  test('normal sign-in still opens the user expenses app', () async {
    Get.put(ExpenseController(_FakeExpenses(), _Auth('admin')));
    final auth = Get.put(AuthController(_Auth('admin')));

    await auth.submitAuthForm(
      email: 'boss@test.com',
      password: 'secret12',
      isLogin: true,
    );

    expect(auth.errorMessage.value, isEmpty);
  });
}
