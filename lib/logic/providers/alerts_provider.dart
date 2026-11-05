import 'package:flutter/foundation.dart';
import 'package:vitalis/data/models/risk_alert.dart';
import 'package:vitalis/data/repositories/alert_repository.dart';

/// Lista de alertas visível para o usuário logado.
class AlertsProvider extends ChangeNotifier {
  AlertsProvider(this._repository);

  final AlertRepository _repository;

  /// Todos os alertas, do mais recente para o mais antigo.
  List<RiskAlert> _all = [];

  /// Trabalhadores cujos alertas o usuário pode ver (`null` = todos).
  Set<String>? _scope;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<RiskAlert> get alerts {
    final scope = _scope;
    if (scope == null) return List.unmodifiable(_all);
    return _all.where((alert) => scope.contains(alert.workerId)).toList();
  }

  int get openCount => alerts.where((alert) => !alert.resolved).length;

  List<RiskAlert> alertsFor(String workerId) =>
      _all.where((alert) => alert.workerId == workerId).toList();

  /// Carrega os alertas salvos. Use [workerIds] para o trabalhador ver só os
  /// próprios alertas; o supervisor passa `null` e vê os da equipe toda.
  Future<void> load({Set<String>? workerIds}) async {
    _scope = workerIds;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final stored = await _repository.fetchAll();
      final storedIds = {for (final alert in stored) alert.id};
      // Mantém alertas que chegaram enquanto o histórico era carregado.
      _all = [
        ..._all.where((alert) => !storedIds.contains(alert.id)),
        ...stored,
      ];
    } catch (_) {
      _errorMessage =
          'Não foi possível ler o histórico de alertas salvo no aparelho.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> retry() => load(workerIds: _scope);

  /// Adiciona alertas em ordem cronológica (o último é o mais recente).
  Future<void> addAll(List<RiskAlert> newAlerts) async {
    if (newAlerts.isEmpty) return;
    _all = [...newAlerts.reversed, ..._all];
    notifyListeners();
    await _persist();
  }

  Future<void> resolve(String alertId) async {
    _all = [
      for (final alert in _all)
        alert.id == alertId ? alert.copyWith(resolved: true) : alert,
    ];
    notifyListeners();
    await _persist();
  }

  Future<void> clearResolved() async {
    final visibleIds = {for (final alert in alerts) alert.id};
    _all = _all
        .where((alert) => !(alert.resolved && visibleIds.contains(alert.id)))
        .toList();
    notifyListeners();
    await _persist();
  }

  /// Limpa o estado em memória ao sair da conta.
  void reset() {
    _all = [];
    _scope = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      await _repository.saveAll(_all);
    } catch (error) {
      debugPrint('Falha ao salvar alertas: $error');
    }
  }
}
