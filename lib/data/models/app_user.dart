import 'package:vitalis/data/models/user_role.dart';

/// Usuário do aplicativo (trabalhador ou supervisor).
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.activity,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.byName(json['role'] as String),
      activity: json['activity'] as String? ?? 'Trabalho rural',
    );
  }

  final String id;
  final String name;
  final String email;
  final UserRole role;

  /// Atividade no campo (trabalhador) ou fazenda/setor (supervisor).
  final String activity;

  bool get isSupervisor => role == UserRole.supervisor;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'activity': activity,
      };
}
