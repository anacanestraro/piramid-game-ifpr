import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../../core/command/command_state.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/ui/app_feedback.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/auth_primary_button.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AuthViewModel get _viewModel => InjectionContainer.instance.authViewModel;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    await _viewModel.loginCommand.execute((
      email: _emailController.text,
      password: _passwordController.text,
    ));

    _handleOutcome(_viewModel.loginCommand.state.value);
  }

  Future<void> _loginWithGoogle() async {
    await _viewModel.loginGoogleCommand.execute();
    _handleOutcome(_viewModel.loginGoogleCommand.state.value);
  }

  // A tela só reage ao resultado: navega ou exibe o erro.
  void _handleOutcome(CommandState state) {
    if (!mounted) return;

    if (state.isSuccess) {
      context.go(AppRoutes.home);
    } else if (state.isError) {
      AppFeedback.showError(context, state.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SignalBuilder(
                builder: (context) {
                  final isLoggingIn =
                      _viewModel.loginCommand.state.value.isRunning;
                  final isLoggingInWithGoogle =
                      _viewModel.loginGoogleCommand.state.value.isRunning;
                  final isBusy = isLoggingIn || isLoggingInWithGoogle;

                  return AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthHeader(
                          title: 'Entrar',
                          subtitle: 'Acesse o ranking do IFPR Paranaguá',
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
                          label: 'Senha',
                          icon: Icons.lock_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onSubmitted: (_) => isBusy ? null : _login(),
                        ),
                        const SizedBox(height: 22),
                        AuthPrimaryButton(
                          label: 'Entrar',
                          isLoading: isLoggingIn,
                          onPressed: isBusy ? null : _login,
                        ),
                        const SizedBox(height: 18),
                        const _OrDivider(),
                        const SizedBox(height: 18),
                        GoogleSignInButton(
                          isLoading: isLoggingInWithGoogle,
                          onPressed: isBusy ? null : _loginWithGoogle,
                        ),
                        const SizedBox(height: 22),
                        _SwitchAuthLink(
                          question: 'Ainda não tem conta?',
                          action: 'Criar conta',
                          onTap: isBusy
                              ? null
                              : () => context.go(AppRoutes.signUp),
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final textDim =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: .5);

    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: AppTextStyles.jakarta(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textDim,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _SwitchAuthLink extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback? onTap;

  const _SwitchAuthLink({
    required this.question,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textDim =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: AppTextStyles.jakarta(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textDim,
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}