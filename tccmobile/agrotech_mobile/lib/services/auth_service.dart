import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // =========================================================
  // CONFIGURAÇÃO DA API
  // =========================================================

  static const String baseUrl = 'http://10.0.2.2:8000/';

  // =========================================================
  // LOGIN REAL PELA API
  // =========================================================

  static Future<bool> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/token/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);

        final accessToken = dados['access'];
        final refreshToken = dados['refresh'];

        final prefs =
            await SharedPreferences.getInstance();

        // Salva os tokens
        await prefs.setString(
          'access_token',
          accessToken,
        );

        await prefs.setString(
          'refresh_token',
          refreshToken,
        );

        // Também marca como logado
        await prefs.setBool(
          'logged_in',
          true,
        );

        // Salva o usuário
        await prefs.setString(
          'user_name',
          username,
        );

        return true;
      }

      print(
        'Erro no login: ${response.statusCode}',
      );

      print(response.body);

      return false;
    } catch (e) {
      print(
        'Erro ao conectar com a API: $e',
      );

      return false;
    }
  }

  // =========================================================
  // LOGIN SIMULADO
  // =========================================================

  static Future<void> salvarLogin(
    String nome,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    // Diz que o usuário está logado
    await prefs.setBool(
      'logged_in',
      true,
    );

    // Salva o nome
    await prefs.setString(
      'user_name',
      nome,
    );
  }

  // =========================================================
  // VERIFICAR SE ESTÁ LOGADO
  // =========================================================

  static Future<bool> isLoggedIn() async {
    final prefs =
        await SharedPreferences.getInstance();

    // Verifica o login simulado
    final loggedIn =
        prefs.getBool('logged_in') ?? false;

    // Verifica se existe token da API
    final token =
        prefs.getString('access_token');

    final possuiToken =
        token != null && token.isNotEmpty;

    // Se qualquer um estiver válido,
    // consideramos o usuário logado.
    return loggedIn || possuiToken;
  }

  // =========================================================
  // PEGAR NOME DO USUÁRIO
  // =========================================================

  static Future<String> getUserName() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
          'user_name',
        ) ??
        'Usuário';
  }

  // =========================================================
  // PEGAR TOKEN
  // =========================================================

  static Future<String?> getAccessToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
      'access_token',
    );
  }

  // =========================================================
  // PEGAR REFRESH TOKEN
  // =========================================================

  static Future<String?> getRefreshToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
      'refresh_token',
    );
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  static Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    // Remove sessão
    await prefs.remove(
      'logged_in',
    );

    // Remove usuário
    await prefs.remove(
      'user_name',
    );

    // Remove tokens
    await prefs.remove(
      'access_token',
    );

    await prefs.remove(
      'refresh_token',
    );
  }
}