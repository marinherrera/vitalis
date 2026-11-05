import 'package:flutter/foundation.dart';
import 'package:vitalis/data/local/local_storage.dart';
import 'package:vitalis/data/models/app_user.dart';
import 'package:vitalis/data/models/user_role.dart';
import 'package:vitalis/data/repositories/user_repository.dart';

enum AuthStatus { checking, unauthenticated, authenticated }

/// Estado de autenticação do app.
///
/// [login] e [register] devolvem `null` em caso de sucesso ou a mensagem de
/// erro para a tela exibir.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final UserRepository _repository;

  AuthStatus _status = AuthStatus.checking;
  AppUser? _currentUser;

  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;

  Future<void> restoreSession() async {
    try {
      _setSession(await _repository.currentUser());
    } on StorageException {
      _setSession(null);
    }
  }

  Future<String?> login(String email, String password) {
    return _authenticate(() => _repository.login(email, password));
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String activity,
  }) {
    return _authenticate(
      () => _repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
        activity: activity,
      ),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    _setSession(null);
  }

  Future<String?> _authenticate(Future<AppUser> Function() action) async {
    try {
      _setSession(await action());
      return null;
    } on AuthException catch (error) {
      return error.message;
    } on StorageException catch (error) {
      return error.message;
    } catch (_) {
      return 'Não foi possível concluir agora. Tente novamente.';
    }
  }

  void _setSession(AppUser? user) {
    _currentUser = user;
    _status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }
}
