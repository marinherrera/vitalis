import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/data/models/app_user.dart';
import 'package:vitalis/data/repositories/alert_repository.dart';
import 'package:vitalis/data/repositories/user_repository.dart';
import 'package:vitalis/logic/providers/alerts_provider.dart';
import 'package:vitalis/logic/providers/auth_provider.dart';
import 'package:vitalis/logic/providers/monitoring_provider.dart';
import 'package:vitalis/ui/screens/auth/login_screen.dart';
import 'package:vitalis/ui/screens/splash_screen.dart';
import 'package:vitalis/ui/screens/supervisor/supervisor_shell.dart';
import 'package:vitalis/ui/screens/worker/worker_shell.dart';
import 'package:vitalis/ui/theme/app_theme.dart';

/// Raiz do app: registra os providers e aplica o tema.
class VitalisApp extends StatelessWidget {
  const VitalisApp({
    super.key,
    required this.userRepository,
    required this.alertRepository,
  });

  final UserRepository userRepository;
  final AlertRepository alertRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(userRepository)..restoreSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => AlertsProvider(alertRepository),
        ),
        ChangeNotifierProvider(
          create: (context) => MonitoringProvider(
            userRepository: userRepository,
            alerts: context.read<AlertsProvider>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Vitalis',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}

/// Decide a primeira tela de acordo com a sessão e o perfil do usuário.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return switch (auth.status) {
      AuthStatus.checking => const SplashScreen(),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated => _homeFor(auth.currentUser!),
    };
  }

  Widget _homeFor(AppUser user) {
    // A chave garante que a tela inicial é recriada ao trocar de conta.
    return user.isSupervisor
        ? SupervisorShell(key: ValueKey(user.id), user: user)
        : WorkerShell(key: ValueKey(user.id), user: user);
  }
}
