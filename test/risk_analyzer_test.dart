import 'package:flutter_test/flutter_test.dart';
import 'package:vitalis/core/constants/risk_thresholds.dart';
import 'package:vitalis/data/models/risk.dart';
import 'package:vitalis/data/models/sensor_reading.dart';
import 'package:vitalis/logic/risk_analyzer.dart';

List<SensorReading> readingsOf(List<double> temperatures) {
  final start = DateTime(2026, 10, 20, 8);
  return [
    for (var i = 0; i < temperatures.length; i++)
      SensorReading(
        timestamp: start.add(Duration(seconds: i * 2)),
        skinTemperature: temperatures[i],
        batteryLevel: 90,
      ),
  ];
}

void main() {
  const analyzer = RiskAnalyzer();

  test('sem leituras retorna o estado de espera', () {
    final result = analyzer.assess([]);
    expect(result.level, RiskLevel.normal);
    expect(result.title, RiskAssessment.waiting.title);
  });

  test('temperatura estável é classificada como normal', () {
    final result = analyzer.assess(readingsOf(List.filled(20, 33.5)));
    expect(result.level, RiskLevel.normal);
  });

  test('temperatura acima do limite de atenção gera atenção', () {
    final result = analyzer.assess(readingsOf([33.5, 35.6]));
    expect(result.level, RiskLevel.attention);
  });

  test('temperatura no limite crítico gera risco alto', () {
    final result = analyzer.assess(readingsOf([34.0, 36.9]));
    expect(result.level, RiskLevel.critical);
  });

  test('aquecimento rápido gera atenção mesmo abaixo do limite', () {
    final temperatures = [for (var i = 0; i < 12; i++) 33.0 + i * 0.12];
    expect(temperatures.last, lessThan(RiskThresholds.attentionTemperature));
    final result = analyzer.assess(readingsOf(temperatures));
    expect(result.level, RiskLevel.attention);
    expect(result.title, 'Temperatura subindo rápido');
  });

  test('calor prolongado acima do limite de atenção gera risco alto', () {
    final result = analyzer.assess(
      readingsOf(List.filled(RiskThresholds.sustainedReadings, 35.8)),
    );
    expect(result.level, RiskLevel.critical);
    expect(result.title, 'Calor prolongado no corpo');
  });

  test('pausa para hidratação interrompe a sequência de calor', () {
    final result = analyzer.assess(
      readingsOf([
        ...List.filled(RiskThresholds.sustainedReadings, 35.8),
        34.6,
      ]),
    );
    expect(result.level, RiskLevel.normal);
  });

  test('classificação de uma temperatura isolada', () {
    expect(RiskAnalyzer.levelForTemperature(33.0), RiskLevel.normal);
    expect(RiskAnalyzer.levelForTemperature(35.5), RiskLevel.attention);
    expect(RiskAnalyzer.levelForTemperature(36.8), RiskLevel.critical);
  });
}
