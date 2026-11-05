import 'package:vitalis/data/models/risk.dart';
import 'package:vitalis/logic/monitoring/worker_monitor.dart';

/// Filtros da lista da equipe do supervisor.
enum TeamFilter {
  all('Todos'),
  critical('Risco alto'),
  attention('Atenção'),
  offline('Sem sinal'),
  normal('Normal');

  const TeamFilter(this.label);

  final String label;

  bool matches(WorkerMonitor monitor) {
    final level = monitor.assessment.level;
    return switch (this) {
      TeamFilter.all => true,
      TeamFilter.critical => monitor.isOnline && level == RiskLevel.critical,
      TeamFilter.attention => monitor.isOnline && level == RiskLevel.attention,
      TeamFilter.offline => !monitor.isOnline,
      TeamFilter.normal => monitor.isOnline && level == RiskLevel.normal,
    };
  }
}
