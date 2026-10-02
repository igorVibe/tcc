import 'package:flutter/material.dart';

import 'package:agrotech_mobile/pages/clientes/configuracoes/contas_page.dart';
import 'package:agrotech_mobile/pages/clientes/configuracoes/notificacoes_page.dart';
import 'package:agrotech_mobile/pages/clientes/configuracoes/aparencia_page.dart';
import 'package:agrotech_mobile/pages/clientes/configuracoes/privacidade_page.dart';
import 'package:agrotech_mobile/pages/clientes/configuracoes/seguranca_page.dart';
import 'package:agrotech_mobile/pages/clientes/configuracoes/ajuda_page.dart';
import 'package:agrotech_mobile/pages/clientes/configuracoes/sobre_page.dart';

import 'package:agrotech_mobile/pages/login/login_page.dart';

class ConfiguracoesPage extends StatefulWidget {
  final String userName;

  const ConfiguracoesPage({
    super.key,
    this.userName = 'Usuário',
  });

  @override
  State<ConfiguracoesPage> createState() =>
      _ConfiguracoesPageState();
}

class _ConfiguracoesPageState
    extends State<ConfiguracoesPage> {
  final Color green = const Color(0xFF19A974);
  final Color darkGreen = const Color(0xFF087443);
  final Color lightGreen = const Color(0xFFE7F8EF);
  final Color background = const Color(0xFFF7F9F7);

  bool notificacoesAtivas = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
          ),
        ),

        title: const Text(
          'Configurações',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 21,
          ),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),

        children: [
          _buildProfileHeader(),

          const SizedBox(height: 28),

          _buildSectionTitle(
            'Conta',
          ),

          const SizedBox(height: 10),

          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.person_outline_rounded,
              title: 'Conta e perfil',
              subtitle: 'Gerencie seus dados pessoais',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ContaPage(
                      userName: widget.userName,
                    ),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 25),

          _buildSectionTitle(
            'Preferências',
          ),

          const SizedBox(height: 10),

          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notificações',
              subtitle: notificacoesAtivas
                  ? 'Notificações ativadas'
                  : 'Notificações desativadas',
              trailing: Switch(
                value: notificacoesAtivas,
                activeColor: green,
                onChanged: (value) {
                  setState(() {
                    notificacoesAtivas = value;
                  });

                  _showMessage(
                    value
                        ? 'Notificações ativadas'
                        : 'Notificações desativadas',
                  );
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificacoesPage(
                      notificacoesAtivas:
                          notificacoesAtivas,
                    ),
                  ),
                );
              },
            ),

            _buildDivider(),

            _buildSettingItem(
              icon: Icons.palette_outlined,
              title: 'Aparência',
              subtitle: 'Personalize a aparência do aplicativo',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AparenciaPage(),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 25),

          _buildSectionTitle(
            'Segurança e privacidade',
          ),

          const SizedBox(height: 10),

          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacidade',
              subtitle: 'Controle seus dados e permissões',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PrivacidadePage(),
                  ),
                );
              },
            ),

            _buildDivider(),

            _buildSettingItem(
              icon: Icons.security_outlined,
              title: 'Segurança',
              subtitle: 'Senha e proteção da conta',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SegurancaPage(),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 25),

          _buildSectionTitle(
            'Suporte',
          ),

          const SizedBox(height: 10),

          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.help_outline_rounded,
              title: 'Ajuda e suporte',
              subtitle: 'Encontre respostas e entre em contato',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AjudaPage(),
                  ),
                );
              },
            ),

            _buildDivider(),

            _buildSettingItem(
              icon: Icons.info_outline_rounded,
              title: 'Sobre o AgroTech',
              subtitle: 'Informações sobre o aplicativo',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SobrePage(),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 30),

          _buildLogoutButton(),

          const SizedBox(height: 20),

          Center(
            child: Text(
              'AgroTech • TCC SENAI',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CABEÇALHO DO PERFIL
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,

            decoration: BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.person_rounded,
              color: darkGreen,
              size: 31,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Olá!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.userName,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Sua conta AgroTech',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.verified_rounded,
            color: green,
            size: 24,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TÍTULO
  // ============================================================

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildSettingsCard(
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: children,
      ),
    );
  }

  // ============================================================
  // ITEM
  // ============================================================

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(20),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                      BorderRadius.circular(13),
                ),

                child: Icon(
                  icon,
                  color: darkGreen,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DIVISOR
  // ============================================================

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 74,
      endIndent: 16,
      color: Colors.grey.shade200,
    );
  }

  // ============================================================
  // SAIR
  // ============================================================

  Widget _buildLogoutButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,

      child: GestureDetector(
        onTap: _confirmarLogout,

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),

          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.red.withOpacity(0.15),
            ),
          ),

          child: const Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 20,
              ),

              SizedBox(width: 9),

              Text(
                'Sair da conta',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONFIRMAR LOGOUT
  // ============================================================

  void _confirmarLogout() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(
            'Sair da conta?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),

          content: const Text(
            'Você será direcionado para a tela de login.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Cancelar',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const LoginScreen(),
                  ),
                  (route) => false,
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              child: const Text(
                'Sair',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MENSAGEM
  // ============================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),

        behavior:
            SnackBarBehavior.floating,

        backgroundColor: darkGreen,

        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
  }
}