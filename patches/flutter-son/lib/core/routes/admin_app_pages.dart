import 'package:get/get.dart';

import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../auth/admin_middleware.dart';
import 'app_routes.dart';

/// Routes for the admin entrypoint (`lib/main_admin.dart`).
/// The user app (`AppPages`) must not register these screens.
abstract final class AdminAppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthPage(adminPortal: true),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordPage(),
    ),
    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminDashboardPage(),
      middlewares: [AdminMiddleware()],
    ),
  ];
}
