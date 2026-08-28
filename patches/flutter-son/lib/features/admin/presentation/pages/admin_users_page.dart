import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/animated_mesh_background.dart';
import '../../../../core/widgets/app_filter_chip.dart';
import '../../controllers/admin_controller.dart';
import '../../domain/admin_directory_user.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdminController>()
        ? Get.find<AdminController>()
        : Get.put(AdminController());
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text(l10n.adminUsersPageTitle)),
      body: AnimatedMeshBackground(
        child: Obx(() {
          if (controller.isLoading.value && controller.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: FilledButton.icon(
                  onPressed: controller.isMutating.value
                      ? null
                      : () => _showAddUserDialog(context, controller),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: Text(l10n.adminAddUser),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ),
              Expanded(
                child: _AdminNameList(
                  users: controller.users.toList(),
                  emptyLabel: l10n.adminNoUsers,
                  onTap: (user) => Get.toNamed(
                    AppRoutes.adminUserDetail,
                    arguments: user.id,
                  ),
                  trailingBuilder: (user) => IconButton(
                    tooltip: l10n.adminDeleteUser,
                    onPressed: () => _confirmDelete(context, controller, user),
                    icon: Icon(
                      Icons.delete_outline,
                      color: colors.error,
                    ),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(44, 44),
                    ),
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

class AdminRolesPage extends StatelessWidget {
  const AdminRolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdminController>()
        ? Get.find<AdminController>()
        : Get.put(AdminController());
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text(l10n.adminRolesPageTitle)),
      body: AnimatedMeshBackground(
        child: Obx(() {
          if (controller.isLoading.value && controller.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return _AdminNameList(
            users: controller.users.toList(),
            emptyLabel: l10n.adminNoUsers,
            onTap: (user) => Get.toNamed(
              AppRoutes.adminUserDetail,
              arguments: user.id,
            ),
          );
        }),
      ),
    );
  }
}

class AdminUserDetailPage extends StatelessWidget {
  const AdminUserDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AdminController>()
        ? Get.find<AdminController>()
        : Get.put(AdminController());
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final id = Get.arguments is String ? Get.arguments as String : '';

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: Text(l10n.adminUserDetailTitle)),
      body: AnimatedMeshBackground(
        child: Obx(() {
          final user = controller.userById(id);
          if (user == null) {
            return Center(
              child: Text(
                l10n.adminNoUsers,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.adminEmailAddress,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.adminRoleLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: AppFilterMetrics.groupGap,
                        runSpacing: AppFilterMetrics.groupGap,
                        children: [
                          AppFilterChip(
                            label: l10n.adminRoleUser,
                            selected: !user.isAdmin,
                            onSelected: (_) => _setRole(
                              context,
                              controller,
                              user,
                              'user',
                            ),
                          ),
                          AppFilterChip(
                            label: l10n.adminRoleAdmin,
                            selected: user.isAdmin,
                            onSelected: (_) => _setRole(
                              context,
                              controller,
                              user,
                              'admin',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: controller.isMutating.value
                    ? null
                    : () => _confirmDelete(context, controller, user, pop: true),
                icon: Icon(Icons.delete_outline, color: colors.error),
                label: Text(l10n.adminDeleteUser),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _setRole(
    BuildContext context,
    AdminController controller,
    AdminDirectoryUser user,
    String role,
  ) async {
    if (user.role == role) return;
    final error = await controller.updateRole(user.id, role);
    if (!context.mounted) return;
    final l10n = context.l10n;
    Get.snackbar(
      error == null ? l10n.saved : l10n.error,
      error ?? l10n.adminRoleUpdated,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _AdminNameList extends StatelessWidget {
  const _AdminNameList({
    required this.users,
    required this.emptyLabel,
    required this.onTap,
    this.trailingBuilder,
  });

  final List<AdminDirectoryUser> users;
  final String emptyLabel;
  final ValueChanged<AdminDirectoryUser> onTap;
  final Widget Function(AdminDirectoryUser user)? trailingBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final unnamed = context.l10n.adminUnnamedUser;

    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyLabel,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            minVerticalPadding: 12,
            title: Text(
              user.displayName(unnamed),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
            trailing: trailingBuilder?.call(user) ??
                Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            onTap: () => onTap(user),
          ),
        );
      },
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  AdminController controller,
  AdminDirectoryUser user, {
  bool pop = false,
}) async {
  final l10n = context.l10n;
  final colors = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (ctx) => AlertDialog(
      title: Text(l10n.adminDeleteUserTitle),
      content: Text(l10n.adminDeleteUserBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          style: TextButton.styleFrom(minimumSize: const Size(88, 44)),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            minimumSize: const Size(88, 44),
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          child: Text(l10n.adminDeleteUser),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final error = await controller.deleteUser(user.id);
  if (!context.mounted) return;
  Get.snackbar(
    error == null ? l10n.deleted : l10n.error,
    error ?? l10n.adminUserDeleted,
    snackPosition: SnackPosition.BOTTOM,
  );
  if (error == null && pop) {
    Get.back();
  }
}

Future<void> _showAddUserDialog(
  BuildContext context,
  AdminController controller,
) async {
  final l10n = context.l10n;
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final created = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l10n.adminAddUser),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l10n.adminFullName),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? l10n.error : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l10n.adminEmailAddress),
                  validator: (value) =>
                      (value == null || !value.contains('@')) ? l10n.error : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.password),
                  validator: (value) =>
                      (value == null || value.length < 8) ? l10n.error : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(minimumSize: const Size(88, 44)),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final error = await controller.createUser(
                name: name.text,
                email: email.text,
                password: password.text,
              );
              if (!ctx.mounted) return;
              if (error != null) {
                Get.snackbar(
                  l10n.error,
                  error,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              Navigator.of(ctx).pop(true);
            },
            style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
            child: Text(l10n.adminAddUser),
          ),
        ],
      );
    },
  );

  name.dispose();
  email.dispose();
  password.dispose();

  if (created == true && context.mounted) {
    Get.snackbar(
      l10n.saved,
      l10n.adminUserCreated,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
