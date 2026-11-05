import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:vitalis/data/local/local_storage.dart';
import 'package:vitalis/data/models/app_user.dart';
import 'package:vitalis/data/models/user_role.dart';

/// Erro de autenticação com mensagem pronta para exibir ao usuário.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Contas, login e sessão, todos guardados no próprio aparelho.
///
/// As senhas nunca são salvas em texto puro: guardamos apenas o hash SHA-256.
class UserRepository {
  UserRepository(this._storage);

  static const String demoPassword = '123456';
  static const String demoWorkerEmail = 'trabalhador@vitalis.com';
  static const String demoSupervisorEmail = 'supervisor@vitalis.com';

  static const String _accountsKey = 'vitalis.accounts';
  static const String _sessionKey = 'vitalis.session';

  static const List<AppUser> _demoUsers = [
    AppUser(
      id: 's1',
      name: 'Carla Mendes',
      email: demoSupervisorEmail,
      role: UserRole.supervisor,
      activity: 'Fazenda Boa Safra',
    ),
    AppUser(
      id: 'w1',
      name: 'João Pereira',
      email: demoWorkerEmail,
      role: UserRole.worker,
      activity: 'Colheita de café',
    ),
    AppUser(
      id: 'w2',
      name: 'Ana Souza',
      email: 'ana@vitalis.com',
      role: UserRole.worker,
      activity: 'Corte de cana',
    ),
    AppUser(
      id: 'w3',
      name: 'Pedro Alves',
      email: 'pedro@vitalis.com',
      role: UserRole.worker,
      activity: 'Colheita de laranja',
    ),
    AppUser(
      id: 'w4',
      name: 'Rita Santos',
      email: 'rita@vitalis.com',
      role: UserRole.worker,
      activity: 'Plantio de hortaliças',
    ),
    AppUser(
      id: 'w5',
      name: 'Lucas Ferreira',
      email: 'lucas@vitalis.com',
      role: UserRole.worker,
      activity: 'Aplicação de adubo',
    ),
  ];

  final LocalStorage _storage;

  /// Cria as contas de demonstração na primeira vez que o app abre.
  Future<void> seedDemoData() async {
    List<Map<String, dynamic>> existing;
    try {
      existing = _storage.readList(_accountsKey);
    } on StorageException {
      existing = [];
    }
    if (existing.isNotEmpty) return;
    await _storage.writeList(
      _accountsKey,
      [for (final user in _demoUsers) _toAccount(user, demoPassword)],
    );
  }

  Future<AppUser> login(String email, String password) async {
    final normalizedEmail = _normalize(email);
    final account = _findAccount((item) => item['email'] == normalizedEmail);
    if (account == null ||
        account['passwordHash'] != _hash(normalizedEmail, password)) {
      throw const AuthException('E-mail ou senha incorretos.');
    }
    final user = AppUser.fromJson(account);
    await _storage.writeString(_sessionKey, user.id);
    return user;
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String activity,
  }) async {
    final normalizedEmail = _normalize(email);
    if (_findAccount((item) => item['email'] == normalizedEmail) != null) {
      throw const AuthException('Já existe uma conta com este e-mail.');
    }
    final trimmedActivity = activity.trim();
    final user = AppUser(
      id: 'u${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      email: normalizedEmail,
      role: role,
      activity: trimmedActivity.isNotEmpty
          ? trimmedActivity
          : (role == UserRole.supervisor ? 'Supervisão de campo' : 'Trabalho rural'),
    );
    final accounts = _storage.readList(_accountsKey);
    await _storage.writeList(
      _accountsKey,
      [...accounts, _toAccount(user, password)],
    );
    await _storage.writeString(_sessionKey, user.id);
    return user;
  }

  /// Usuário da sessão salva, ou `null` se ninguém estiver logado.
  Future<AppUser?> currentUser() async {
    final userId = _storage.readString(_sessionKey);
    if (userId == null) return null;
    final account = _findAccount((item) => item['id'] == userId);
    return account == null ? null : AppUser.fromJson(account);
  }

  Future<void> logout() => _storage.remove(_sessionKey);

  /// Trabalhadores cadastrados, que formam a equipe do supervisor.
  Future<List<AppUser>> fetchWorkers() async {
    return _storage
        .readList(_accountsKey)
        .map(AppUser.fromJson)
        .where((user) => user.role == UserRole.worker)
        .toList();
  }

  Map<String, dynamic>? _findAccount(
    bool Function(Map<String, dynamic> account) test,
  ) {
    for (final account in _storage.readList(_accountsKey)) {
      if (test(account)) return account;
    }
    return null;
  }

  Map<String, dynamic> _toAccount(AppUser user, String password) => {
        ...user.toJson(),
        'passwordHash': _hash(user.email, password),
      };

  String _normalize(String email) => email.trim().toLowerCase();

  String _hash(String email, String password) {
    final bytes = utf8.encode('vitalis:${_normalize(email)}:$password');
    return sha256.convert(bytes).toString();
  }
}
