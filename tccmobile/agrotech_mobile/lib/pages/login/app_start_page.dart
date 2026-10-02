import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'Login_page.dart';
import '../clientes/home/home_page.dart';

class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {

  @override
  void initState() {
    super.initState();

    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    final logado = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (logado) {
      final nome = await AuthService.getUserName();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userName: nome,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F9F7),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF19A974),
        ),
      ),
    );
  }
}