/// Configurações gerais do protótipo.
abstract final class AppConfig {
  /// Intervalo entre duas leituras do sensor simulado.
  static const Duration sensorInterval = Duration(seconds: 2);

  /// Tempo simulado de pareamento com o sensor ao abrir o app.
  static const Duration connectionDelay = Duration(milliseconds: 1500);

  /// Quantidade máxima de leituras mantidas em memória por trabalhador.
  static const int maxReadingsInMemory = 300;

  /// Quantidade de leituras exibidas no gráfico.
  static const int chartWindow = 30;

  /// Quantidade máxima de alertas salvos no aparelho.
  static const int maxStoredAlerts = 200;
}
