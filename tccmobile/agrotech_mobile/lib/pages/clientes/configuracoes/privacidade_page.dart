import 'package:flutter/material.dart';

class PrivacidadePage extends StatefulWidget {
  const PrivacidadePage({
    super.key,
  });

  @override
  State<PrivacidadePage> createState() =>
      _PrivacidadePageState();
}

class _PrivacidadePageState
    extends State<PrivacidadePage> {
  final Color green = const Color(0xFF19A974);
  final Color darkGreen = const Color(0xFF087443);
  final Color lightGreen = const Color(0xFFE7F8EF);
  final Color background = const Color(0xFFF7F9F7);

  bool compartilharDados = true;
  bool coletaAnalitica = false;
  bool localizacao = true;

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
          'Privacidade',
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
                  Icons.lock_outline_rounded,
                  color: darkGreen,
                  size: 32,
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Text(
                    'Você controla quais informações o AgroTech pode utilizar.',
                    style: TextStyle(
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          _buildSwitch(
            title: 'Compartilhar dados',
            subtitle:
                'Permitir compartilhamento para melhorar o sistema',
            value: compartilharDados,
            onChanged: (value) {
              setState(() {
                compartilharDados = value;
              });
            },
          ),

          _buildSwitch(
            title: 'Dados analíticos',
            subtitle:
                'Enviar dados anônimos de utilização',
            value: coletaAnalitica,
            onChanged: (value) {
              setState(() {
                coletaAnalitica = value;
              });
            },
          ),

          _buildSwitch(
            title: 'Localização',
            subtitle:
                'Permitir utilização da localização do dispositivo',
            value: localizacao,
            onChanged: (value) {
              setState(() {
                localizacao = value;
              });
            },
          ),

          const SizedBox(height: 20),

          _buildAction(
            icon: Icons.delete_outline_rounded,
            title: 'Excluir dados locais',
            subtitle:
                'Remove dados armazenados neste dispositivo',
            color: Colors.red,
            onTap: _confirmarExclusao,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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

          Switch(
            value: value,
            activeColor: green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding:
            const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Row(
          children: [
            Icon(
              icon,
              color: color,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w800,
                      color: color,
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

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Excluir dados?',
          ),

          content: const Text(
            'Essa ação remove os dados locais do aplicativo.',
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
                      'Dados locais removidos.',
                    ),
                  ),
                );
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),

              child: const Text(
                'Excluir',
              ),
            ),
          ],
        );
      },
    );
  }
}