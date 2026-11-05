import 'package:flutter/material.dart';
import 'package:vitalis/core/constants/risk_thresholds.dart';
import 'package:vitalis/core/utils/formatters.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/theme/risk_style.dart';
import 'package:vitalis/ui/widgets/surface_card.dart';

/// Linha com bateria do sensor, tempo de monitoramento e última hidratação.
class VitalsPanel extends StatelessWidget {
  const VitalsPanel({
    super.key,
    required this.batteryLevel,
    required this.monitoredFor,
    required this.lastHydration,
    required this.now,
  });

  final int batteryLevel;
  final Duration monitoredFor;
  final DateTime? lastHydration;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final hydration = lastHydration;
    final isLowBattery = batteryLevel <= RiskThresholds.lowBattery;
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _VitalItem(
                icon: RiskStyle.batteryIcon(batteryLevel),
                label: 'Bateria',
                value: '$batteryLevel%',
                color: isLowBattery ? AppColors.criticalText : null,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _VitalItem(
                icon: Icons.timer_outlined,
                label: 'Monitorando',
                value: Formatters.duration(monitoredFor),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _VitalItem(
                icon: Icons.water_drop_outlined,
                label: 'Última pausa',
                value: hydration == null
                    ? 'Nenhuma'
                    : Formatters.elapsedSince(hydration, now),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalItem extends StatelessWidget {
  const _VitalItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color ?? AppColors.field),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
