import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalis/data/local/local_storage.dart';
import 'package:vitalis/data/models/risk.dart';
import 'package:vitalis/data/repositories/user_repository.dart';
import 'package:vitalis/logic/providers/auth_provider.dart';
import 'package:vitalis/ui/screens/auth/login_screen.dart';
import 'package:vitalis/ui/theme/app_theme.dart';
import 'package:vitalis/ui/widgets/risk_badge.dart';
import 'package:vitalis/ui/widgets/state_views.dart';

void main() {
  testWidgets('RiskBadge mostra o rótulo do nível de risco', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RiskBadge.level(RiskLevel.critical))),
    );
    expect(find.text('Risco alto'), findsOneWidget);
  });

  testWidgets('ErrorView executa a ação do botão', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            title: 'Falha',
            message: 'Algo deu errado.',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Tentar novamente'));
    expect(tapped, isTrue);
  });

  testWidgets('Login valida os campos antes de entrar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = UserRepository(LocalStorage(preferences));

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(repository),
        child: MaterialApp(theme: AppTheme.light(), home: const LoginScreen()),
      ),
    );

    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
  });
}
