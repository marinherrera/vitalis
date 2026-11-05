import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/logic/providers/alerts_provider.dart';
import 'package:vitalis/ui/widgets/alert_tile.dart';
import 'package:vitalis/ui/widgets/state_views.dart';

/// Lista de alertas. O trabalhador vê os próprios; o supervisor vê os da
/// equipe toda, com o nome de cada trabalhador.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, required this.showWorkerNames});

  final bool showWorkerNames;

  Future<void> _confirmClearResolved(BuildContext context) async {
    final provider = context.read<AlertsProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar alertas resolvidos?'),
        content: const Text(
          'Os alertas resolvidos saem da lista. Os que ainda estão abertos continuam.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await provider.clearResolved();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertsProvider>();
    final alerts = provider.alerts;
    final hasResolved = alerts.any((alert) => alert.resolved);
    final error = provider.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
          if (hasResolved)
            IconButton(
              tooltip: 'Limpar alertas resolvidos',
              onPressed: () => _confirmClearResolved(context),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const LoadingView(message: 'Carregando alertas...');
          }
          if (error != null) {
            return ErrorView(
              title: 'Alertas indisponíveis',
              message: error,
              onAction: provider.retry,
            );
          }
          if (alerts.isEmpty) {
            return EmptyView(
              icon: Icons.notifications_none,
              title: 'Nenhum alerta por enquanto',
              message: showWorkerNames
                  ? 'Quando alguém da equipe entrar em risco, o alerta aparece aqui.'
                  : 'Quando o sensor indicar risco, o alerta aparece aqui.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const Divider(indent: 68),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return AlertTile(
                alert: alert,
                showWorkerName: showWorkerNames,
                onResolve: alert.resolved ? null : () => provider.resolve(alert.id),
              );
            },
          );
        },
      ),
    );
  }
}
