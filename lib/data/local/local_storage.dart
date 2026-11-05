import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Erro ao ler ou gravar dados no aparelho.
class StorageException implements Exception {
  const StorageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Acesso ao armazenamento local do aparelho (shared_preferences).
///
/// Os dados são guardados como JSON. Os repositórios usam esta classe e não
/// conhecem os detalhes do shared_preferences.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  /// Lê uma lista de objetos JSON. Lança [StorageException] se o conteúdo
  /// salvo estiver corrompido.
  List<Map<String, dynamic>> readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const StorageException('Os dados salvos estão em formato inválido.');
      }
      return decoded.whereType<Map<String, dynamic>>().toList();
    } on FormatException {
      throw const StorageException('Os dados salvos estão em formato inválido.');
    }
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> items) async {
    final saved = await _prefs.setString(key, jsonEncode(items));
    if (!saved) {
      throw const StorageException('Não foi possível salvar os dados no aparelho.');
    }
  }

  String? readString(String key) => _prefs.getString(key);

  Future<void> writeString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
