import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TalhaoStorage {
  static const String _key = 'talhoes_cadastrados';

  // =========================================================
  // BUSCAR TALHÕES SALVOS
  // =========================================================

  static Future<List<Map<String, String>>> getTalhoes() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString(_key);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    final List<dynamic> lista = jsonDecode(dados);

    return lista.map<Map<String, String>>((item) {
      return Map<String, String>.from(item);
    }).toList();
  }

  // =========================================================
  // SALVAR NOVO TALHÃO
  // =========================================================

  static Future<void> saveTalhao(
    Map<String, String> talhao,
  ) async {
    final talhoes = await getTalhoes();

    talhoes.add(talhao);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      jsonEncode(talhoes),
    );
  }

  // =========================================================
  // LIMPAR TODOS OS TALHÕES
  // =========================================================

  static Future<void> clearTalhoes() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}