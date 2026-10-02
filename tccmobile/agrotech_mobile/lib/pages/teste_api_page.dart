import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TesteApiPage extends StatefulWidget {
  const TesteApiPage({super.key});

  @override
  State<TesteApiPage> createState() => _TesteApiPageState();
}

class _TesteApiPageState extends State<TesteApiPage> {
  String mensagem = 'Testando conexão...';

  @override
  void initState() {
    super.initState();
    testarApi();
  }

  Future<void> testarApi() async {
    final conectado = await ApiService.testarConexao();

    setState(() {
      if (conectado != null) {
        mensagem = 'API conectada com sucesso! ✅';
      } else {
        mensagem = 'Não foi possível conectar com a API ❌';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste da API'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: testarApi,
              child: const Text('Testar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}