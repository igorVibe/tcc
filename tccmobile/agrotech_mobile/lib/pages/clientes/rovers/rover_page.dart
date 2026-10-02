import 'package:flutter/material.dart';

import '../../../services/rover_storage.dart';
import 'cadastro_rover_page.dart';

class RoverPage extends StatefulWidget {
  const RoverPage({super.key});

  @override
  State<RoverPage> createState() => _RoverPageState();
}

class _RoverPageState extends State<RoverPage> {
  static const Color green = Color(0xFF19A974);

  List<Map<String, dynamic>> _rovers = [];

  @override
  void initState() {
    super.initState();

    _carregarRovers();
  }

  // ============================================================
  // CARREGAR ROVERS
  // ============================================================

  Future<void> _carregarRovers() async {
    final rovers =
        await RoverStorage.getRovers();

    if (!mounted) return;

    setState(() {
      _rovers = rovers;
    });
  }

  // ============================================================
  // ABRIR CADASTRO
  // ============================================================

  Future<void> _abrirCadastro() async {
    final resultado = await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) =>
            const CadastroRoverScreen(),
      ),
    );

    // Se cadastrou um Rover,
    // atualiza a lista
    if (resultado == true) {
      await _carregarRovers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F9F7),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            28,
            28,
            28,
            100,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // CABEÇALHO
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ÍCONE
                  Container(
                    width: 72,
                    height: 72,

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFE7F8EF,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),
                    ),

                    child: const Icon(
                      Icons
                          .smart_toy_rounded,
                      size: 38,
                      color: green,
                    ),
                  ),

                  const SizedBox(width: 18),

                  // TÍTULO
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          'Meus Rovers',

                          style: TextStyle(
                            fontSize: 32,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.black,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Acompanhe seus equipamentos',

                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // ==================================================
                  // BOTÃO CRIAR ROVER
                  // ==================================================

                  MouseRegion(
                    cursor:
                        SystemMouseCursors
                            .click,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _abrirCadastro,

                      icon: const Icon(
                        Icons.add_rounded,
                      ),

                      label: const Text(
                        'Criar Rover',
                      ),

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            green,

                        foregroundColor:
                            Colors.white,

                        elevation: 0,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),

                        textStyle:
                            const TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ==================================================
              // LISTA
              // ==================================================

              Expanded(
                child:
                    _buildListaRovers(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LISTA DE ROVERS
  // ============================================================

  Widget _buildListaRovers() {
    // Se ainda não cadastrou nenhum
    if (_rovers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFE7F8EF,
                ),

                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),

              child: const Icon(
                Icons.smart_toy_outlined,
                size: 48,
                color: green,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Nenhum Rover cadastrado',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Clique em "Criar Rover" para\n'
              'adicionar seu primeiro equipamento.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _rovers.length,

      separatorBuilder:
          (context, index) =>
              const SizedBox(height: 12),

      itemBuilder:
          (context, index) {
        final rover =
            _rovers[index];

        return _LargeStatusCard(
          name:
              rover['nome'] ??
                  'Rover',

          status:
              rover['status'] ??
                  'Online',

          battery:
              rover['bateria'] ??
                  '100%',

          location:
              rover['talhao'] ??
                  'Sem talhão',

          icon:
              Icons.smart_toy_rounded,

          color: green,
        );
      },
    );
  }
}

// ================================================================
// CARD DO ROVER
// ================================================================

class _LargeStatusCard
    extends StatelessWidget {
  final String name;
  final String status;
  final String battery;
  final String location;
  final IconData icon;
  final Color color;

  const _LargeStatusCard({
    required this.name,
    required this.status,
    required this.battery,
    required this.location,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool online =
        status.toLowerCase() ==
            'online';

    return MouseRegion(
      cursor:
          SystemMouseCursors.click,

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),

        padding:
            const EdgeInsets.all(24),

        decoration:
            BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            24,
          ),

          border: Border.all(
            color:
                Colors.grey.shade200,
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black
                      .withValues(
                alpha: 0.03,
              ),

              blurRadius: 12,

              offset:
                  const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            // ==================================================
            // ÍCONE
            // ==================================================

            Container(
              width: 72,
              height: 72,

              decoration:
                  BoxDecoration(
                color: online
                    ? const Color(
                        0xFFE7F8EF,
                      )
                    : const Color(
                        0xFFF2F2F2,
                      ),

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Icon(
                icon,

                size: 38,

                color: online
                    ? color
                    : Colors.grey,
              ),
            ),

            const SizedBox(width: 20),

            // ==================================================
            // NOME E STATUS
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Text(
                    name,

                    style:
                        const TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Colors.black,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,

                        decoration:
                            BoxDecoration(
                          color: online
                              ? Colors
                                  .green
                              : Colors
                                  .grey,

                          shape:
                              BoxShape
                                  .circle,
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        status,

                        style:
                            TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                          color: online
                              ? Colors
                                  .green
                              : Colors
                                  .grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // BATERIA E TALHÃO
            // ==================================================

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,

              children: [
                Text(
                  battery,

                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  location,

                  style:
                      const TextStyle(
                    fontSize: 14,
                    color:
                        Colors.black45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}