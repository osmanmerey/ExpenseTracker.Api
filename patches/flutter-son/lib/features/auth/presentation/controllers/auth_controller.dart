import 'package:get/get.dart';

import '../../../../core/auth/access_messages.dart';
import '../../../../core/auth/user_roles.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../expenses/presentation/controllers/expense_controller.dart';
import '../../domain/models/forgot_password_result.dart';
import '../../domain/models/reset_password_args.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthController extends GetxController {
  final IAuthRepository _authRepository;

  AuthController(this._authRepository);

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final sessionEpoch = 0.obs;

  String? get currentUserId => _authRepository.getCurrentUserId();

  String? get currentUserEmail => _authRepository.getCurrentUserEmail();

  String? get currentUserRole => _authRepository.getCurrentUserRole();

  bool get isAdmin {
    if (UserRoles.isAdmin(currentUserRole)) return true;
    final email = currentUserEmail?.trim().toLowerCase();
    return email == UserRoles.bootstrapAdminEmail;
  }

  void _markSessionChanged() => sessionEpoch.value++;

  Future<void> submitAuthForm({
    required String email,
    required String password,
    required bool isLogin,
    bool openAdminPanel = false,
  }) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      errorMessage.value = 'Lütfen tüm alanları doldurun.';
      return;
    }

    bool success;
    if (isLogin) {
      success = await login(cleanEmail, cleanPassword);
    } else {
      success = await register(cleanEmail, cleanPassword);
    }

    if (success) {
      _markSessionChanged();
      if (openAdminPanel) {
        if (!isAdmin) {
          await _authRepository.logout();
          _markSessionChanged();
          errorMessage.value = AccessMessages.deniedBody;
          return;
        }
        Get.offAllNamed(AppRoutes.admin);
        return;
      }
      Get.find<ExpenseController>().loadExpenses();
      Get.offAllNamed(AppRoutes.expenses);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.login(email, password);
      return true;
    } catch (e) {
      final error = e is AppException
          ? e
          : const AppException(
              kind: AppErrorKind.unknown,
              userMessage: 'Giriş başarısız. Lütfen tekrar deneyin.',
            );
      logAppException('AuthController.login', error);
      errorMessage.value = error.userMessage;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.register(email, password);
      return true;
    } catch (e) {
      final error = e is AppException
          ? e
          : const AppException(
              kind: AppErrorKind.unknown,
              userMessage: 'Kayıt başarısız. Lütfen tekrar deneyin.',
            );
      logAppException('AuthController.register', error);
      errorMessage.value = error.userMessage;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<ForgotPasswordResult?> requestPasswordReset(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      errorMessage.value = 'Lütfen e-posta adresinizi girin.';
      return null;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _authRepository.requestPasswordReset(cleanEmail);
      if (result.resetToken != null && result.resetToken!.isNotEmpty) {
        Get.toNamed(
          AppRoutes.resetPassword,
          arguments: ResetPasswordArgs(
            email: cleanEmail,
            token: result.resetToken,
          ),
        );
      }
      return result;
    } catch (e) {
      final error = e is AppException
          ? e
          : const AppException(
              kind: AppErrorKind.unknown,
              userMessage: 'İstek gönderilemedi. Lütfen tekrar deneyin.',
            );
      logAppException('AuthController.requestPasswordReset', error);
      errorMessage.value = error.userMessage;
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final cleanEmail = email.trim();
    final cleanToken = token.trim();

    if (cleanEmail.isEmpty || cleanToken.isEmpty || newPassword.isEmpty) {
      errorMessage.value = 'Lütfen tüm alanları doldurun.';
      return false;
    }
    if (newPassword.length < 8) {
      errorMessage.value = 'Yeni şifre en az 8 karakter olmalıdır.';
      return false;
    }
    if (newPassword != confirmPassword) {
      errorMessage.value = 'Şifreler eşleşmiyor.';
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.resetPassword(
        email: cleanEmail,
        token: cleanToken,
        newPassword: newPassword,
      );
      Get.offAllNamed(AppRoutes.auth);
      Get.snackbar(
        'Şifre güncellendi',
        'Yeni şifrenizle giriş yapabilirsiniz.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      final error = e is AppException
          ? e
          : const AppException(
              kind: AppErrorKind.unknown,
              userMessage: 'Şifre sıfırlanamadı. Lütfen tekrar deneyin.',
            );
      logAppException('AuthController.resetPassword', error);
      errorMessage.value = error.userMessage;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears session and replaces the stack with the auth route.
  Future<void> logout() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _authRepository.logout();
      _markSessionChanged();
      if (Get.isRegistered<ExpenseController>()) {
        Get.find<ExpenseController>().expenses.clear();
      }
      Get.offAllNamed(AppRoutes.auth);
    } catch (e) {
      final error = e is AppException
          ? e
          : AppException(
              kind: AppErrorKind.unknown,
              userMessage: 'Çıkış yapılamadı. Lütfen tekrar deneyin.',
              cause: e,
            );
      logAppException('AuthController.logout', error);
      errorMessage.value = error.userMessage;
      Get.snackbar(
        'Hata',
        error.userMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

}
