import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:agrotech_mobile/pages/clientes/home/home_page.dart';
import 'package:agrotech_mobile/pages/login/esqueci_senha.dart';
import 'package:agrotech_mobile/services/auth_service.dart';
import 'package:agrotech_mobile/services/user_storage.dart';
import 'package:agrotech_mobile/models/user_role.dart';
import 'package:agrotech_mobile/pages/admin/admin_home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late AnimationController _animationController;

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Preencha o e-mail e a senha.');
      return;
    }

    setState(() {
      _loading = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    // ==========================================================
    // LOGIN DO ADMINISTRADOR
    // ==========================================================

    final isAdmin =
        email.toLowerCase() == 'admin@gmail.com' &&
        password == 'admin123';

    // ==========================================================
    // DEFINE O NOME
    // ==========================================================

    final nome = isAdmin
        ? 'Administrador'
        : _nomeAPartirDoEmail(email);

    // ==========================================================
    // DEFINE O TIPO DE USUÁRIO
    // ==========================================================

    final role = isAdmin
        ? UserRole.administrador
        : UserRole.cliente;

    // ==========================================================
    // SALVA A SESSÃO
    // ==========================================================

    await AuthService.salvarLogin(nome);

    await UserStorage.salvarUsuario(
      nome: nome,
      email: email,
      role: role,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
    });

    // ==========================================================
    // ABRE A TELA CORRETA
    // ==========================================================

    if (isAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminHomePage(
            userName: nome,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            userName: nome,
          ),
        ),
      );
    }
  }

  // ============================================================
  // TRANSFORMA O E-MAIL EM NOME
  // ============================================================

  String _nomeAPartirDoEmail(String email) {
    final parte = email.split('@').first.trim();

    if (parte.isEmpty) {
      return 'Usuário';
    }

    return parte
        .split(RegExp(r'[._-]+'))
        .where((item) => item.isNotEmpty)
        .map(
          (item) =>
              item[0].toUpperCase() +
              item.substring(1),
        )
        .join(' ');
  }

  // ============================================================
  // MENSAGEM
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            const Color.fromARGB(255, 209, 222, 209),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // ANIMAÇÃO
  // ============================================================

  Widget _animatedItem({
    required Widget child,
    required double begin,
    required double end,
  }) {
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = Tween<double>(
          begin: begin,
          end: end,
        ).animate(animation).value;

        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, value),
            child: child,
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ======================================================
          // FUNDO
          // ======================================================

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF071A12),
                  Color(0xFF0B2418),
                  Color(0xFF050907),
                ],
              ),
            ),
          ),

          // ======================================================
          // BRILHO SUPERIOR
          // ======================================================

          Positioned(
            top: -100,
            left: -80,
            child: _glowCircle(
              size: 280,
              color: const Color(0xFF28A866),
            ),
          ),

          // ======================================================
          // BRILHO INFERIOR
          // ======================================================

          Positioned(
            bottom: -120,
            right: -80,
            child: _glowCircle(
              size: 300,
              color: const Color(0xFF0D7A4A),
            ),
          ),

          // ======================================================
          // CONTEÚDO
          // ======================================================

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 460,
                  ),
                  child: Column(
                    children: [
                      // ==================================================
                      // LOGO
                      // ==================================================

                      _animatedItem(
                        begin: 35,
                        end: 0,
                        child: _buildLogo(),
                      ),

                      const SizedBox(height: 28),

                      // ==================================================
                      // TÍTULO
                      // ==================================================

                      _animatedItem(
                        begin: 30,
                        end: 0,
                        child: const Column(
                          children: [
                            Text(
                              'Bem-vindo ao AgroTech',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tecnologia inteligente para o campo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // CARD
                      // ==================================================

                      _animatedItem(
                        begin: 45,
                        end: 0,
                        child: _buildGlassCard(),
                      ),

                      const SizedBox(height: 25),

                      // ==================================================
                      // CADASTRO
                      // ==================================================

                      _animatedItem(
                        begin: 25,
                        end: 0,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Ainda não possui uma conta? ',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showMessage(
                                  'Tela de cadastro em desenvolvimento.',
                                );
                              },
                              child: const Text(
                                'Criar conta',
                                style: TextStyle(
                                  color: Color(0xFF55D98B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'AGROTECH • SMART AGRICULTURE',
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo() {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2DD477),
            Color(0xFF087A43),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF24C873)
                .withOpacity(0.35),
            blurRadius: 35,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.eco_rounded,
        size: 43,
        color: Colors.white,
      ),
    );
  }

  // ============================================================
  // CARD DO LOGIN
  // ============================================================

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Acesse seu painel de monitoramento.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // EMAIL
              // ==================================================

              _buildInput(
                controller: _emailController,
                focusNode: _emailFocus,
                label: 'E-mail',
                hint: 'seuemail@exemplo.com',
                icon: Icons.email_outlined,
                keyboardType:
                    TextInputType.emailAddress,
              ),

              const SizedBox(height: 17),

              // ==================================================
              // SENHA
              // ==================================================

              _buildInput(
                controller: _passwordController,
                focusNode: _passwordFocus,
                label: 'Senha',
                hint: 'Digite sua senha',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword;
                    });
                  },
                  icon: AnimatedSwitcher(
                    duration:
                        const Duration(milliseconds: 200),
                    transitionBuilder:
                        (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      _obscurePassword
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                      key: ValueKey(
                        _obscurePassword,
                      ),
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // ESQUECI SENHA
              // ==================================================

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const EsqueciSenhaScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(
                      color: Color(0xFF5BE394),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // BOTÃO LOGIN
              // ==================================================

              _buildLoginButton(),

              const SizedBox(height: 25),

              // ==================================================
              // DIVISOR
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white12,
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      'ou continue com',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // GOOGLE + APPLE
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: _socialButton(
                      icon: 'G',
                      text: 'Google',
                      onTap: () {
                        _showMessage(
                          'Login com Google em desenvolvimento.',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _socialButton(
                      icon: '●',
                      text: 'Apple',
                      onTap: () {
                        _showMessage(
                          'Login com Apple em desenvolvimento.',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CAMPO DE TEXTO
  // ============================================================

  Widget _buildInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final focused = focusNode.hasFocus;

        return AnimatedContainer(
          duration:
              const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(17),
            color: focused
                ? const Color(0xFF1A3A29)
                : Colors.white.withOpacity(0.045),
            border: Border.all(
              color: focused
                  ? const Color(0xFF4FE18A)
                  : Colors.white.withOpacity(0.10),
              width: focused ? 1.4 : 1,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: const Color(0xFF39D879)
                          .withOpacity(0.12),
                      blurRadius: 15,
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            cursorColor:
                const Color(0xFF5BE394),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: TextStyle(
                color: focused
                    ? const Color(0xFF5BE394)
                    : Colors.white54,
              ),
              hintStyle: const TextStyle(
                color: Colors.white24,
                fontSize: 13,
              ),
              prefixIcon: Icon(
                icon,
                color: focused
                    ? const Color(0xFF5BE394)
                    : Colors.white54,
              ),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BOTÃO DE LOGIN
  // ============================================================

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(17),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3BE07D),
              Color(0xFF129653),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF27D873)
                  .withOpacity(0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
                BorderRadius.circular(17),
            onTap: _loading ? null : _login,
            child: Center(
              child: AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 250),
                child: _loading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<
                                  Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Row(
                        key: ValueKey('login'),
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'Entrar no AgroTech',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTÕES SOCIAIS
  // ============================================================

  Widget _socialButton({
    required String icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 50,
      child: Material(
        color:
            Colors.white.withOpacity(0.045),
        borderRadius:
            BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(15),
              border: Border.all(
                color:
                    Colors.white.withOpacity(0.10),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  icon,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BRILHO DO FUNDO
  // ============================================================

  Widget _glowCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.08),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 100,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}