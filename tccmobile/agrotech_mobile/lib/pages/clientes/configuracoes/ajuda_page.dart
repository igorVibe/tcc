import 'package:flutter/material.dart';

class AjudaPage extends StatelessWidget {
  const AjudaPage({
    super.key,
  });

  final Color green = const Color(0xFF19A974);
  final Color darkGreen = const Color(0xFF087443);
  final Color lightGreen = const Color(0xFFE7F8EF);
  final Color background = const Color(0xFFF7F9F7);

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
          'Ajuda e suporte',
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
                const EdgeInsets.all(22),

            decoration: BoxDecoration(
              color: green,
              borderRadius:
                  BorderRadius.circular(22),
            ),

            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 35,
                ),

                SizedBox(height: 12),

                Text(
                  'Como podemos ajudar?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Encontre respostas para as principais dúvidas sobre o AgroTech.',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          _buildOption(
            context,
            Icons.menu_book_outlined,
            'Como usar o AgroTech',
            'Aprenda a utilizar os recursos do aplicativo.',
          ),

          _buildOption(
            context,
            Icons.smart_toy_outlined,
            'Como cadastrar um Rover',
            'Veja como adicionar um novo Rover.',
          ),

          _buildOption(
            context,
            Icons.grass_outlined,
            'Como cadastrar um Talhão',
            'Veja como cadastrar sua área de plantação.',
          ),

          _buildOption(
            context,
            Icons.water_drop_outlined,
            'Monitoramento da umidade',
            'Entenda os dados de umidade do solo.',
          ),

          _buildOption(
            context,
            Icons.contact_support_outlined,
            'Falar com suporte',
            'Entre em contato com a equipe.',
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,

          builder: (context) {
            return AlertDialog(
              title: Text(title),

              content: Text(
                '$subtitle\n\n'
                'Esta seção faz parte do sistema de ajuda do AgroTech.',
              ),

              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context),

                  child: const Text(
                    'Entendi',
                  ),
                ),
              ],
            );
          },
        );
      },

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

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}