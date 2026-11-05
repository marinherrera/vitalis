import 'package:flutter/material.dart';
import 'package:vitalis/core/utils/formatters.dart';
import 'package:vitalis/data/models/risk.dart';
import 'package:vitalis/logic/monitoring/worker_monitor.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/theme/risk_style.dart';
import 'package:vitalis/ui/widgets/surface_card.dart';
import 'package:vitalis/ui/widgets/temperature_sparkline.dart';
import 'package:vitalis/ui/widgets/worker_card.dart';

/// Ações que o supervisor pode tomar a partir do painel do trabalhador.
enum WorkerAction {
  callRescue('Acionar socorro imediato'),
  removeFromField('Retirar do campo'),
  logIncident('Registrar ocorrência');

  const WorkerAction(this.label);

  final String label;
}

/// Painel lateral com o status atual do trabalhador selecionado e as ações
/// recomendadas para a situação dele.
class WorkerSidePanel extends StatelessWidget {
  const WorkerSidePanel({
    super.key,
    required this.monitor,
    required this.onClose,
    required this.onOpenDetails,
    required this.onAction,
  });

  final WorkerMonitor monitor;
  final VoidCallback onClose;
  final VoidCallback onOpenDetails;
  final ValueChanged<WorkerAction> onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = WorkerCard.styleOf(monitor);
    final isCritical =
        monitor.isOnline && monitor.assessment.level == RiskLevel.critical;
    final latest = monitor.latest;
    final statusLabel =
        monitor.isOnline ? monitor.assessment.level.label : 'Sem sinal';
    final statusTitle =
        monitor.isOnline ? monitor.assessment.title : 'Sensor sem comunicação';
    final statusMessage = monitor.isOnline
        ? monitor.assessment.message
        : 'Combine um contato com ${monitor.worker.firstName}. '
            'Mostrando a última leitura recebida.';

    return Container(
      color: AppColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(monitor.worker.name, style: textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(monitor.worker.activity, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Fechar painel',
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: BoxDecoration(
                color: style.color,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STATUS ATUAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: style.onColor.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(style.icon, color: style.onColor, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          statusLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 28,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: style.onColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    statusTitle,
                    style: textTheme.titleMedium?.copyWith(color: style.onColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusMessage,
                    style: textTheme.bodyMedium?.copyWith(color: style.onColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'TEMPERATURA',
                    value: latest == null
                        ? '--'
                        : Formatters.temperature(latest.skinTemperature),
                    valueColor: monitor.isOnline &&
                            monitor.assessment.level != RiskLevel.normal
                        ? style.textColor
                        : AppColors.ink,
                    footer: TemperatureSparkline(
                      readings: monitor.readings,
                      color: style.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'BATERIA',
                    value: '${monitor.batteryLevel}%',
                    valueColor: monitor.isLowBattery
                        ? AppColors.criticalText
                        : AppColors.ink,
                    footer: Icon(
                      RiskStyle.batteryIcon(monitor.batteryLevel),
                      size: 40,
                      color: monitor.isLowBattery
                          ? AppColors.riskCritical
                          : AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
            if (monitor.isOnline) ...[
              const SizedBox(height: 12),
              SurfaceCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.water_drop_outlined,
                      size: 20,
                      color: AppColors.field,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        monitor.assessment.recommendation,
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text('AÇÕES RECOMENDADAS', style: _labelStyle),
            const SizedBox(height: 10),
            if (isCritical) ...[
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.riskCritical,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => onAction(WorkerAction.callRescue),
                child: Text(WorkerAction.callRescue.label),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.criticalText,
                  side: const BorderSide(color: AppColors.riskCritical),
                ),
                onPressed: () => onAction(WorkerAction.removeFromField),
                child: Text(WorkerAction.removeFromField.label),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton(
              onPressed: () => onAction(WorkerAction.logIncident),
              child: Text(WorkerAction.logIncident.label),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onOpenDetails,
              child: const Text('Ver detalhes completos'),
            ),
            const Divider(height: 28),
            Text(
              latest == null
                  ? 'Nenhuma leitura recebida ainda.'
                  : 'Última leitura às ${Formatters.time(latest.timestamp)}',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

const TextStyle _labelStyle = TextStyle(
  fontSize: 10.5,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.8,
  color: AppColors.muted,
);

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.footer,
  });

  final String label;
  final String value;
  final Color valueColor;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: valueColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 8),
          footer,
        ],
      ),
    );
  }
}
