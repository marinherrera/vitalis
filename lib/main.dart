import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalis/app.dart';
import 'package:vitalis/data/local/local_storage.dart';
import 'package:vitalis/data/repositories/alert_repository.dart';
import 'package:vitalis/data/repositories/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final storage = LocalStorage(preferences);
  final userRepository = UserRepository(storage);
  await userRepository.seedDemoData();

  runApp(
    VitalisApp(
      userRepository: userRepository,
      alertRepository: AlertRepository(storage),
    ),
  );
}
