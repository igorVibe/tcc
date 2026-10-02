import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RoverStorage {
  static const String _key = 'rovers_cadastrados';

  // ============================================================
  // BUSCAR ROVERS SALVOS
  // ============================================================

  static Future<List<Map<String, String>>> getRovers() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString(_key);

    // Se não existir nenhum rover salvo
    if (dados == null || dados.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> lista = jsonDecode(dados);

      return lista.map<Map<String, String>>((item) {
        return Map<String, String>.from(item);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // SALVAR UM ROVER
  // ============================================================

  static Future<void> saveRover(
    Map<String, String> rover,
  ) async {
    // Busca os rovers que já existem
    final rovers = await getRovers();

    // Adiciona o novo rover
    rovers.add(rover);

    // Acessa o armazenamento local
    final prefs = await SharedPreferences.getInstance();

    // Converte a lista para JSON e salva
    await prefs.setString(
      _key,
      jsonEncode(rovers),
    );
  }

  // ============================================================
  // LIMPAR TODOS OS ROVERS
  // ============================================================

  static Future<void> clearRovers() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}