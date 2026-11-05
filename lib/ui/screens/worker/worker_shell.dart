import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/data/models/app_user.dart';
import 'package:vitalis/logic/providers/alerts_provider.dart';
import 'package:vitalis/logic/providers/monitoring_provider.dart';
import 'package:vitalis/ui/screens/shared/alerts_screen.dart';
import 'package:vitalis/ui/screens/shared/profile_screen.dart';
import 'package:vitalis/ui/screens/worker/history_screen.dart';
import 'package:vitalis/ui/screens/worker/monitor_screen.dart';

/// Navegação principal do trabalhador rural.
class WorkerShell extends StatefulWidget {
  const WorkerShell({super.key, required this.user});

  final AppUser user;

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Inicia depois do primeiro frame para não notificar durante o build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MonitoringProvider>().startPersonal(widget.user);
      context.read<AlertsProvider>().load(workerIds: {widget.user.id});
    });
  }

  @override
  Widget build(BuildContext context) {
    final openAlerts = context.select<AlertsProvider, int>(
      (provider) => provider.openCount,
    );

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          MonitorScreen(user: widget.user),
          HistoryScreen(user: widget.user),
          const AlertsScreen(showWorkerNames: false),
          ProfileScreen(user: widget.user),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart),
            label: 'Monitor',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: openAlerts > 0,
              label: Text('$openAlerts'),
              child: const Icon(Icons.notifications_outlined),
            ),
            label: 'Alertas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
