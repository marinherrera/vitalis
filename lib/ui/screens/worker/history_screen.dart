import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/core/utils/formatters.dart';
import 'package:vitalis/data/models/app_user.dart';
import 'package:vitalis/logic/providers/monitoring_provider.dart';
import 'package:vitalis/logic/reading_stats.dart';
import 'package:vitalis/logic/risk_analyzer.dart';
import 'package:vitalis/ui/theme/risk_style.dart';
import 'package:vitalis/ui/widgets/state_views.dart';
import 'package:vitalis/ui/widgets/surface_card.dart';

/// Leituras registradas na jornada atual, com um resumo no topo.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final monitoring = context.watch<MonitoringProvider>();
    final monitor = monitoring.monitorFor(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico da jornada')),
      body: Builder(
        builder: (context) {
          if (monitoring.status == MonitoringStatus.failure) {
            return ErrorView(
              title: 'Histórico indisponível',
              message: monitoring.errorMessage ?? 'Tente novamente.',
              onAction: monitoring.retry,
            );
          }
          if (monitor == null) {
            return const LoadingView(message: 'Carregando leituras...');
          }
          final stats = ReadingStats.from(monitor.readings);
          if (stats == null) {
            return const EmptyView(
              icon: Icons.history,
              title: 'Nenhuma leitura ainda',
              message: 'Assim que o sensor enviar dados, eles aparecem aqui.',
            );
          }
          final readings = monitor.readings.reversed.toList();
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: readings.length + 1,
            separatorBuilder: (_, index) => index == 0
                ? const SizedBox(height: 8)
                : const Divider(indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _StatsPanel(stats: stats),
                );
              }
              final reading = readings[index - 1];
              final style = RiskStyle.of(
                RiskAnalyzer.levelForTemperature(reading.skinTemperature),
              );
              return ListTile(
                leading: Icon(style.icon, color: style.textColor),
                title: Text(
                  Formatters.temperature(reading.skinTemperature),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                subtitle: Text('Bateria ${reading.batteryLevel}%'),
                trailing: Text(
                  Formatters.time(reading.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.stats});

  final ReadingStats stats;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _Stat(label: 'Mínima', value: stats.minimum)),
              Expanded(child: _Stat(label: 'Média', value: stats.average)),
              Expanded(child: _Stat(label: 'Máxima', value: stats.maximum)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${stats.aboveAttention} de ${stats.count} leituras acima do limite de atenção.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          Formatters.temperature(value),
          style: textTheme.titleMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
