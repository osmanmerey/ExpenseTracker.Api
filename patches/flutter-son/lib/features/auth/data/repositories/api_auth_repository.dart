import 'dart:convert';

import '../../../../core/auth/jwt_claims.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/problem_details.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/models/forgot_password_result.dart';
import '../../domain/repositories/i_auth_repository.dart';

class ApiAuthRepository implements IAuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  ApiAuthRepository(this._apiClient, this._tokenStorage);

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        {'email': email, 'password': password},
        auth: false,
      );

      if (response.statusCode != 200) {
        final error = appExceptionFromResponse(response);
        logAppException('ApiAuthRepository.login', error);
        throw error;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = data['user'] as Map<String, dynamic>;
      final userId = user['id'].toString();
      final userEmail = (user['email'] as String?)?.trim();
      final userRole = _readRole(user) ?? JwtClaims.role(token);

      await _tokenStorage.saveSession(
        token: token,
        userId: userId,
        email: userEmail,
        role: userRole,
      );
      return userId;
    } on AppException {
      rethrow;
    } catch (e) {
      final error = appExceptionFromError(e);
      logAppException('ApiAuthRepository.login', error);
      throw error;
    }
  }

  @override
  Future<String> register(String email, String password) async {
    final name = email.contains('@') ? email.split('@').first : email;

    try {
      final response = await _apiClient.post(
        '/auth/register',
        {'name': name, 'email': email, 'password': password},
        auth: false,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        final error = appExceptionFromResponse(response);
        logAppException('ApiAuthRepository.register', error);
        throw error;
      }

      return login(email, password);
    } on AppException {
      rethrow;
    } catch (e) {
      final error = appExceptionFromError(e);
      logAppException('ApiAuthRepository.register', error);
      throw error;
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
  }

  @override
  String? getCurrentUserId() => _tokenStorage.userId;

  @override
  String? getCurrentUserEmail() => _tokenStorage.email;

  @override
  String? getCurrentUserRole() => _tokenStorage.role;

  @override
  Future<ForgotPasswordResult> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(
        '/auth/forgot-password',
        {'email': email.trim()},
        auth: false,
      );

      if (response.statusCode != 200) {
        final error = appExceptionFromResponse(response);
        logAppException('ApiAuthRepository.requestPasswordReset', error);
        throw error;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ForgotPasswordResult(
        message: (data['message'] as String?) ??
            'E-posta kayıtlıysa şifre sıfırlama talimatları gönderildi.',
        resetToken: data['resetToken'] as String?,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      final error = appExceptionFromError(e);
      logAppException('ApiAuthRepository.requestPasswordReset', error);
      throw error;
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/reset-password',
        {
          'email': email.trim(),
          'token': token.trim(),
          'newPassword': newPassword,
        },
        auth: false,
      );

      if (response.statusCode != 200) {
        final error = appExceptionFromResponse(response);
        logAppException('ApiAuthRepository.resetPassword', error);
        throw error;
      }
    } on AppException {
      rethrow;
    } catch (e) {
      final error = appExceptionFromError(e);
      logAppException('ApiAuthRepository.resetPassword', error);
      throw error;
    }
  }

  static String? _readRole(Map<String, dynamic> user) {
    final value = user['role'] ?? user['Role'];
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
