import 'package:flutter/material.dart';
import 'package:vitalis/core/utils/formatters.dart';
import 'package:vitalis/data/models/risk.dart';
import 'package:vitalis/ui/theme/risk_style.dart';

/// Bloco principal do monitoramento: a temperatura do pulso em destaque,
/// pintado com a cor do risco atual e com a orientação do que fazer.
class RiskHero extends StatelessWidget {
  const RiskHero({
    super.key,
    required this.assessment,
    required this.temperature,
  });

  final RiskAssessment assessment;
  final double? temperature;

  @override
  Widget build(BuildContext context) {
    final style = RiskStyle.of(assessment.level);
    final textTheme = Theme.of(context).textTheme;
    final value = temperature;

    return Semantics(
      container: true,
      label: 'Situação: ${assessment.level.label}. ${assessment.title}.',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: style.color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(style.icon, color: style.onColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  assessment.level.label,
                  style: textTheme.titleMedium?.copyWith(color: style.onColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value == null ? '-- °C' : Formatters.temperature(value),
              style: TextStyle(
                fontSize: 64,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: -2,
                color: style.onColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Temperatura da pele no pulso',
              style: textTheme.bodySmall?.copyWith(
                color: style.onColor.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              assessment.title,
              style: textTheme.titleLarge?.copyWith(color: style.onColor),
            ),
            const SizedBox(height: 4),
            Text(
              assessment.message,
              style: textTheme.bodyMedium?.copyWith(color: style.onColor),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.water_drop_outlined, color: style.onColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      assessment.recommendation,
                      style: textTheme.bodyMedium?.copyWith(
                        color: style.onColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
