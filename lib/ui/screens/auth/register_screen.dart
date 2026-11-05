import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/core/utils/validators.dart';
import 'package:vitalis/data/models/user_role.dart';
import 'package:vitalis/logic/providers/auth_provider.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/widgets/app_text_field.dart';
import 'package:vitalis/ui/widgets/form_error_banner.dart';
import 'package:vitalis/ui/widgets/loading_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _activityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  UserRole _role = UserRole.worker;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _activityController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateConfirmation(String? value) {
    if ((value ?? '').isEmpty) return 'Repita a senha.';
    if (value != _passwordController.text) return 'As senhas não são iguais.';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final error = await auth.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _role,
      activity: _activityController.text,
    );
    if (error == null) {
      // Volta para a raiz, que já mostra a tela inicial do perfil criado.
      navigator.popUntil((route) => route.isFirst);
      return;
    }
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final error = _error;
    final isWorker = _role == UserRole.worker;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Como você vai usar o Vitalis?', style: textTheme.titleMedium),
                    const SizedBox(height: 10),
                    SegmentedButton<UserRole>(
                      segments: const [
                        ButtonSegment(
                          value: UserRole.worker,
                          icon: Icon(Icons.agriculture),
                          label: Text('Trabalhador'),
                        ),
                        ButtonSegment(
                          value: UserRole.supervisor,
                          icon: Icon(Icons.groups_outlined),
                          label: Text('Supervisor'),
                        ),
                      ],
                      selected: {_role},
                      onSelectionChanged: (selection) =>
                          setState(() => _role = selection.first),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isWorker
                          ? 'Você acompanha o seu próprio sensor durante a jornada.'
                          : 'Você acompanha todos os trabalhadores cadastrados no app.',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 22),
                    AppTextField(
                      controller: _nameController,
                      label: 'Nome completo',
                      icon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 14),
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
                      controller: _activityController,
                      label: isWorker
                          ? 'Atividade no campo (opcional)'
                          : 'Fazenda ou setor (opcional)',
                      hint: isWorker ? 'Ex.: colheita de café' : 'Ex.: Fazenda Boa Safra',
                      icon: isWorker ? Icons.agriculture : Icons.badge_outlined,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: Validators.password,
                      suffix: IconButton(
                        tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _confirmController,
                      label: 'Repita a senha',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirmation,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 14),
                      FormErrorBanner(message: error),
                    ],
                    const SizedBox(height: 22),
                    LoadingButton(
                      label: 'Criar conta',
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Os dados ficam salvos apenas neste aparelho.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
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
