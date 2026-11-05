import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/core/utils/formatters.dart';
import 'package:vitalis/logic/providers/alerts_provider.dart';
import 'package:vitalis/logic/providers/monitoring_provider.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/widgets/alert_tile.dart';
import 'package:vitalis/ui/widgets/section_title.dart';
import 'package:vitalis/ui/widgets/state_views.dart';
import 'package:vitalis/ui/widgets/surface_card.dart';
import 'package:vitalis/ui/widgets/worker_dashboard.dart';

/// Detalhe de um trabalhador, visto pelo supervisor.
class WorkerDetailScreen extends StatelessWidget {
  const WorkerDetailScreen({super.key, required this.workerId});

  final String workerId;

  static const int _recentAlertsLimit = 5;

  @override
  Widget build(BuildContext context) {
    final monitor = context.watch<MonitoringProvider>().monitorFor(workerId);
    final alertsProvider = context.watch<AlertsProvider>();

    if (monitor == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(
          icon: Icons.person_off,
          title: 'Trabalhador indisponível',
          message: 'Os dados deste trabalhador não estão mais no monitoramento.',
        ),
      );
    }

    final alerts = alertsProvider.alertsFor(workerId).take(_recentAlertsLimit).toList();
    final latest = monitor.latest;

    return Scaffold(
      appBar: AppBar(title: Text(monitor.worker.name)),
      body: WorkerDashboard(
        monitor: monitor,
        header: monitor.isOnline
            ? Text(monitor.worker.activity, style: Theme.of(context).textTheme.bodyMedium)
            : _OfflineNotice(
                message: latest == null
                    ? 'O sensor ainda não enviou nenhuma leitura.'
                    : 'Sem sinal do sensor. Mostrando a última leitura, das ${Formatters.time(latest.timestamp)}. '
                        'Combine um contato com ${monitor.worker.firstName}.',
              ),
        bottom: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Alertas recentes',
              subtitle: 'Os 5 mais recentes deste trabalhador.',
            ),
            SurfaceCard(
              padding: EdgeInsets.zero,
              child: alerts.isEmpty
                  ? const EmptyView(
                      icon: Icons.notifications_none,
                      title: 'Nenhum alerta',
                      message: 'Este trabalhador ainda não teve alertas.',
                      compact: true,
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < alerts.length; i++) ...[
                          if (i > 0) const Divider(indent: 68),
                          AlertTile(
                            alert: alerts[i],
                            onResolve: alerts[i].resolved
                                ? null
                                : () => alertsProvider.resolve(alerts[i].id),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.offline.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sensors_off, color: AppColors.offlineText, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.offlineText),
            ),
          ),
        ],
      ),
    );
  }
}
