/// Parâmetros da análise de risco do protótipo.
///
/// Os valores são ilustrativos, pensados para a temperatura da pele medida na
/// parte interna do pulso pelo sensor DS18B20. Servem para fins acadêmicos e
/// não substituem avaliação médica ou de um técnico de segurança do trabalho.
abstract final class RiskThresholds {
  /// A partir desta temperatura o trabalhador entra em atenção.
  static const double attentionTemperature = 35.5;

  /// A partir desta temperatura o risco é considerado alto.
  static const double criticalTemperature = 36.8;

  /// Leituras seguidas acima do limite de atenção que caracterizam calor
  /// prolongado (sinal de exaustão e possível desidratação).
  static const int sustainedReadings = 15;

  /// Quantidade de leituras usada para medir a velocidade de aquecimento.
  static const int trendWindow = 10;

  /// Aumento de temperatura dentro da janela que indica aquecimento rápido.
  static const double trendRise = 0.8;

  /// Percentual de bateria considerado baixo.
  static const int lowBattery = 15;
}
