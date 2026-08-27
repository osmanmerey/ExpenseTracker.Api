import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/settings/app_settings_controller.dart';
import '../../../../core/widgets/animated_mesh_background.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// Profile / settings shell: theme + language + session info + logout.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String _languageSubtitle(AppLocalizations l10n, Locale? override) {
    if (override == null) return l10n.languageSystem;
    if (override.languageCode == 'en') return l10n.languageEnglish;
    return l10n.languageTurkish;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final settings = Get.find<AppSettingsController>();
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: AnimatedMeshBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text(
              l10n.sectionAccount,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.person_outline, color: colors.primary),
                title: Text(
                  l10n.userLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                subtitle: Obx(() {
                  auth.sessionEpoch.value;
                  final mail = auth.currentUserEmail;
                  if (mail == null || mail.isEmpty) {
                    return Text(
                      l10n.noSessionInfo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    );
                  }
                  return Text(
                    mail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.sectionBudget,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.savings_outlined, color: colors.primary),
                title: Text(
                  l10n.monthlyBudget,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                subtitle: Text(
                  l10n.monthlyBudgetSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.toNamed(AppRoutes.budgets),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.sectionNotifications,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.notifications_outlined,
                  color: colors.primary,
                ),
                title: Text(
                  l10n.remindersAndAlerts,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                subtitle: Text(
                  l10n.remindersAndAlertsSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.toNamed(AppRoutes.notificationSettings),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.sectionLanguage,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Obx(() {
                final override = settings.localeOverride.value;
                return ListTile(
                  leading: Icon(Icons.translate, color: colors.primary),
                  title: Text(
                    l10n.language,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    _languageSubtitle(l10n, override),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.toNamed(AppRoutes.languageSettings),
                );
              }),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.sectionAppearance,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Obx(() {
                final isDark = settings.themeMode.value == ThemeMode.dark;
                return SwitchListTile(
                  secondary: Icon(
                    isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: colors.primary,
                  ),
                  title: Text(
                    l10n.darkTheme,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    isDark ? l10n.darkThemeOn : l10n.lightThemeOn,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  value: isDark,
                  onChanged: (_) => settings.toggleDarkMode(),
                );
              }),
            ),
            const SizedBox(height: 32),
            Obx(() {
              final loading = auth.isLoading.value;
              return FilledButton.tonalIcon(
                onPressed: loading
                    ? null
                    : () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.logoutConfirmTitle),
                            content: Text(l10n.logoutConfirmBody),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(l10n.cancel),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(l10n.logout),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await auth.logout();
                        }
                      },
                icon: loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onSecondaryContainer,
                        ),
                      )
                    : const Icon(Icons.logout),
                label: Text(loading ? l10n.loggingOut : l10n.logout),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              );
            }),
            const SizedBox(height: 12),
            Text(
              l10n.logoutHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
