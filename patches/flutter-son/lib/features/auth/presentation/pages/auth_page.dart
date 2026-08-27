import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/animated_mesh_background.dart';
import '../controllers/auth_controller.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.adminPortal = false});

  final bool adminPortal;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final AuthController _authController = Get.find<AuthController>();

  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    _authController.submitAuthForm(
      email: _emailController.text,
      password: _passwordController.text,
      isLogin: _isLogin,
      openAdminPanel: widget.adminPortal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.surface,
      body: AnimatedMeshBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      widget.adminPortal
                          ? l10n.adminPanelTitle
                          : l10n.appTitle,
                      style: AppTypography.brand(
                        brightness: theme.brightness,
                        color: colors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.adminPortal
                          ? l10n.adminPanelSubtitle
                          : (_isLogin
                              ? l10n.authLoginSubtitle
                              : l10n.authRegisterSubtitle),
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _isLogin ? l10n.login : l10n.register,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(Icons.mail_outline),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                    ),
                    Obx(() {
                      final message = _authController.errorMessage.value;
                      if (message.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: colors.onErrorContainer),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    message,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_isLogin) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _authController.errorMessage.value = '';
                            Get.toNamed(AppRoutes.forgotPassword);
                          },
                          child: Text(l10n.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ] else
                      const SizedBox(height: 24),
                    Obx(
                      () => _authController.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : FilledButton(
                              onPressed: _submit,
                              child: Text(
                                widget.adminPortal
                                    ? l10n.adminPortalSignIn
                                    : (_isLogin ? l10n.login : l10n.register),
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _authController.errorMessage.value = '';
                        });
                      },
                      child: Text(
                        _isLogin
                            ? l10n.switchToRegister
                            : l10n.switchToLogin,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
