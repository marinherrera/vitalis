/// Níveis de risco calculados a partir das leituras do sensor.
enum RiskLevel {
  normal('Normal'),
  attention('Atenção'),
  critical('Risco alto');

  const RiskLevel(this.label);

  final String label;

  bool isMoreSevereThan(RiskLevel other) => index > other.index;
}

/// Resultado da análise de risco, com texto pronto para o usuário.
class RiskAssessment {
  const RiskAssessment({
    required this.level,
    required this.title,
    required this.message,
    required this.recommendation,
  });

  /// Estado inicial, antes da primeira leitura chegar.
  static const RiskAssessment waiting = RiskAssessment(
    level: RiskLevel.normal,
    title: 'Aguardando leituras',
    message: 'O sensor está enviando os primeiros dados.',
    recommendation: 'Mantenha o sensor firme na parte interna do pulso.',
  );

  final RiskLevel level;
  final String title;
  final String message;
  final String recommendation;
}
