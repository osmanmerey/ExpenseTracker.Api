import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/widgets/animated_mesh_background.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(l10n.adminPanelTitle),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            onPressed: () => Get.find<AuthController>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: AnimatedMeshBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 56,
                      color: colors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.connectionErrorTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.adminOverviewLoadFailed,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: controller.loadOverview,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                l10n.adminPanelSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              _OverviewCard(
                icon: Icons.groups_outlined,
                title: l10n.adminUserCountLabel,
                value: l10n.adminUserCountValue(controller.userCount.value),
              ),
              const SizedBox(height: 12),
              _OverviewCard(
                icon: controller.isApiReachable.value
                    ? Icons.cloud_done_outlined
                    : Icons.cloud_off_outlined,
                title: l10n.adminSystemStatus,
                value: controller.isApiReachable.value
                    ? l10n.adminSystemOnline
                    : l10n.adminSystemOffline,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.adminUsageSummary,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              if (controller.userCount.value == 0)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 72,
                          color: colors.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noRecordsYet,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.adminUsageEmptyHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.person_outline,
                            color: colors.primary,
                          ),
                          title: Text(l10n.adminUsageAccounts(
                            controller.userCount.value,
                          )),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.admin_panel_settings_outlined,
                            color: colors.primary,
                          ),
                          title: Text(l10n.adminUsageAdmins(
                            controller.adminAccountCount.value,
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: colors.primary),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(color: colors.onSurface),
        ),
        subtitle: Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
