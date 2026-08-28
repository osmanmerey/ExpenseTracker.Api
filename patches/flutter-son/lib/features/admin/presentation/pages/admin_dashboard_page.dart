import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/animated_mesh_background.dart';
import '../../../../core/widgets/logout_confirm_dialog.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdminController>()) {
      Get.put(AdminController());
    }
    final controller = Get.find<AdminController>();
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
            onPressed: () => confirmLogoutAndRun(
              context,
              Get.find<AuthController>().logout,
            ),
            icon: const Icon(Icons.logout),
            style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
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
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(160, 44),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 720;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  Text(
                    l10n.adminPanelSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (stacked) ...[
                    _UsersSummaryCard(controller: controller),
                    const SizedBox(height: 12),
                    const _QuickActions(fullWidth: true),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _UsersSummaryCard(controller: controller),
                        ),
                        const SizedBox(width: 12),
                        const SizedBox(
                          width: 260,
                          child: _QuickActions(fullWidth: true),
                        ),
                      ],
                    ),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}

class _UsersSummaryCard extends StatelessWidget {
  const _UsersSummaryCard({required this.controller});

  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adminUsersCardTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${controller.userCount.value}',
              style: theme.textTheme.displaySmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.adminUserCountLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.adminUsersAdminsLine(controller.adminAccountCount.value),
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

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.fullWidth});

  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    final add = FilledButton.icon(
      onPressed: () => Get.toNamed(AppRoutes.adminUsers),
      icon: const Icon(Icons.person_add_alt_1_outlined),
      label: Text(l10n.adminManageUsersAction),
      style: FilledButton.styleFrom(
        minimumSize: Size(fullWidth ? double.infinity : 0, 44),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
    );
    final roles = OutlinedButton.icon(
      onPressed: () => Get.toNamed(AppRoutes.adminRoles),
      icon: const Icon(Icons.admin_panel_settings_outlined),
      label: Text(l10n.adminManageRolesAction),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(fullWidth ? double.infinity : 0, 44),
        foregroundColor: colors.onSurface,
        side: BorderSide(color: colors.outline),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        add,
        const SizedBox(height: 8),
        roles,
      ],
    );
  }
}
