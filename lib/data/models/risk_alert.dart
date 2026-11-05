/// Tipos de alerta gerados pelo monitoramento.
enum AlertType {
  attention('Atenção'),
  critical('Risco alto'),
  lowBattery('Bateria baixa'),
  sensorOffline('Sensor sem sinal');

  const AlertType(this.label);

  final String label;
}

/// Alerta emitido para o trabalhador e para o supervisor.
class RiskAlert {
  const RiskAlert({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.type,
    required this.message,
    required this.createdAt,
    this.resolved = false,
  });

  factory RiskAlert.fromJson(Map<String, dynamic> json) {
    return RiskAlert(
      id: json['id'] as String,
      workerId: json['workerId'] as String,
      workerName: json['workerName'] as String,
      type: AlertType.values.byName(json['type'] as String),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolved: json['resolved'] as bool? ?? false,
    );
  }

  final String id;
  final String workerId;
  final String workerName;
  final AlertType type;
  final String message;
  final DateTime createdAt;
  final bool resolved;

  RiskAlert copyWith({bool? resolved}) {
    return RiskAlert(
      id: id,
      workerId: workerId,
      workerName: workerName,
      type: type,
      message: message,
      createdAt: createdAt,
      resolved: resolved ?? this.resolved,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workerId': workerId,
        'workerName': workerName,
        'type': type.name,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'resolved': resolved,
      };
}
