import 'package:flutter/material.dart';

class CadastroRoverScreen extends StatefulWidget {
  const CadastroRoverScreen({super.key});

  @override
  State<CadastroRoverScreen> createState() => _CadastroRoverScreenState();
}

class _CadastroRoverScreenState extends State<CadastroRoverScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _talhaoController = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    _talhaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarRover() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _salvando = true;
    });

    // Simulação de salvamento
    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      _salvando = false;
    });

    // Dados do rover cadastrado
    final rover = {
      'nome': _nomeController.text.trim(),
      'codigo': _codigoController.text.trim(),
      'talhao': _talhaoController.text.trim(),
      'status': 'Online',
      'bateria': '100%',
    };

    // Retorna o rover para a Home
    Navigator.pop(context, rover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F7),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Criar Rover',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ÍCONE
                Center(
                  child: Container(
                    width: 90,
                    height: 90,

                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F8EF),
                      borderRadius: BorderRadius.circular(28),
                    ),

                    child: const Icon(
                      Icons.smart_toy_rounded,
                      size: 48,
                      color: Color(0xFF19A974),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // TÍTULO
                const Center(
                  child: Text(
                    'Novo Rover',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // DESCRIÇÃO
                const Center(
                  child: Text(
                    'Cadastre um novo rover para acompanhar\n'
                    'as informações da plantação.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                _buildLabel('Nome do Rover'),

                _buildTextField(
                  controller: _nomeController,
                  hint: 'Ex: Rover Alpha',
                  icon: Icons.smart_toy_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite o nome do rover';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildLabel('Código do Rover'),

                _buildTextField(
                  controller: _codigoController,
                  hint: 'Ex: ROV-001',
                  icon: Icons.qr_code_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite o código do rover';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildLabel('Talhão'),

                _buildTextField(
                  controller: _talhaoController,
                  hint: 'Ex: Talhão A1',
                  icon: Icons.agriculture_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Digite o talhão';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // BOTÃO
                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,

                    child: ElevatedButton(
                      onPressed: _salvando
                          ? null
                          : _salvarRover,

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF19A974),

                        foregroundColor: Colors.white,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),

                      child: AnimatedSwitcher(
                        duration:
                            const Duration(milliseconds: 250),

                        child: _salvando
                            ? const SizedBox(
                                key: ValueKey('loading'),

                                width: 24,
                                height: 24,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                key: ValueKey('text'),

                                mainAxisAlignment:
                                    MainAxisAlignment.center,

                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                  ),

                                  SizedBox(width: 10),

                                  Text(
                                    'Cadastrar Rover',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: Text(
                    'Os dados poderão ser conectados à API posteriormente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Text(
        text,

        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,

      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: const TextStyle(
          color: Colors.black38,
        ),

        prefixIcon: Icon(
          icon,
          color: const Color(0xFF19A974),
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF19A974),
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}