import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_role.dart';

class UserStorage {
  static const String _nomeKey = 'agrotech_user_name';
  static const String _roleKey = 'agrotech_user_role';
  static const String _usuariosKey = 'agrotech_usuarios';

  static String _nome = 'Usuário';
  static UserRole _role = UserRole.cliente;

  // ============================================================
  // CARREGAR USUÁRIO ATUAL
  // ============================================================

  static Future<void> carregarNome() async {
    final prefs = await SharedPreferences.getInstance();

    _nome = prefs.getString(_nomeKey) ?? 'Usuário';

    final roleSalvo = prefs.getString(_roleKey);

    _role = UserRoleExtension.fromString(roleSalvo);
  }

  // ============================================================
  // SALVAR NOME
  // ============================================================

  static Future<void> salvarNome(String nome) async {
    final nomeFinal =
        nome.trim().isEmpty ? 'Usuário' : nome.trim();

    _nome = nomeFinal;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _nomeKey,
      nomeFinal,
    );
  }

  // ============================================================
  // PEGAR NOME
  // ============================================================

  static Future<String> getNome() async {
    final prefs = await SharedPreferences.getInstance();

    _nome = prefs.getString(_nomeKey) ?? _nome;

    return _nome;
  }

  // ============================================================
  // SALVAR FUNÇÃO/ROLE
  // ============================================================

  static Future<void> salvarRole(
    UserRole role,
  ) async {
    _role = role;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _roleKey,
      role.value,
    );
  }

  // ============================================================
  // PEGAR FUNÇÃO/ROLE
  // ============================================================

  static Future<UserRole> getRole() async {
    final prefs = await SharedPreferences.getInstance();

    final roleSalvo = prefs.getString(_roleKey);

    _role = UserRoleExtension.fromString(
      roleSalvo,
    );

    return _role;
  }

  // ============================================================
  // SALVAR USUÁRIO ATUAL
  // ============================================================

  static Future<void> salvarUsuario({
    required String nome,
    required UserRole role,
    String email = '',
  }) async {
    final nomeFinal =
        nome.trim().isEmpty ? 'Usuário' : nome.trim();

    _nome = nomeFinal;
    _role = role;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _nomeKey,
      nomeFinal,
    );

    await prefs.setString(
      _roleKey,
      role.value,
    );

    // ----------------------------------------------------------
    // SALVA NA LISTA DE USUÁRIOS
    // ----------------------------------------------------------

    if (email.trim().isNotEmpty) {
      await _adicionarUsuarioNaLista(
        nome: nomeFinal,
        email: email.trim(),
        role: role,
      );
    }
  }

  // ============================================================
  // ADICIONAR USUÁRIO À LISTA
  // ============================================================

  static Future<void> _adicionarUsuarioNaLista({
    required String nome,
    required String email,
    required UserRole role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final dadosSalvos =
        prefs.getString(_usuariosKey);

    List<Map<String, dynamic>> usuarios = [];

    if (dadosSalvos != null &&
        dadosSalvos.isNotEmpty) {
      try {
        final lista =
            jsonDecode(dadosSalvos) as List;

        usuarios = lista
            .map(
              (item) => Map<String, dynamic>.from(
                item,
              ),
            )
            .toList();
      } catch (_) {
        usuarios = [];
      }
    }

    // Verifica se o e-mail já existe
    final indice = usuarios.indexWhere(
      (usuario) =>
          usuario['email']
              .toString()
              .toLowerCase() ==
          email.toLowerCase(),
    );

    final novoUsuario = <String, dynamic>{
      'nome': nome,
      'email': email,
      'role': role.value,
    };

    if (indice >= 0) {
      // Atualiza o usuário existente
      usuarios[indice] = novoUsuario;
    } else {
      // Adiciona novo usuário
      usuarios.add(novoUsuario);
    }

    await prefs.setString(
      _usuariosKey,
      jsonEncode(usuarios),
    );
  }

  // ============================================================
  // PEGAR TODOS OS USUÁRIOS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getUsuarios() async {
    final prefs = await SharedPreferences.getInstance();

    final dadosSalvos =
        prefs.getString(_usuariosKey);

    if (dadosSalvos == null ||
        dadosSalvos.isEmpty) {
      return [];
    }

    try {
      final lista =
          jsonDecode(dadosSalvos) as List;

      return lista
          .map(
            (item) => Map<String, dynamic>.from(
              item,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // LIMPAR USUÁRIO ATUAL
  // ============================================================

  static Future<void> limparUsuario() async {
    _nome = 'Usuário';
    _role = UserRole.cliente;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_nomeKey);
    await prefs.remove(_roleKey);
  }

  // ============================================================
  // LIMPAR TODOS OS USUÁRIOS
  // ============================================================

  static Future<void> limparTodosUsuarios() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_usuariosKey);
  }
}