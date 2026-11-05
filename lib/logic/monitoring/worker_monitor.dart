import 'dart:collection';

import 'package:vitalis/core/constants/app_config.dart';
import 'package:vitalis/core/constants/risk_thresholds.dart';
import 'package:vitalis/data/models/app_user.dart';
import 'package:vitalis/data/models/heat_scenario.dart';
import 'package:vitalis/data/models/risk.dart';
import 'package:vitalis/data/models/sensor_reading.dart';
import 'package:vitalis/data/services/simulated_sensor.dart';

/// Estado do monitoramento de um trabalhador durante a jornada.
class WorkerMonitor {
  WorkerMonitor({
    required this.worker,
    required this.sensor,
    required this.startedAt,
  });

  final AppUser worker;
  final SimulatedSensor sensor;
  final DateTime startedAt;
  final List<SensorReading> _readings = [];

  RiskAssessment assessment = RiskAssessment.waiting;
  bool isOnline = true;
  DateTime? lastHydration;
  bool lowBatteryAlertSent = false;

  UnmodifiableListView<SensorReading> get readings =>
      UnmodifiableListView(_readings);

  SensorReading? get latest => _readings.isEmpty ? null : _readings.last;

  int get batteryLevel => sensor.batteryLevel;

  bool get isLowBattery => batteryLevel <= RiskThresholds.lowBattery;

  HeatScenario get scenario => sensor.scenario;

  void addReading(SensorReading reading) {
    _readings.add(reading);
    if (_readings.length > AppConfig.maxReadingsInMemory) {
      _readings.removeAt(0);
    }
  }

  /// Ordem de exibição na lista da equipe: quem precisa de atenção primeiro.
  int get priority {
    if (isOnline && assessment.level == RiskLevel.critical) return 4;
    if (isOnline && assessment.level == RiskLevel.attention) return 3;
    if (!isOnline) return 2;
    return 1;
  }
}
