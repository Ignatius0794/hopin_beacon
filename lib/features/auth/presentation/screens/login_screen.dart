import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sandbox/core/localization/app_localizations.dart';
import 'package:sandbox/core/routes/app_paths.dart';
import 'package:sandbox/core/widgets/neo_toast.dart';
import 'package:sandbox/features/auth/presentation/bloc/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await context.read<AuthCubit>().login(
          _usernameController.text,
          _passwordController.text,
        );
    if (!mounted) return;

    if (success) {
      context.go(AppPaths.home);
    } else {
      showNeoToast(context, context.tr('auth.loginFailed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loading =
        context.watch<AuthCubit>().state.status == AuthStatus.loading;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.65),
              colorScheme.surface,
              colorScheme.tertiaryContainer.withValues(alpha: 0.45),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(context.tr('auth.welcome'),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text(context.tr('auth.signInToContinue'),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _usernameController,
                              enabled: !loading,
                              autofillHints: const [AutofillHints.username],
                              decoration: InputDecoration(
                                  labelText: context.tr('auth.username'),
                                  prefixIcon: const Icon(Icons.person_outline)),
                              textInputAction: TextInputAction.next,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? context.tr('auth.enterUsername')
                                      : null,
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _passwordController,
                              enabled: !loading,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: context.tr('auth.password'),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: context.tr(_obscurePassword
                                      ? 'auth.showPassword'
                                      : 'auth.hidePassword'),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                ),
                              ),
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted:
                                  loading ? null : (_) => _submit(),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? context.tr('auth.enterPassword')
                                      : null,
                            ),
                            const SizedBox(height: 28),
                            FilledButton.icon(
                              onPressed: loading ? null : _submit,
                              icon: loading
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.login),
                              label: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(context.tr('auth.login'))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
