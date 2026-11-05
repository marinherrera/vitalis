import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/core/utils/validators.dart';
import 'package:vitalis/data/repositories/user_repository.dart';
import 'package:vitalis/logic/providers/auth_provider.dart';
import 'package:vitalis/ui/screens/auth/register_screen.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/widgets/app_text_field.dart';
import 'package:vitalis/ui/widgets/form_error_banner.dart';
import 'package:vitalis/ui/widgets/loading_button.dart';
import 'package:vitalis/ui/widgets/surface_card.dart';
import 'package:vitalis/ui/widgets/vitalis_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final error = await auth.login(
      _emailController.text,
      _passwordController.text,
    );
    // Em caso de sucesso esta tela já foi substituída pela tela inicial.
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _error = error;
    });
  }

  void _useDemoAccount(String email) {
    _emailController.text = email;
    _passwordController.text = UserRepository.demoPassword;
    setState(() => _error = null);
  }

  void _openRegister() {
    setState(() => _error = null);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final error = _error;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: VitalisLogo(size: 48),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Cuide de quem trabalha no sol',
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Acompanhe sinais de desidratação e exaustão pelo calor durante a jornada no campo.',
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 28),
                      AppTextField(
                        controller: _emailController,
                        label: 'E-mail',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Senha',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: Validators.password,
                        onFieldSubmitted: (_) => _submit(),
                        suffix: IconButton(
                          tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
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
                      if (error != null) ...[
                        const SizedBox(height: 14),
                        FormErrorBanner(message: error),
                      ],
                      const SizedBox(height: 22),
                      LoadingButton(
                        label: 'Entrar',
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isSubmitting ? null : _openRegister,
                        child: const Text('Criar uma conta'),
                      ),
                      const SizedBox(height: 20),
                      _DemoAccounts(onSelect: _useDemoAccount),
                    ],
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

/// Atalhos para as contas de demonstração criadas na primeira execução.
class _DemoAccounts extends StatelessWidget {
  const _DemoAccounts({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contas de demonstração', style: textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            'Toque para preencher. A senha de todas é ${UserRepository.demoPassword}.',
            style: textTheme.bodySmall,
          ),
          _DemoAccountTile(
            icon: Icons.agriculture,
            title: 'Trabalhador',
            email: UserRepository.demoWorkerEmail,
            onTap: () => onSelect(UserRepository.demoWorkerEmail),
          ),
          const Divider(),
          _DemoAccountTile(
            icon: Icons.groups_outlined,
            title: 'Supervisor',
            email: UserRepository.demoSupervisorEmail,
            onTap: () => onSelect(UserRepository.demoSupervisorEmail),
          ),
        ],
      ),
    );
  }
}

class _DemoAccountTile extends StatelessWidget {
  const _DemoAccountTile({
    required this.icon,
    required this.title,
    required this.email,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.field),
      title: Text(title),
      subtitle: Text(email),
      trailing: const Text(
        'Usar',
        style: TextStyle(color: AppColors.field, fontWeight: FontWeight.w700),
      ),
      onTap: onTap,
    );
  }
}
