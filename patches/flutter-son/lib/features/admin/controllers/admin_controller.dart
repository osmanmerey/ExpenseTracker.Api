import 'dart:convert';

import 'package:get/get.dart';

import '../../../../core/auth/user_roles.dart';
import '../../../../core/network/api_client.dart';

/// Operational admin overview: aggregate counts only, no personal records.
class AdminController extends GetxController {
  var isLoading = false.obs;
  var hasError = false.obs;
  var isApiReachable = false.obs;
  var userCount = 0.obs;
  var adminAccountCount = 0.obs;

  ApiClient get _apiClient => Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    loadOverview();
  }

  Future<void> loadOverview() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final response = await _apiClient.get('/users');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = decoded is List ? decoded : const [];
        var admins = 0;
        for (final item in list) {
          if (item is Map && UserRoles.isAdmin(item['role']?.toString())) {
            admins++;
          }
        }
        userCount.value = list.length;
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

  void _markUnavailable() {
    userCount.value = 0;
    adminAccountCount.value = 0;
    isApiReachable.value = false;
    hasError.value = true;
  }
}
