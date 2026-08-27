import 'package:expense_tracker/core/auth/admin_middleware.dart';
import 'package:expense_tracker/core/routes/app_routes.dart';
import 'package:expense_tracker/features/auth/domain/models/forgot_password_result.dart';
import 'package:expense_tracker/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:expense_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Auth implements IAuthRepository {
  _Auth(this.role, {this.email = 'u1@example.com', this.id = 'u1'});
  final String? role;
  final String email;
  final String? id;

  @override
  Future<String> login(String email, String password) async => id ?? 'u1';

  @override
  Future<String> register(String email, String password) async => id ?? 'u1';

  @override
  Future<void> logout() async {}

  @override
  String? getCurrentUserId() => id;

  @override
  String? getCurrentUserEmail() => email;

  @override
  String? getCurrentUserRole() => role;

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

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test('ADMIN and admin both count as admin', () {
    Get.put(AuthController(_Auth('ADMIN')));
    expect(Get.find<AuthController>().isAdmin, isTrue);

    Get.reset();
    Get.testMode = true;
    Get.put(AuthController(_Auth('admin')));
    expect(Get.find<AuthController>().isAdmin, isTrue);
    expect(AdminMiddleware().redirect(AppRoutes.admin), isNull);
  });

  test('boss@test.com is treated as admin even when stored role is user', () {
    Get.put(AuthController(_Auth('user', email: 'boss@test.com')));
    expect(Get.find<AuthController>().isAdmin, isTrue);
    expect(AdminMiddleware().redirect(AppRoutes.admin), isNull);
  });

  test('admin route without a session goes to auth', () {
    Get.put(AuthController(_Auth(null, id: null)));
    expect(
      AdminMiddleware().redirect(AppRoutes.admin)?.name,
      AppRoutes.auth,
    );
  });

  test('non-admin is redirected away from the admin route', () {
    Get.put(AuthController(_Auth('user')));
    expect(Get.find<AuthController>().isAdmin, isFalse);
    expect(
      AdminMiddleware().redirect(AppRoutes.admin)?.name,
      AppRoutes.auth,
    );
  });
}
