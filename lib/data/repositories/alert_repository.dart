import 'package:vitalis/core/constants/app_config.dart';
import 'package:vitalis/data/local/local_storage.dart';
import 'package:vitalis/data/models/risk_alert.dart';

/// Histórico de alertas salvo no aparelho.
class AlertRepository {
  AlertRepository(this._storage);

  static const String _key = 'vitalis.alerts';

  final LocalStorage _storage;

  /// Alertas salvos, do mais recente para o mais antigo.
  Future<List<RiskAlert>> fetchAll() async {
    return _storage.readList(_key).map(RiskAlert.fromJson).toList();
  }

  /// Salva a lista (ordenada do mais recente para o mais antigo), mantendo
  /// apenas os [AppConfig.maxStoredAlerts] mais recentes.
  Future<void> saveAll(List<RiskAlert> alerts) async {
    await _storage.writeList(
      _key,
      alerts
          .take(AppConfig.maxStoredAlerts)
          .map((alert) => alert.toJson())
          .toList(),
    );
  }
}
