import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:vitalis/core/constants/app_config.dart';
import 'package:vitalis/core/utils/formatters.dart';
import 'package:vitalis/data/models/app_user.dart';
import 'package:vitalis/data/models/heat_scenario.dart';
import 'package:vitalis/data/models/risk.dart';
import 'package:vitalis/data/models/risk_alert.dart';
import 'package:vitalis/data/repositories/user_repository.dart';
import 'package:vitalis/data/services/simulated_sensor.dart';
import 'package:vitalis/logic/monitoring/worker_monitor.dart';
import 'package:vitalis/logic/providers/alerts_provider.dart';
import 'package:vitalis/logic/risk_analyzer.dart';

enum MonitoringStatus { idle, connecting, active, failure }

/// Coleta as leituras dos sensores, analisa o risco e emite alertas.
///
/// O trabalhador monitora apenas o próprio sensor ([startPersonal]); o
/// supervisor monitora todos os trabalhadores da equipe ([startTeam]).
class MonitoringProvider extends ChangeNotifier {
  MonitoringProvider({
    required UserRepository userRepository,
    required AlertsProvider alerts,
    RiskAnalyzer analyzer = const RiskAnalyzer(),
    Duration interval = AppConfig.sensorInterval,
    Duration connectionDelay = AppConfig.connectionDelay,
    Random? random,
  })  : _users = userRepository,
        _alerts = alerts,
        _analyzer = analyzer,
        _interval = interval,
        _connectionDelay = connectionDelay,
        _random = random ?? Random();

  final UserRepository _users;
  final AlertsProvider _alerts;
  final RiskAnalyzer _analyzer;
  final Duration _interval;
  final Duration _connectionDelay;
  final Random _random;

  final Map<String, WorkerMonitor> _monitors = {};
  Timer? _timer;
  int _session = 0;
  MonitoringStatus _status = MonitoringStatus.idle;
  String? _errorMessage;
  Future<void> Function()? _lastStart;

  MonitoringStatus get status => _status;
  String? get errorMessage => _errorMessage;

  /// Monitores ordenados por prioridade (risco alto primeiro) e nome.
  List<WorkerMonitor> get monitors {
    final list = _monitors.values.toList()
      ..sort((a, b) {
        final byPriority = b.priority.compareTo(a.priority);
        if (byPriority != 0) return byPriority;
        return a.worker.name.compareTo(b.worker.name);
      });
    return list;
  }

  WorkerMonitor? monitorFor(String workerId) => _monitors[workerId];

  Future<void> startPersonal(AppUser worker) {
    _lastStart = () => _start(
          () async => [worker],
          (_) => SimulationProfile.personal,
        );
    return _lastStart!();
  }

  Future<void> startTeam() {
    _lastStart = () => _start(
          _users.fetchWorkers,
          SimulationProfile.forTeamMember,
        );
    return _lastStart!();
  }

  Future<void> retry() => _lastStart?.call() ?? Future<void>.value();

  void stop() {
    _session++;
    _cancelTimer();
    _monitors.clear();
    _status = MonitoringStatus.idle;
    _errorMessage = null;
    _lastStart = null;
    notifyListeners();
  }

  /// O trabalhador registrou uma pausa para beber água.
  void registerHydration(String workerId) {
    final monitor = _monitors[workerId];
    if (monitor == null || !monitor.isOnline) return;
    monitor.sensor.applyHydration();
    monitor.lastHydration = DateTime.now();
    notifyListeners();
  }

  void changeScenario(String workerId, HeatScenario scenario) {
    final monitor = _monitors[workerId];
    if (monitor == null) return;
    monitor.sensor.scenario = scenario;
    notifyListeners();
  }

  /// Simula a perda de sinal do sensor (usado na demonstração).
  void simulateSignalLoss(String workerId) {
    final monitor = _monitors[workerId];
    if (monitor == null || !monitor.isOnline) return;
    monitor.sensor.loseSignal();
    monitor.isOnline = false;
    unawaited(
      _alerts.addAll([
        _buildAlert(
          monitor,
          AlertType.sensorOffline,
          'O sensor parou de enviar dados.',
          DateTime.now(),
        ),
      ]),
    );
    notifyListeners();
  }

  void reconnect(String workerId) {
    final monitor = _monitors[workerId];
    if (monitor == null) return;
    monitor.sensor.reconnect();
    monitor.isOnline = true;
    notifyListeners();
  }

  Future<void> _start(
    Future<List<AppUser>> Function() loadWorkers,
    SimulationProfile Function(int index) profileFor,
  ) async {
    _cancelTimer();
    _monitors.clear();
    final session = ++_session;
    _status = MonitoringStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      final workers = await loadWorkers();
      await Future<void>.delayed(_connectionDelay);
      if (session != _session) return;

      final now = DateTime.now();
      for (var i = 0; i < workers.length; i++) {
        _monitors[workers[i].id] = WorkerMonitor(
          worker: workers[i],
          sensor: SimulatedSensor(profile: profileFor(i), random: _random),
          startedAt: now,
        );
      }
      _status = MonitoringStatus.active;
      _tick();
      _timer = Timer.periodic(_interval, (_) => _tick());
    } catch (_) {
      if (session != _session) return;
      _status = MonitoringStatus.failure;
      _errorMessage =
          'Não foi possível iniciar o monitoramento. Verifique os dados salvos e tente novamente.';
      notifyListeners();
    }
  }

  void _tick() {
    final now = DateTime.now();
    final newAlerts = <RiskAlert>[];

    for (final monitor in _monitors.values) {
      final reading = monitor.sensor.read(now);

      if (reading == null) {
        if (monitor.isOnline) {
          monitor.isOnline = false;
          newAlerts.add(
            _buildAlert(
              monitor,
              AlertType.sensorOffline,
              monitor.batteryLevel == 0
                  ? 'O sensor desligou por falta de bateria.'
                  : 'O sensor parou de enviar dados.',
              now,
            ),
          );
        }
        continue;
      }

      monitor.isOnline = true;
      monitor.addReading(reading);

      final previousLevel = monitor.assessment.level;
      monitor.assessment = _analyzer.assess(monitor.readings);
      final currentLevel = monitor.assessment.level;

      if (currentLevel.isMoreSevereThan(previousLevel)) {
        newAlerts.add(
          _buildAlert(
            monitor,
            currentLevel == RiskLevel.critical
                ? AlertType.critical
                : AlertType.attention,
            '${monitor.assessment.title}: ${Formatters.temperature(reading.skinTemperature)}.',
            now,
          ),
        );
      }

      if (monitor.isLowBattery && !monitor.lowBatteryAlertSent) {
        monitor.lowBatteryAlertSent = true;
        newAlerts.add(
          _buildAlert(
            monitor,
            AlertType.lowBattery,
            'Bateria do sensor em ${monitor.batteryLevel}%. Recarregue na próxima pausa.',
            now,
          ),
        );
      } else if (!monitor.isLowBattery) {
        monitor.lowBatteryAlertSent = false;
      }
    }

    if (newAlerts.isNotEmpty) unawaited(_alerts.addAll(newAlerts));
    notifyListeners();
  }

  RiskAlert _buildAlert(
    WorkerMonitor monitor,
    AlertType type,
    String message,
    DateTime createdAt,
  ) {
    return RiskAlert(
      id: '${createdAt.microsecondsSinceEpoch}-${monitor.worker.id}-${type.name}',
      workerId: monitor.worker.id,
      workerName: monitor.worker.name,
      type: type,
      message: message,
      createdAt: createdAt,
    );
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
