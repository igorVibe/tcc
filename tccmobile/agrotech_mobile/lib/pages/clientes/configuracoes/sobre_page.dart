import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({
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
          'Sobre o AgroTech',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,

              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius:
                    BorderRadius.circular(30),
              ),

              child: Icon(
                Icons.agriculture_rounded,
                color: darkGreen,
                size: 52,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'AgroTech',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Center(
            child: Text(
              'Tecnologia para o campo',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 30),

          _buildCard(
            icon: Icons.info_outline_rounded,
            title: 'Versão',
            value: '1.0.0',
          ),

          _buildCard(
            icon: Icons.school_outlined,
            title: 'Projeto',
            value: 'TCC SENAI - Tecnologia da Informação',
          ),

          _buildCard(
            icon: Icons.smart_toy_outlined,
            title: 'Objetivo',
            value:
                'Monitoramento de operações agrícolas através de tecnologia.',
          ),

          const SizedBox(height: 20),

          Container(
            padding:
                const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: green,
              borderRadius:
                  BorderRadius.circular(22),
            ),

            child: const Column(
              children: [
                Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 35,
                ),

                SizedBox(height: 10),

                Text(
                  'AgroTech',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Tecnologia, dados e inovação para uma agricultura mais inteligente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Center(
            child: Text(
              'Desenvolvido para o projeto TCC',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
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
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}