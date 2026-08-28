import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n_ext.dart';

/// Accessible session-end confirmation. Cancel, close, barrier tap, and Escape
/// keep the session open. Confirming returns `true`.
Future<bool> showLogoutConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (ctx) => const LogoutConfirmDialog(),
  );
  return result == true;
}

class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.of(context).pop(false);
        },
      },
      child: Focus(
        autofocus: true,
        child: AlertDialog(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
          titlePadding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.logoutConfirmTitle,
                    style: theme.dialogTheme.titleTextStyle ??
                        theme.textTheme.titleLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.dialogClose,
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.logoutConfirmBody,
            style: theme.dialogTheme.contentTextStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                minimumSize: const Size(88, 44),
                foregroundColor: colors.onSurfaceVariant,
              ),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                minimumSize: const Size(88, 44),
                backgroundColor: colors.errorContainer,
                foregroundColor: colors.onErrorContainer,
              ),
              child: Text(l10n.logoutConfirmAction),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> confirmLogoutAndRun(
  BuildContext context,
  Future<void> Function() logout,
) async {
  final confirmed = await showLogoutConfirmDialog(context);
  if (confirmed) {
    await logout();
  }
}
