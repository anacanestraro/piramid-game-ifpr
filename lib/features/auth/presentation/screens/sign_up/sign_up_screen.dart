import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/ui/app_feedback.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/auth_primary_button.dart';
import '../../widgets/auth_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  AuthViewModel get _viewModel => InjectionContainer.instance.authViewModel;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    await _viewModel.signUpCommand.execute((
      email: _emailController.text,
      password: _passwordController.text,
      passwordConfirmation: _confirmationController.text,
    ));

    if (!mounted) return;

    final state = _viewModel.signUpCommand.state.value;

    if (state.isSuccess) {
      AppFeedback.showSuccess(context, 'Conta criada! Bem-vindo ao ranking.');
      context.go(AppRoutes.home);
    } else if (state.isError) {
      AppFeedback.showError(context, state.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textDim =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SignalBuilder(
                builder: (context) {
                  final isSigningUp =
                      _viewModel.signUpCommand.state.value.isRunning;

                  return AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthHeader(
                          title: 'Criar conta',
                          subtitle: 'Entre para a disputa pelo Nível Lenda',
                        ),
                        const SizedBox(height: 32),
                        AuthTextField(
                          controller: _emailController,
                          label: 'E-mail',
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                        ),
                        const SizedBox(height: 12),
                        AuthTextField(
                          controller: _passwordController,
                          label: 'Senha (mínimo 6 caracteres)',
                          icon: Icons.lock_rounded,
                          isPassword: true,
                          autofillHints: const [AutofillHints.newPassword],
                        ),
                        const SizedBox(height: 12),
                        AuthTextField(
                          controller: _confirmationController,
                          label: 'Confirmar senha',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onSubmitted: (_) => isSigningUp ? null : _signUp(),
                        ),
                        const SizedBox(height: 22),
                        AuthPrimaryButton(
                          label: 'Criar conta',
                          isLoading: isSigningUp,
                          onPressed: isSigningUp ? null : _signUp,
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Já tem conta?',
                              style: AppTextStyles.jakarta(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textDim,
                              ),
                            ),
                            TextButton(
                              onPressed: isSigningUp
                                  ? null
                                  : () => context.go(AppRoutes.login),
                              child: const Text('Entrar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}