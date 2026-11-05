import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalis/core/constants/risk_thresholds.dart';
import 'package:vitalis/data/models/heat_scenario.dart';
import 'package:vitalis/data/models/sensor_reading.dart';
import 'package:vitalis/data/services/simulated_sensor.dart';

void main() {
  final start = DateTime(2026, 10, 20, 8);

  test('cenário de calor extremo aquece até o risco alto', () {
    final sensor = SimulatedSensor(
      profile: const SimulationProfile(
        scenario: HeatScenario.extreme,
        initialBattery: 100,
      ),
      random: Random(42),
    );
    SensorReading? last;
    for (var i = 0; i < 120; i++) {
      last = sensor.read(start.add(Duration(seconds: i * 2)));
    }
    expect(last, isNotNull);
    expect(last!.skinTemperature, greaterThan(RiskThresholds.criticalTemperature));
  });

  test('clima ameno mantém a temperatura abaixo da atenção', () {
    final sensor = SimulatedSensor(
      profile: const SimulationProfile(
        scenario: HeatScenario.mild,
        initialBattery: 100,
      ),
      random: Random(7),
    );
    for (var i = 0; i < 120; i++) {
      final reading = sensor.read(start.add(Duration(seconds: i * 2)));
      expect(
        reading!.skinTemperature,
        lessThan(RiskThresholds.attentionTemperature),
      );
    }
  });

  test('hidratação reduz a temperatura da pele', () {
    final sensor = SimulatedSensor(
      profile: const SimulationProfile(
        scenario: HeatScenario.hot,
        initialBattery: 100,
      ),
      random: Random(1),
    );
    for (var i = 0; i < 40; i++) {
      sensor.read(start.add(Duration(seconds: i * 2)));
    }
    final before = sensor.currentTemperature;
    sensor.applyHydration();
    expect(sensor.currentTemperature, closeTo(before - 1.2, 0.001));
  });

  test('sensor desliga quando a bateria acaba e volta ao reconectar', () {
    final sensor = SimulatedSensor(
      profile: const SimulationProfile(
        scenario: HeatScenario.mild,
        initialBattery: 0.5,
      ),
      random: Random(3),
    );
    for (var i = 0; i < 10; i++) {
      sensor.read(start.add(Duration(seconds: i * 2)));
    }
    expect(sensor.isConnected, isFalse);
    expect(sensor.read(start), isNull);

    sensor.reconnect();
    expect(sensor.isConnected, isTrue);
    expect(sensor.batteryLevel, 100);
  });

  test('perda de sinal interrompe as leituras', () {
    final sensor = SimulatedSensor(profile: SimulationProfile.personal);
    sensor.loseSignal();
    expect(sensor.read(start), isNull);
    sensor.reconnect();
    expect(sensor.read(start), isNotNull);
  });
}
