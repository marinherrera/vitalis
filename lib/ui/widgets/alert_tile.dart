import 'package:flutter/material.dart';
import 'package:vitalis/core/utils/formatters.dart';
import 'package:vitalis/data/models/risk_alert.dart';
import 'package:vitalis/ui/theme/app_colors.dart';
import 'package:vitalis/ui/theme/risk_style.dart';

/// Item da lista de alertas.
class AlertTile extends StatelessWidget {
  const AlertTile({
    super.key,
    required this.alert,
    this.showWorkerName = false,
    this.onResolve,
  });

  final RiskAlert alert;
  final bool showWorkerName;
  final VoidCallback? onResolve;

  @override
  Widget build(BuildContext context) {
    final style = RiskStyle.forAlert(alert.type);
    final textTheme = Theme.of(context).textTheme;
    final resolve = onResolve;

    return Opacity(
      opacity: alert.resolved ? 0.6 : 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(style.icon, color: style.textColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          showWorkerName ? alert.workerName : alert.type.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.dateTime(alert.createdAt),
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (showWorkerName)
                    Text(
                      alert.type.label,
                      style: textTheme.bodySmall?.copyWith(
                        color: style.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(alert.message, style: textTheme.bodyMedium),
                  if (alert.resolved)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.normalText,
                          ),
                          const SizedBox(width: 4),
                          Text('Resolvido', style: textTheme.bodySmall),
                        ],
                      ),
                    )
                  else if (resolve != null)
                    TextButton.icon(
                      onPressed: resolve,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Marcar como resolvido'),
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
