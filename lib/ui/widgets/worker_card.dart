import 'package:flutter/material.dart';
import 'package:vitalis/core/utils/formatters.dart';
import 'package:vitalis/data/models/risk.dart';
import 'package:vitalis/logic/monitoring/worker_monitor.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/theme/risk_style.dart';
import 'package:vitalis/ui/widgets/risk_badge.dart';
import 'package:vitalis/ui/widgets/temperature_sparkline.dart';

/// Cartão de um trabalhador na equipe. Todo o cartão é pintado com a cor da
/// situação (verde, amarelo, vermelho ou cinza), então dá para ver quem está
/// em risco de longe.
class WorkerCard extends StatelessWidget {
  const WorkerCard({
    super.key,
    required this.monitor,
    required this.onTap,
    this.selected = false,
  });

  final WorkerMonitor monitor;
  final VoidCallback onTap;

  /// Destaca o cartão do trabalhador aberto no painel lateral.
  final bool selected;

  /// Estilo da situação atual: sem sinal tem prioridade sobre o nível de risco.
  static RiskStyle styleOf(WorkerMonitor monitor) => monitor.isOnline
      ? RiskStyle.of(monitor.assessment.level)
      : RiskStyle.offline;

  /// Linha de aviso do cartão. Nulo quando está tudo normal.
  static String? statusMessage(WorkerMonitor monitor) {
    if (!monitor.isOnline) return 'Sem sinal do sensor';
    if (monitor.assessment.level != RiskLevel.normal) {
      return monitor.assessment.title;
    }
    if (monitor.isLowBattery) return 'Bateria do sensor baixa';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = styleOf(monitor);
    final isCritical =
        monitor.isOnline && monitor.assessment.level == RiskLevel.critical;
    final latest = monitor.latest;
    final message = statusMessage(monitor);
    final temperature =
        latest == null ? '--' : Formatters.temperature(latest.skinTemperature);
    final valueColor = !monitor.isOnline
        ? AppColors.offlineText
        : monitor.assessment.level == RiskLevel.normal
            ? AppColors.ink
            : style.textColor;

    final background = Color.alphaBlend(
      style.color.withValues(alpha: isCritical ? 0.14 : 0.09),
      AppColors.surface,
    );
    final BorderSide border = selected
        ? const BorderSide(color: AppColors.ink, width: 2.5)
        : isCritical
            ? BorderSide(color: style.color, width: 2)
            : BorderSide(color: style.color.withValues(alpha: 0.4));
    final radius = BorderRadius.circular(16);

    return Semantics(
      button: true,
      onTap: onTap,
      label: '${monitor.worker.name}, ${monitor.worker.activity}. '
          '${monitor.isOnline ? monitor.assessment.level.label : 'Sem sinal'}. '
          'Temperatura $temperature.',
      excludeSemantics: true,
      child: Material(
        color: background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: radius, side: border),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            monitor.worker.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            monitor.worker.activity,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (monitor.isOnline)
                      RiskBadge.level(monitor.assessment.level)
                    else
                      const RiskBadge.offline(),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TEMPERATURA', style: _labelStyle),
                        const SizedBox(height: 2),
                        Text(
                          temperature,
                          style: TextStyle(
                            fontSize: 26,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: valueColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TemperatureSparkline(
                        readings: monitor.readings,
                        color: style.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _BatteryRing(
                      level: monitor.batteryLevel,
                      color: monitor.isLowBattery
                          ? AppColors.riskCritical
                          : style.color,
                    ),
                  ],
                ),
                if (message != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    decoration: BoxDecoration(
                      color: style.color.withValues(alpha: 0.14),
                      border: Border(
                        left: BorderSide(color: style.color, width: 3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(style.icon, size: 16, color: style.textColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: style.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
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

/// Anel com a carga da bateria do sensor.
class _BatteryRing extends StatelessWidget {
  const _BatteryRing({required this.level, required this.color});

  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: level.clamp(0, 100) / 100,
                  strokeWidth: 4,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.2),
                ),
              ),
              Text(
                '$level',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'bateria',
          style: TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }
}
