import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import 'access_messages.dart';

/// Blocks the admin route unless the signed-in user has an admin role.
/// Role comparison is case-insensitive (`ADMIN` / `admin`).
class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: AppRoutes.auth);
    }
    final auth = Get.find<AuthController>();
    if (auth.currentUserId == null) {
      return const RouteSettings(name: AppRoutes.auth);
    }
    if (!auth.isAdmin) {
      if (!Get.testMode) {
        Future.microtask(() {
          Get.snackbar(
            AccessMessages.deniedTitle,
            AccessMessages.deniedBody,
            snackPosition: SnackPosition.BOTTOM,
          );
        });
      }
      return const RouteSettings(name: AppRoutes.auth);
    }
    return null;
  }
}
