import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/data/models/heat_scenario.dart';
import 'package:vitalis/logic/providers/monitoring_provider.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/widgets/surface_card.dart';

/// Controles do sensor simulado, para demonstrar o app sem o hardware.
class SimulatorPanel extends StatelessWidget {
  const SimulatorPanel({super.key, required this.workerId});

  final String workerId;

  @override
  Widget build(BuildContext context) {
    final monitoring = context.watch<MonitoringProvider>();
    final monitor = monitoring.monitorFor(workerId);
    final textTheme = Theme.of(context).textTheme;

    if (monitor == null) {
      return SurfaceCard(
        child: Text(
          'Os controles aparecem quando o sensor terminar de conectar.',
          style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
      );
    }

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cenário de calor', style: textTheme.titleMedium),
          for (final scenario in HeatScenario.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(scenario.label),
              subtitle: Text(scenario.description),
              trailing: Icon(
                scenario == monitor.scenario
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: scenario == monitor.scenario
                    ? AppColors.field
                    : AppColors.line,
              ),
              onTap: () => monitoring.changeScenario(workerId, scenario),
            ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sensor conectado'),
            subtitle: Text(
              monitor.isOnline
                  ? 'Recebendo uma leitura a cada 2 segundos.'
                  : 'Sem sinal. Ative para reconectar.',
            ),
            value: monitor.isOnline,
            onChanged: (connected) => connected
                ? monitoring.reconnect(workerId)
                : monitoring.simulateSignalLoss(workerId),
          ),
        ],
      ),
    );
  }
}
