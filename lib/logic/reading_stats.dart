import 'package:vitalis/core/constants/risk_thresholds.dart';
import 'package:vitalis/data/models/sensor_reading.dart';

/// Resumo estatístico das leituras de uma jornada.
class ReadingStats {
  const ReadingStats._({
    required this.minimum,
    required this.maximum,
    required this.average,
    required this.count,
    required this.aboveAttention,
  });

  /// Retorna `null` quando ainda não há leituras.
  static ReadingStats? from(List<SensorReading> readings) {
    if (readings.isEmpty) return null;
    var minimum = readings.first.skinTemperature;
    var maximum = minimum;
    var sum = 0.0;
    var aboveAttention = 0;
    for (final reading in readings) {
      final temperature = reading.skinTemperature;
      if (temperature < minimum) minimum = temperature;
      if (temperature > maximum) maximum = temperature;
      if (temperature >= RiskThresholds.attentionTemperature) aboveAttention++;
      sum += temperature;
    }
    return ReadingStats._(
      minimum: minimum,
      maximum: maximum,
      average: sum / readings.length,
      count: readings.length,
      aboveAttention: aboveAttention,
    );
  }

  final double minimum;
  final double maximum;
  final double average;
  final int count;

  /// Leituras acima do limite de atenção.
  final int aboveAttention;
}
