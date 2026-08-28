import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/auth/session_guard.dart';
import 'core/network/api_client.dart';
import 'core/notifications/budget_alert_coordinator.dart';
import 'core/notifications/notification_service.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/settings/app_settings_controller.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/repositories/api_auth_repository.dart';
import 'features/auth/domain/repositories/i_auth_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/budgets/data/repositories/api_budget_repository.dart';
import 'features/budgets/domain/repositories/i_budget_repository.dart';
import 'features/budgets/presentation/controllers/budget_controller.dart';
import 'features/expenses/data/repositories/api_expense_repository.dart';
import 'features/expenses/domain/repositories/i_expense_repository.dart';
import 'features/expenses/presentation/controllers/expense_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final settings = AppSettingsController();
  await settings.init();
  Get.put<AppSettingsController>(settings);

  final notifications = NotificationService();
  await notifications.init();
  Get.put<NotificationService>(notifications);
  await settings.syncNotificationsFromPrefs();

  final tokenStorage = TokenStorage();
  await tokenStorage.init();
  Get.put<TokenStorage>(tokenStorage);
  Get.put<SessionGuard>(SessionGuard(tokenStorage));
  Get.put<ApiClient>(ApiClient(tokenStorage));

  Get.put<IAuthRepository>(
    ApiAuthRepository(Get.find<ApiClient>(), Get.find<TokenStorage>()),
  );
  Get.put(AuthController(Get.find<IAuthRepository>()));

  Get.put<IExpenseRepository>(ApiExpenseRepository(Get.find<ApiClient>()));
  Get.put(ExpenseController(
    Get.find<IExpenseRepository>(),
    Get.find<IAuthRepository>(),
  ));

  Get.put<IBudgetRepository>(ApiBudgetRepository(Get.find<ApiClient>()));
  Get.lazyPut(
    () => BudgetController(Get.find<IBudgetRepository>()),
    fenix: true,
  );

  Get.put(
    BudgetAlertCoordinator(
      Get.find<IBudgetRepository>(),
      settings,
      notifications,
    ),
  );

  final hasSession = tokenStorage.userId != null &&
      (tokenStorage.token?.isNotEmpty ?? false);
  runApp(
    ExpenseTrackerApp(
      initialRoute: hasSession ? AppRoutes.expenses : AppRoutes.auth,
      pages: AppPages.pages,
    ),
  );
}
