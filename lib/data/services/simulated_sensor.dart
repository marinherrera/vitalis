import 'dart:math';

import 'package:vitalis/data/models/heat_scenario.dart';
import 'package:vitalis/data/models/sensor_reading.dart';

/// Configuração inicial de um sensor simulado.
class SimulationProfile {
  const SimulationProfile({
    required this.scenario,
    required this.initialBattery,
  });

  /// Perfil usado quando o trabalhador monitora a si mesmo.
  static const SimulationProfile personal = SimulationProfile(
    scenario: HeatScenario.hot,
    initialBattery: 92,
  );

  /// Perfis variados para que a equipe do supervisor mostre situações
  /// diferentes na demonstração (inclusive um sensor com bateria baixa).
  static const List<SimulationProfile> team = [
    SimulationProfile(scenario: HeatScenario.hot, initialBattery: 88),
    SimulationProfile(scenario: HeatScenario.mild, initialBattery: 95),
    SimulationProfile(scenario: HeatScenario.extreme, initialBattery: 76),
    SimulationProfile(scenario: HeatScenario.mild, initialBattery: 17),
    SimulationProfile(scenario: HeatScenario.hot, initialBattery: 64),
  ];

  static SimulationProfile forTeamMember(int index) =>
      team[index % team.length];

  final HeatScenario scenario;
  final double initialBattery;
}

/// Simula o biossensor do pulso (ESP32 + DS18B20).
///
/// A cada leitura a temperatura da pele se aproxima da temperatura-alvo do
/// cenário de calor, com uma pequena variação aleatória, e a bateria descarrega
/// um pouco. Quando o hardware estiver pronto, esta classe pode ser trocada por
/// uma implementação que lê o ESP32 via Bluetooth, sem mudar o resto do app.
class SimulatedSensor {
  SimulatedSensor({required SimulationProfile profile, Random? random})
      : _random = random ?? Random(),
        scenario = profile.scenario,
        _battery = profile.initialBattery {
    _temperature += _random.nextDouble() * 0.6;
  }

  static const double drainPerReading = 0.15;
  static const double smoothing = 0.06;
  static const double noise = 0.08;
  static const double hydrationCooling = 1.2;
  static const double minTemperature = 31.0;
  static const double maxTemperature = 39.5;

  final Random _random;

  /// Cenário atual. Pode ser trocado durante a demonstração.
  HeatScenario scenario;

  double _temperature = 33.0;
  double _battery;
  bool _signalLost = false;

  int get batteryLevel => _battery.clamp(0, 100).round();

  bool get isConnected => !_signalLost && _battery > 0;

  double get currentTemperature => _temperature;

  /// Gera a próxima leitura, ou `null` se o sensor estiver sem sinal.
  SensorReading? read(DateTime now) {
    if (!isConnected) return null;
    final jitter = (_random.nextDouble() * 2 - 1) * noise;
    final next = _temperature +
        (scenario.targetTemperature - _temperature) * smoothing +
        jitter;
    _temperature = next.clamp(minTemperature, maxTemperature).toDouble();
    _battery = max(0.0, _battery - drainPerReading);
    return SensorReading(
      timestamp: now,
      skinTemperature: _temperature,
      batteryLevel: batteryLevel,
    );
  }

  /// Efeito de uma pausa para beber água na sombra.
  void applyHydration() {
    _temperature = max(minTemperature, _temperature - hydrationCooling);
  }

  void loseSignal() {
    _signalLost = true;
  }

  /// Reconecta o sensor. Se a bateria tiver acabado, considera que foi
  /// recarregado antes da reconexão.
  void reconnect() {
    _signalLost = false;
    if (_battery <= 0) _battery = 100;
  }
}
