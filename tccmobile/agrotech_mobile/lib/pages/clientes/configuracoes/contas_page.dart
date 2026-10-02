import 'package:flutter/material.dart';

import 'package:agrotech_mobile/services/theme_service.dart';
import 'package:agrotech_mobile/services/user_storage.dart';

class ContaPage extends StatefulWidget {
  final String userName;

  const ContaPage({
    super.key,
    this.userName = 'Usuário',
  });

  @override
  State<ContaPage> createState() => _ContaPageState();
}

class _ContaPageState extends State<ContaPage> {
  late TextEditingController nomeController;

  final TextEditingController emailController =
      TextEditingController(text: 'usuario@agrotech.com');

  final TextEditingController telefoneController =
      TextEditingController(text: '(00) 00000-0000');

  bool _salvando = false;

  Color get green => ThemeService.primaryColor;
  Color get darkGreen => ThemeService.darkPrimaryColor;
  Color get lightGreen => ThemeService.lightPrimaryColor;
  Color get background =>
      Theme.of(context).scaffoldBackgroundColor;
  Color get surface => Theme.of(context).colorScheme.surface;
  Color get textColor =>
      Theme.of(context).colorScheme.onSurface;
  Color get secondaryTextColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.userName);
    _carregarNome();
  }

  Future<void> _carregarNome() async {
    final nome = await UserStorage.getNome();

    if (!mounted) return;

    if (nome.trim().isNotEmpty && nome.trim() != 'Usuário') {
      setState(() {
        nomeController.text = nome;
      });
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    final nome = nomeController.text.trim();

    if (nome.isEmpty) {
      _mostrarMensagem(
        'Atenção',
        'Digite um nome antes de salvar.',
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      await UserStorage.salvarNome(nome);

      if (!mounted) return;

      Navigator.pop(context, nome);
    } catch (e) {
      if (!mounted) return;

      _mostrarMensagem(
        'Erro',
        'Não foi possível salvar as alterações.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  void _mostrarMensagem(String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surface,
          title: Text(
            titulo,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            mensagem,
            style: TextStyle(color: secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fechar',
                style: TextStyle(
                  color: green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: textColor,
          ),
        ),
        title: Text(
          'Conta e perfil',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 28),
          Text(
            'Informações pessoais',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: nomeController,
            label: 'Nome',
            hint: 'Digite seu nome',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 15),
          _buildField(
            controller: emailController,
            label: 'E-mail',
            hint: 'Digite seu e-mail',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          _buildField(
            controller: telefoneController,
            label: 'Telefone',
            hint: 'Digite seu telefone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 54,
            width: double.infinity,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvarAlteracoes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  disabledBackgroundColor: green.withOpacity(0.6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _salvando
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Salvar alterações',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'As alterações do nome serão salvas localmente e '
            'utilizadas no aplicativo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              size: 48,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            nomeController.text.isEmpty
                ? 'Usuário'
                : nomeController.text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Perfil AgroTech',
            style: TextStyle(
              fontSize: 12,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        color: textColor,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: secondaryTextColor),
        hintStyle: TextStyle(
          color: secondaryTextColor.withOpacity(0.7),
        ),
        prefixIcon: Icon(
          icon,
          color: darkGreen,
        ),
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context)
                .dividerColor
                .withOpacity(0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: green,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
