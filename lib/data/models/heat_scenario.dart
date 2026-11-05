/// Cenários de calor usados pelo simulador do sensor.
///
/// Como o protótipo físico ainda está no backlog, o app gera as leituras a
/// partir destes cenários para demonstrar o fluxo completo.
enum HeatScenario {
  mild(
    'Clima ameno',
    'Temperatura da pele estável ao longo da jornada.',
    33.6,
  ),
  hot(
    'Sol forte',
    'Aquecimento gradual até entrar em atenção e risco.',
    36.0,
  ),
  extreme(
    'Calor extremo',
    'Aquecimento rápido até o risco alto.',
    37.4,
  );

  const HeatScenario(this.label, this.description, this.targetTemperature);

  final String label;
  final String description;

  /// Temperatura da pele que o corpo tende a atingir neste cenário.
  final double targetTemperature;
}
