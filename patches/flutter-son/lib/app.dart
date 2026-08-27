import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'core/l10n/app_locale.dart';
import 'core/l10n/l10n_ext.dart';
import 'core/settings/app_settings_controller.dart';
import 'core/theme/app_theme.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({
    super.key,
    required this.initialRoute,
    required this.pages,
    this.title = 'Expense Tracker',
  });

  final String initialRoute;
  final List<GetPage<dynamic>> pages;
  final String title;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<AppSettingsController>();

    return Obx(
      () => GetMaterialApp(
        title: title,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: settings.themeMode.value,
        locale: settings.materialLocale,
        fallbackLocale: AppLocale.turkish,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: initialRoute,
        getPages: pages,
      ),
    );
  }
}
