// Admin-only entrypoint. Run with:
//   flutter run -t lib/main_admin.dart
// The user app (`lib/main.dart`) does not register these screens.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/auth/session_guard.dart';
import 'core/auth/user_roles.dart';
import 'core/l10n/app_locale.dart';
import 'core/l10n/l10n_ext.dart';
import 'core/network/api_client.dart';
import 'core/routes/admin_app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/settings/app_settings_controller.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/repositories/api_auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final settings = AppSettingsController();
  await settings.init();
  Get.put<AppSettingsController>(settings);

  final tokenStorage = TokenStorage();
  await tokenStorage.init();
  Get.put<TokenStorage>(tokenStorage);
  Get.put<SessionGuard>(SessionGuard(tokenStorage));
  Get.put<ApiClient>(ApiClient(tokenStorage));

  Get.put<IAuthRepository>(
    ApiAuthRepository(Get.find<ApiClient>(), Get.find<TokenStorage>()),
  );
  Get.put(AuthController(Get.find<IAuthRepository>()));

  final hasSession = tokenStorage.userId != null &&
      (tokenStorage.token?.isNotEmpty ?? false);
  final isAdmin = UserRoles.isAdmin(tokenStorage.role) ||
      tokenStorage.email?.trim().toLowerCase() ==
          UserRoles.bootstrapAdminEmail;
  final l10n = lookupAppLocalizations(
    settings.materialLocale ?? AppLocale.turkish,
  );

  runApp(
    ExpenseTrackerApp(
      title: l10n.adminPanelTitle,
      initialRoute:
          hasSession && isAdmin ? AppRoutes.admin : AppRoutes.auth,
      pages: AdminAppPages.pages,
    ),
  );
}
