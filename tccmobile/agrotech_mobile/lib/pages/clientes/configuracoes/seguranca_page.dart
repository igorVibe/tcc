import 'package:flutter/material.dart';

class SegurancaPage extends StatefulWidget {
  const SegurancaPage({
    super.key,
  });

  @override
  State<SegurancaPage> createState() =>
      _SegurancaPageState();
}

class _SegurancaPageState
    extends State<SegurancaPage> {
  final Color green = const Color(0xFF19A974);
  final Color darkGreen = const Color(0xFF087443);
  final Color lightGreen = const Color(0xFFE7F8EF);
  final Color background = const Color(0xFFF7F9F7);

  bool autenticacao = false;

  bool esconderDados = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,

        leading: IconButton(
          onPressed: () =>
              Navigator.pop(context),

          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
          ),
        ),

        title: const Text(
          'Segurança',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Container(
            padding:
                const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: darkGreen,
                  size: 35,
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Text(
                    'Proteja sua conta e seus dados do AgroTech.',
                    style: TextStyle(
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          _buildOption(
            icon: Icons.lock_outline_rounded,
            title: 'Alterar senha',
            subtitle:
                'Atualize a senha da sua conta',
            onTap: _alterarSenha,
          ),

          _buildOption(
            icon:
                Icons.fingerprint_rounded,
            title: 'Autenticação biométrica',
            subtitle:
                'Usar biometria para entrar',
            trailing: Switch(
              value: autenticacao,
              activeColor: green,
              onChanged: (value) {
                setState(() {
                  autenticacao = value;
                });
              },
            ),
            onTap: () {
              setState(() {
                autenticacao = !autenticacao;
              });
            },
          ),

          _buildOption(
            icon:
                Icons.visibility_off_outlined,
            title: 'Ocultar informações sensíveis',
            subtitle:
                'Esconder informações importantes',
            trailing: Switch(
              value: esconderDados,
              activeColor: green,
              onChanged: (value) {
                setState(() {
                  esconderDados = value;
                });
              },
            ),
            onTap: () {
              setState(() {
                esconderDados = !esconderDados;
              });
            },
          ),

          _buildOption(
            icon: Icons.devices_outlined,
            title: 'Dispositivos conectados',
            subtitle:
                'Visualizar dispositivos conectados',
            onTap: () {
              _showMessage(
                'Dispositivos',
                'Nenhum outro dispositivo conectado.',
              );
            },
          ),

          _buildOption(
            icon:
                Icons.history_rounded,
            title: 'Atividade da conta',
            subtitle:
                'Veja atividades recentes',
            onTap: () {
              _showMessage(
                'Atividade',
                'Nenhuma atividade suspeita encontrada.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin:
            const EdgeInsets.only(bottom: 10),

        padding:
            const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,

              decoration: BoxDecoration(
                color: lightGreen,

                borderRadius:
                    BorderRadius.circular(13),
              ),

              child: Icon(
                icon,
                color: darkGreen,
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
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
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
    );
  }

  void _alterarSenha() {
    final senhaController =
        TextEditingController();

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Alterar senha',
          ),

          content: TextField(
            controller: senhaController,

            obscureText: true,

            decoration:
                const InputDecoration(
              labelText:
                  'Nova senha',

              prefixIcon:
                  Icon(Icons.lock_outline),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),

              child: const Text(
                'Cancelar',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Senha atualizada com sucesso!',
                    ),
                  ),
                );
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
              ),

              child: const Text(
                'Salvar',
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(
    String title,
    String message,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Text(title),

          content: Text(message),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),

              child: const Text(
                'OK',
              ),
            ),
          ],
        );
      },
    );
  }
}