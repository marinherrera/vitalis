import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/core/utils/formatters.dart';
import 'package:vitalis/data/models/app_user.dart';
import 'package:vitalis/logic/providers/alerts_provider.dart';
import 'package:vitalis/logic/providers/auth_provider.dart';
import 'package:vitalis/logic/providers/monitoring_provider.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/widgets/section_title.dart';
import 'package:vitalis/ui/widgets/simulator_panel.dart';
import 'package:vitalis/ui/widgets/surface_card.dart';

/// Dados da conta, simulador do sensor (trabalhador) e saída.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user});

  final AppUser user;

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    context.read<MonitoringProvider>().stop();
    context.read<AlertsProvider>().reset();
    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SurfaceCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.fieldSoft,
                  child: Text(
                    Formatters.initials(user.name),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.fieldDark,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(user.email, style: textTheme.bodySmall),
                      const SizedBox(height: 6),
                      Text(
                        '${user.role.label}, ${user.activity.toLowerCase()}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.field,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (!user.isSupervisor) ...[
            const SectionTitle(
              title: 'Simulador do sensor',
              subtitle:
                  'Enquanto o protótipo ESP32 + DS18B20 não está montado, as leituras são simuladas. Use estes controles na demonstração.',
            ),
            SimulatorPanel(workerId: user.id),
            const SizedBox(height: 28),
          ],
          const SectionTitle(title: 'Sobre o Vitalis'),
          SurfaceCard(
            child: Text(
              'O Vitalis acompanha a temperatura da pele no pulso e avisa quando há sinais de desidratação ou exaustão pelo calor. '
              'É um protótipo acadêmico: os limites usados são ilustrativos e não substituem orientação médica.',
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    );
  }
}
