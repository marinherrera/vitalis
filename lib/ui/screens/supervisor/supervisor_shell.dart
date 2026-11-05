import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitalis/data/models/app_user.dart';
import 'package:vitalis/logic/providers/alerts_provider.dart';
import 'package:vitalis/logic/providers/monitoring_provider.dart';
import 'package:vitalis/ui/screens/shared/alerts_screen.dart';
import 'package:vitalis/ui/screens/shared/profile_screen.dart';
import 'package:vitalis/ui/screens/supervisor/team_screen.dart';

/// Navegação principal do supervisor.
class SupervisorShell extends StatefulWidget {
  const SupervisorShell({super.key, required this.user});

  final AppUser user;

  @override
  State<SupervisorShell> createState() => _SupervisorShellState();
}

class _SupervisorShellState extends State<SupervisorShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MonitoringProvider>().startTeam();
      context.read<AlertsProvider>().load();
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
          const TeamScreen(),
          const AlertsScreen(showWorkerNames: true),
          ProfileScreen(user: widget.user),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Equipe',
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
