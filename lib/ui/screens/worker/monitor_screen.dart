import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/data/models/app_user.dart';
import 'package:vitalis/logic/providers/monitoring_provider.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/widgets/state_views.dart';
import 'package:vitalis/ui/widgets/worker_dashboard.dart';

/// Tela principal do trabalhador: situação atual, indicadores e gráfico.
class MonitorScreen extends StatelessWidget {
  const MonitorScreen({super.key, required this.user});

  final AppUser user;

  void _registerHydration(BuildContext context) {
    context.read<MonitoringProvider>().registerHydration(user.id);
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Pausa para beber água registrada.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final monitoring = context.watch<MonitoringProvider>();
    final monitor = monitoring.monitorFor(user.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${user.firstName}'),
        actions: [
          if (monitor != null) _SensorStatus(isOnline: monitor.isOnline),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (monitoring.status == MonitoringStatus.failure) {
            return ErrorView(
              title: 'Monitoramento não iniciado',
              message: monitoring.errorMessage ?? 'Tente novamente.',
              onAction: monitoring.retry,
            );
          }
          if (monitoring.status != MonitoringStatus.active || monitor == null) {
            return const LoadingView(message: 'Conectando ao sensor do pulso...');
          }
          if (!monitor.isOnline) {
            return ErrorView(
              icon: Icons.sensors_off,
              iconColor: AppColors.offline,
              title: 'Sensor sem sinal',
              message: monitor.batteryLevel == 0
                  ? 'A bateria do sensor acabou. Recarregue e reconecte para voltar a monitorar.'
                  : 'O app parou de receber dados. Confira se o sensor está ligado e perto do celular.',
              actionLabel: 'Reconectar sensor',
              onAction: () => monitoring.reconnect(user.id),
            );
          }
          return WorkerDashboard(
            monitor: monitor,
            action: FilledButton.icon(
              onPressed: () => _registerHydration(context),
              icon: const Icon(Icons.water_drop),
              label: const Text('Registrar pausa para beber água'),
            ),
          );
        },
      ),
    );
  }
}

class _SensorStatus extends StatelessWidget {
  const _SensorStatus({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.normalText : AppColors.offlineText;
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isOnline ? Icons.sensors : Icons.sensors_off, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Sensor ativo' : 'Sem sinal',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
