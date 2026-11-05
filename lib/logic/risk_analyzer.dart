import 'package:vitalis/core/constants/risk_thresholds.dart';
import 'package:vitalis/data/models/risk.dart';
import 'package:vitalis/data/models/sensor_reading.dart';

/// Analisa as leituras do sensor e classifica o risco de desidratação e
/// exaustão térmica.
///
/// Regras (em ordem de prioridade):
/// 1. Temperatura atual no limite crítico: risco alto.
/// 2. Várias leituras seguidas acima do limite de atenção: risco alto
///    (calor prolongado, sinal de exaustão e possível desidratação).
/// 3. Temperatura atual acima do limite de atenção: atenção.
/// 4. Aquecimento rápido nas últimas leituras: atenção.
/// 5. Caso contrário: normal.
class RiskAnalyzer {
  const RiskAnalyzer();

  /// Classificação de uma única temperatura, usada no histórico.
  static RiskLevel levelForTemperature(double temperature) {
    if (temperature >= RiskThresholds.criticalTemperature) {
      return RiskLevel.critical;
    }
    if (temperature >= RiskThresholds.attentionTemperature) {
      return RiskLevel.attention;
    }
    return RiskLevel.normal;
  }

  RiskAssessment assess(List<SensorReading> readings) {
    if (readings.isEmpty) return RiskAssessment.waiting;

    final latest = readings.last.skinTemperature;

    if (latest >= RiskThresholds.criticalTemperature) {
      return const RiskAssessment(
        level: RiskLevel.critical,
        title: 'Risco alto de exaustão térmica',
        message: 'A temperatura da pele passou do limite seguro.',
        recommendation:
            'Pare a atividade, vá para a sombra, beba água e avise o responsável.',
      );
    }

    if (_isSustainedHigh(readings)) {
      return const RiskAssessment(
        level: RiskLevel.critical,
        title: 'Calor prolongado no corpo',
        message:
            'A temperatura está alta há muito tempo seguido, sinal de exaustão e possível desidratação.',
        recommendation:
            'Faça uma pausa na sombra agora e beba água em pequenos goles.',
      );
    }

    if (latest >= RiskThresholds.attentionTemperature) {
      return const RiskAssessment(
        level: RiskLevel.attention,
        title: 'Temperatura elevada',
        message: 'O corpo está aquecendo acima do normal.',
        recommendation: 'Diminua o ritmo e beba água nos próximos minutos.',
      );
    }

    if (_isRisingFast(readings)) {
      return const RiskAssessment(
        level: RiskLevel.attention,
        title: 'Temperatura subindo rápido',
        message: 'O aquecimento está acelerado, o que costuma vir antes do estresse térmico.',
        recommendation: 'Procure sombra quando puder e mantenha a hidratação.',
      );
    }

    return const RiskAssessment(
      level: RiskLevel.normal,
      title: 'Condição estável',
      message: 'A temperatura da pele está dentro do esperado.',
      recommendation: 'Continue bebendo água regularmente durante a jornada.',
    );
  }

  bool _isSustainedHigh(List<SensorReading> readings) {
    if (readings.length < RiskThresholds.sustainedReadings) return false;
    return readings
        .skip(readings.length - RiskThresholds.sustainedReadings)
        .every(
          (reading) =>
              reading.skinTemperature >= RiskThresholds.attentionTemperature,
        );
  }

  bool _isRisingFast(List<SensorReading> readings) {
    if (readings.length <= RiskThresholds.trendWindow) return false;
    final reference =
        readings[readings.length - 1 - RiskThresholds.trendWindow];
    final rise = readings.last.skinTemperature - reference.skinTemperature;
    return rise >= RiskThresholds.trendRise;
  }
}
