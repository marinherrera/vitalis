import 'package:flutter/material.dart';
import 'package:vitalis/data/models/risk.dart';
import 'package:vitalis/ui/theme/risk_style.dart';

/// Etiqueta compacta com a situação de risco.
class RiskBadge extends StatelessWidget {
  RiskBadge.level(RiskLevel level, {super.key})
      : label = level.label,
        style = RiskStyle.of(level);

  const RiskBadge.offline({super.key})
      : label = 'Sem sinal',
        style = RiskStyle.offline;

  final String label;
  final RiskStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: style.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
