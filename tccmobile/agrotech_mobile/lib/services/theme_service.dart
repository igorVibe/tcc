import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _modeKey =
      'agrotech_theme_mode';

  // ============================================================
  // TEMA ATUAL
  // ============================================================

  static final ValueNotifier<ThemeMode>
      themeMode =
          ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  // ============================================================
  // CORES AGROTECH
  // ============================================================

  static const Color primaryColor =
      Color(0xFF19A974);

  static const Color darkPrimaryColor =
      Color(0xFF087443);

  static const Color lightPrimaryColor =
      Color(0xFFE7F8EF);

  // ============================================================
  // CARREGAR TEMA SALVO
  // ============================================================

  static Future<void> carregarTema() async {
    final prefs =
        await SharedPreferences.getInstance();

    final salvo =
        prefs.getString(_modeKey);

    switch (salvo) {
      case 'dark':
        themeMode.value =
            ThemeMode.dark;
        break;

      case 'system':
        themeMode.value =
            ThemeMode.system;
        break;

      case 'light':
      default:
        themeMode.value =
            ThemeMode.light;
        break;
    }
  }

  // ============================================================
  // ALTERAR TEMA
  // ============================================================

  static Future<void> mudarTema(
    ThemeMode modo,
  ) async {
    // Atualiza imediatamente o aplicativo
    themeMode.value = modo;

    final prefs =
        await SharedPreferences.getInstance();

    String valor;

    switch (modo) {
      case ThemeMode.dark:
        valor = 'dark';
        break;

      case ThemeMode.system:
        valor = 'system';
        break;

      case ThemeMode.light:
        valor = 'light';
        break;
    }

    await prefs.setString(
      _modeKey,
      valor,
    );
  }

  // ============================================================
  // MODO CLARO
  // ============================================================

  static Future<void> modoClaro() async {
    await mudarTema(
      ThemeMode.light,
    );
  }

  // ============================================================
  // MODO ESCURO
  // ============================================================

  static Future<void> modoEscuro() async {
    await mudarTema(
      ThemeMode.dark,
    );
  }

  // ============================================================
  // MODO AUTOMÁTICO
  // ============================================================

  static Future<void> modoAutomatico() async {
    await mudarTema(
      ThemeMode.system,
    );
  }

  // ============================================================
  // VERIFICAR SE ESTÁ ESCURO
  // ============================================================

  static bool get isDark {
    return themeMode.value ==
        ThemeMode.dark;
  }
}