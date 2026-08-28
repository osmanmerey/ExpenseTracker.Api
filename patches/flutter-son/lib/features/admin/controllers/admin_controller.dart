import 'dart:convert';

import 'package:get/get.dart';

import '../../../core/auth/user_roles.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/problem_details.dart';
import '../domain/admin_directory_user.dart';

/// Admin directory + aggregate counts. Never loads expenses or payment data.
class AdminController extends GetxController {
  var isLoading = false.obs;
  var hasError = false.obs;
  var isApiReachable = false.obs;
  var userCount = 0.obs;
  var adminAccountCount = 0.obs;
  var isMutating = false.obs;
  final users = <AdminDirectoryUser>[].obs;

  ApiClient get _apiClient => Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    loadOverview();
  }

  AdminDirectoryUser? userById(String id) {
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  Future<void> loadOverview() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final response = await _apiClient.get('/users');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded is List ? decoded : const [];
        final parsed = <AdminDirectoryUser>[];
        var admins = 0;
        for (final item in list) {
          if (item is! Map) continue;
          final user = AdminDirectoryUser.fromJson(item);
          if (user.id.isEmpty) continue;
          parsed.add(user);
          if (user.isAdmin) admins++;
        }
        parsed.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        users.assignAll(parsed);
        userCount.value = parsed.length;
        adminAccountCount.value = admins;
        isApiReachable.value = true;
        return;
      }
      _markUnavailable();
    } catch (_) {
      _markUnavailable();
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    isMutating.value = true;
    try {
      final response = await _apiClient.post(
        '/auth/register',
        {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        },
        auth: false,
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        await loadOverview();
        return null;
      }
      return appExceptionFromResponse(response).userMessage;
    } on AppException catch (error) {
      return error.userMessage;
    } catch (_) {
      return const AppException(
        kind: AppErrorKind.unknown,
        userMessage: 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
      ).userMessage;
    } finally {
      isMutating.value = false;
    }
  }

  Future<String?> deleteUser(String id) async {
    isMutating.value = true;
    try {
      final response = await _apiClient.delete('/users/$id');
      if (response.statusCode == 204 || response.statusCode == 200) {
        await loadOverview();
        return null;
      }
      return appExceptionFromResponse(response).userMessage;
    } on AppException catch (error) {
      return error.userMessage;
    } catch (_) {
      return const AppException(
        kind: AppErrorKind.unknown,
        userMessage: 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
      ).userMessage;
    } finally {
      isMutating.value = false;
    }
  }

  Future<String?> updateRole(String id, String role) async {
    final normalized = UserRoles.normalize(role);
    if (!UserRoles.isValid(normalized)) {
      return null;
    }
    isMutating.value = true;
    try {
      final response = await _apiClient.put('/users/$id/role', {'role': normalized});
      if (response.statusCode == 204 || response.statusCode == 200) {
        await loadOverview();
        return null;
      }
      return appExceptionFromResponse(response).userMessage;
    } on AppException catch (error) {
      return error.userMessage;
    } catch (_) {
      return const AppException(
        kind: AppErrorKind.unknown,
        userMessage: 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
      ).userMessage;
    } finally {
      isMutating.value = false;
    }
  }

  void _markUnavailable() {
    users.clear();
    userCount.value = 0;
    adminAccountCount.value = 0;
    isApiReachable.value = false;
    hasError.value = true;
  }
}
