import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/rover.dart';
import '../models/telemetria.dart';
import 'auth_service.dart';

class ApiService {
  // ========================================
  // URL DA API
  // ========================================

  static const String baseUrl = 'http://127.0.0.1:8000';

  // ========================================
  // HEADERS COM JWT
  // ========================================

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getAccessToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ========================================
  // BUSCAR ROVERS
  // ========================================

  static Future<List<Rover>> buscarRovers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rovers/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(response.body);

      return dados
          .map((json) => Rover.fromJson(json))
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Token inválido ou expirado.');
    }

    throw Exception(
      'Erro ao buscar burro rovers: ${response.statusCode}',
    );
  }

  // ========================================
  // BUSCAR TELEMETRIAS
  // ========================================

  static Future<List<Telemetria>> buscarTelemetrias({
    String? roverId,
  }) async {
    String url = '$baseUrl/telemetrias/';

    if (roverId != null && roverId.isNotEmpty) {
      url += '?rover=$roverId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> dados = jsonDecode(response.body);

      return dados
          .map((json) => Telemetria.fromJson(json))
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Token inválido ou expirado.');
    }

    throw Exception(
      'Erro ao buscar  telemetrias: ${response.statusCode}',
    );
  }

  static Future<Object?> testarConexao() async {
    return null;
  }
}