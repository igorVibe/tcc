import 'package:flutter/material.dart';

class NotificacoesPage extends StatefulWidget {
  final bool notificacoesAtivas;

  const NotificacoesPage({
    super.key,
    this.notificacoesAtivas = true,
  });

  @override
  State<NotificacoesPage> createState() =>
      _NotificacoesPageState();
}

class _NotificacoesPageState
    extends State<NotificacoesPage> {
  final Color green = const Color(0xFF19A974);
  final Color darkGreen = const Color(0xFF087443);
  final Color lightGreen = const Color(0xFFE7F8EF);
  final Color background = const Color(0xFFF7F9F7);

  late bool notificacoes;

  bool roverOnline = true;
  bool roverOffline = true;
  bool bateriaBaixa = true;
  bool umidade = true;
  bool manutencao = true;
  bool atualizacoes = false;

  @override
  void initState() {
    super.initState();

    notificacoes =
        widget.notificacoesAtivas;
  }

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
          'Notificações',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          _buildMainSwitch(),

          const SizedBox(height: 25),

          const Text(
            'Tipos de notificação',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          _buildSwitch(
            title: 'Rover conectado',
            subtitle:
                'Avise quando um rover entrar online',
            value: roverOnline,
            onChanged: (value) {
              setState(() {
                roverOnline = value;
              });
            },
          ),

          _buildSwitch(
            title: 'Rover desconectado',
            subtitle:
                'Avise quando um rover ficar offline',
            value: roverOffline,
            onChanged: (value) {
              setState(() {
                roverOffline = value;
              });
            },
          ),

          _buildSwitch(
            title: 'Bateria baixa',
            subtitle:
                'Receba alertas de bateria baixa',
            value: bateriaBaixa,
            onChanged: (value) {
              setState(() {
                bateriaBaixa = value;
              });
            },
          ),

          _buildSwitch(
            title: 'Umidade do solo',
            subtitle:
                'Alertas relacionados à umidade',
            value: umidade,
            onChanged: (value) {
              setState(() {
                umidade = value;
              });
            },
          ),

          _buildSwitch(
            title: 'Manutenção',
            subtitle:
                'Lembretes de manutenção',
            value: manutencao,
            onChanged: (value) {
              setState(() {
                manutencao = value;
              });
            },
          ),

          _buildSwitch(
            title: 'Atualizações',
            subtitle:
                'Novidades e atualizações do AgroTech',
            value: atualizacoes,
            onChanged: (value) {
              setState(() {
                atualizacoes = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainSwitch() {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: Icon(
              Icons.notifications_active_outlined,
              color: darkGreen,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Permitir notificações',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Ative ou desative todas as notificações',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: notificacoes,
            activeColor: Color(0xFF19A974),

            onChanged: (value) {
              setState(() {
                notificacoes = value;
              });
            },
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
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                    fontWeight: FontWeight.w700,
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
            value: notificacoes
                ? value
                : false,

            activeColor: green,

            onChanged:
                notificacoes
                    ? onChanged
                    : null,
          ),
        ],
      ),
    );
  }
}