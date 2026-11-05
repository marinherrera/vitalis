import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalis/data/local/local_storage.dart';
import 'package:vitalis/data/models/user_role.dart';
import 'package:vitalis/data/repositories/user_repository.dart';

void main() {
  late UserRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    repository = UserRepository(LocalStorage(preferences));
    await repository.seedDemoData();
  });

  test('cria as contas de demonstração com 5 trabalhadores', () async {
    final workers = await repository.fetchWorkers();
    expect(workers, hasLength(5));
  });

  test('login com a conta de demonstração salva a sessão', () async {
    final user = await repository.login(
      UserRepository.demoWorkerEmail,
      UserRepository.demoPassword,
    );
    expect(user.role, UserRole.worker);
    final current = await repository.currentUser();
    expect(current?.id, user.id);
  });

  test('senha errada gera AuthException', () async {
    await expectLater(
      () => repository.login(UserRepository.demoWorkerEmail, 'errada'),
      throwsA(isA<AuthException>()),
    );
  });

  test('não permite cadastrar e-mail repetido', () async {
    await expectLater(
      () => repository.register(
        name: 'Outra Pessoa',
        email: UserRepository.demoSupervisorEmail,
        password: '123456',
        role: UserRole.supervisor,
        activity: '',
      ),
      throwsA(isA<AuthException>()),
    );
  });

  test('novo trabalhador entra na equipe', () async {
    await repository.register(
      name: 'Maria Lima',
      email: 'maria@vitalis.com',
      password: 'segredo1',
      role: UserRole.worker,
      activity: 'Colheita de morango',
    );
    final workers = await repository.fetchWorkers();
    expect(workers.map((worker) => worker.name), contains('Maria Lima'));
  });

  test('logout remove a sessão', () async {
    await repository.login(
      UserRepository.demoSupervisorEmail,
      UserRepository.demoPassword,
    );
    await repository.logout();
    expect(await repository.currentUser(), isNull);
  });
}
