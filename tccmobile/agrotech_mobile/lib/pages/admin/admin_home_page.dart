import 'package:flutter/material.dart';

import 'package:agrotech_mobile/services/user_storage.dart';
import '../../services/rover_storage.dart';
import '../../services/talhao_storage.dart';
import '../../services/theme_service.dart';

import 'package:agrotech_mobile/pages/login/login_page.dart';
import 'package:agrotech_mobile/pages/clientes/rovers/cadastro_rover_page.dart';
import 'package:agrotech_mobile/pages/clientes/talhoes/cadastro_talhoes.dart';

class AdminHomePage extends StatefulWidget {
  final String userName;

  const AdminHomePage({
    super.key,
    this.userName = 'Administrador',
  });

  @override
  State<AdminHomePage> createState() =>
      _AdminHomePageState();
}

class _AdminHomePageState
    extends State<AdminHomePage> {
  

  int _selectedIndex = 0;

  List<Map<String, dynamic>> _usuarios = [];
  bool _carregandoUsuarios = true;

  List<Map<String, String>> _rovers = [];
  List<Map<String, String>> _talhoes = [];

  Color get green =>
      ThemeService.primaryColor;

  Color get darkGreen =>
      ThemeService.darkPrimaryColor;

  Color get lightGreen =>
      ThemeService.lightPrimaryColor;

  Color get background =>
      Theme.of(context).scaffoldBackgroundColor;

  Color get surface =>
      Theme.of(context).colorScheme.surface;

  Color get textColor =>
      Theme.of(context).colorScheme.onSurface;

  Color get secondaryTextColor =>
      Theme.of(context)
          .colorScheme
          .onSurfaceVariant;

  @override
  void initState() {
    super.initState();

    _carregarDados();
    
  }
  
  Future<void> _carregarDados() async {
  final usuarios = await UserStorage.getUsuarios();
  final rovers = await RoverStorage.getRovers();
  final talhoes = await TalhaoStorage.getTalhoes();

  if (!mounted) return;

  setState(() {
    _usuarios = usuarios;
    _rovers = rovers;
    _talhoes = talhoes;

    _carregandoUsuarios = false;
  });
}

  Future<void> _cadastrarRover() async {

    final resultado =
        await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CadastroRoverScreen(),
      ),
    );

    if (resultado == null) return;

    await RoverStorage.saveRover(
      resultado,
    );

    await _carregarDados();

    if (!mounted) return;

    _mostrarMensagem(
      'Rover cadastrado',
      '${resultado['nome'] ?? 'Rover'} foi adicionado ao sistema.',
    );
  }

  Future<void> _cadastrarTalhao() async {

    final resultado =
        await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CadastroTalhaoScreen(),
      ),
    );

    if (resultado == null) return;

    await TalhaoStorage.saveTalhao(
      resultado,
    );

    await _carregarDados();

    if (!mounted) return;

    _mostrarMensagem(
      'Talhão cadastrado',
      '${resultado['nome'] ?? 'Talhão'} foi adicionado ao sistema.',
    );
  }

  Future<void> _sair() async {

    await UserStorage.limparUsuario();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _mostrarMensagem(
    String titulo,
    String mensagem,
  ) {

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(
          backgroundColor: surface,

          title: Text(
            titulo,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),

          content: Text(
            mensagem,
            style: TextStyle(
              color: secondaryTextColor,
            ),
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(context),

              child: Text(
                'Fechar',
                style: TextStyle(
                  color: green,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final paginas = [

      _buildDashboard(),

      _buildUsuariosPage(),

      _buildRovers(),

      _buildTalhoes(),

      _buildTelemetria(),
    ];

    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: paginas,
        ),
      ),

      bottomNavigationBar:
          NavigationBar(

        selectedIndex:
            _selectedIndex,

        onDestinationSelected:
            (index) {

          setState(() {
            _selectedIndex = index;
          });
        },

        backgroundColor: surface,

        indicatorColor:
            lightGreen,

        destinations: [

          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
              color: secondaryTextColor,
            ),
            selectedIcon: Icon(
              Icons.dashboard_rounded,
              color: darkGreen,
            ),
            label: 'Dashboard',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.people_outline_rounded,
              color: secondaryTextColor,
            ),
            selectedIcon: Icon(
              Icons.people_rounded,
              color: darkGreen,
            ),
            label: 'Usuários',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.smart_toy_outlined,
              color: secondaryTextColor,
            ),
            selectedIcon: Icon(
              Icons.smart_toy_rounded,
              color: darkGreen,
            ),
            label: 'Rovers',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.grass_outlined,
              color: secondaryTextColor,
            ),
            selectedIcon: Icon(
              Icons.grass_rounded,
              color: darkGreen,
            ),
            label: 'Talhões',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.sensors_outlined,
              color: secondaryTextColor,
            ),
            selectedIcon: Icon(
              Icons.sensors_rounded,
              color: darkGreen,
            ),
            label: 'Telemetria',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {

    final online =
        _rovers.where(
      (rover) =>
          (rover['status'] ?? '')
              .toLowerCase() ==
          'online',
    ).length;

    return RefreshIndicator(
      onRefresh: _carregarDados,

      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.fromLTRB(
          20,
          25,
          20,
          120,
        ),

        children: [

          Row(
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      'Painel administrativo',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight.w900,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Olá, ${widget.userName} 👋',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 48,
                height: 48,

                decoration:
                    BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                child: Icon(
                  Icons
                      .admin_panel_settings_rounded,
                  color: darkGreen,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 28,
          ),

          Text(
            'Visão geral do sistema',
            style: TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.w800,
              color: textColor,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          _buildAdminStats(
              icon: Icons.people_alt_outlined,
              title: 'Usuários',
              value: '${_usuarios.length}',
              detail: 'cadastrados',
          ),

          const SizedBox(
            height: 12,
          ),

          _buildAdminStats(
            icon:
                Icons.smart_toy_outlined,
            title: 'Rovers',
            value:
                '${_rovers.length}',
            detail:
                '$online online',
          ),

          const SizedBox(
            height: 12,
          ),

          _buildAdminStats(
            icon:
                Icons.grass_outlined,
            title: 'Talhões',
            value:
                '${_talhoes.length}',
            detail: 'cadastrados',
          ),

          const SizedBox(
            height: 12,
          ),

          _buildAdminStats(
            icon:
                Icons.warning_amber_outlined,
            title: 'Alertas',
            value: '05',
            detail: 'pendentes',
          ),

          const SizedBox(
            height: 28,
          ),

          Text(
            'Ações rápidas',
            style: TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.w800,
              color: textColor,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Row(
            children: [

              Expanded(
                child: _buildAction(
                  'Novo Rover',
                  Icons.smart_toy_rounded,
                  _cadastrarRover,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: _buildAction(
                  'Novo Talhão',
                  Icons.grass_rounded,
                  _cadastrarTalhao,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          _buildInfoCard(
            icon:
                Icons.security_rounded,
            title:
                'Acesso administrativo',
            text:
                'Nesta área o administrador pode acompanhar e gerenciar os dados de todo o sistema.',
          ),

          const SizedBox(
            height: 12,
          ),

          _buildInfoCard(
            icon:
                Icons.logout_rounded,
            title:
                'Sair da conta',
            text:
                'Encerrar a sessão administrativa neste dispositivo.',
            onTap: _sair,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminStats({
    required IconData icon,
    required String title,
    required String value,
    required String detail,
  }) {

    return Container(
      padding:
          const EdgeInsets.all(17),

      decoration:
          BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(.35),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 46,
            height: 46,

            decoration:
                BoxDecoration(
              color: lightGreen,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: Icon(
              icon,
              color: darkGreen,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight:
                    FontWeight.w700,
                color: textColor,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.w900,
              color: textColor,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Text(
            detail,
            style: TextStyle(
              fontSize: 10,
              color:
                  secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {

    return MouseRegion(
      cursor:
          SystemMouseCursors.click,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(18),

        child: Container(
          padding:
              const EdgeInsets.symmetric(
            vertical: 18,
          ),

          decoration:
              BoxDecoration(
            color: green,
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),

          child: Column(
            children: [

              Icon(
                icon,
                color: Colors.white,
                size: 27,
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String text,
    VoidCallback? onTap,
  }) {

    final card = Container(
      padding:
          const EdgeInsets.all(17),

      decoration:
          BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(.35),
        ),
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: darkGreen,
          ),

          const SizedBox(
            width: 13,
          ),

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
                    color: textColor,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  text,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        secondaryTextColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color:
                  secondaryTextColor,
            ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return MouseRegion(
      cursor:
          SystemMouseCursors.click,

      child: GestureDetector(
        onTap: onTap,
        child: card,
      ),
    );
  }

  Widget _buildUsuariosPage() {
  return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: RefreshIndicator(
      onRefresh: _carregarDados,
      child: _carregandoUsuarios
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _usuarios.isEmpty
              ? ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 180),
                    Center(
                      child: Text(
                        'Nenhum usuário encontrado.',
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    26,
                    25,
                    26,
                    110,
                  ),
                  itemCount: _usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = _usuarios[index];

                    final nome =
                        usuario['nome']?.toString() ??
                            'Usuário';

                    final email =
                        usuario['email']?.toString() ??
                            '';

                    final role =
                        usuario['role']?.toString() ??
                            'cliente';

                    final isAdmin =
                        role == 'administrador';

                    return Container(
                      margin:
                          const EdgeInsets.only(bottom: 16),
                      padding:
                          const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface,
                        borderRadius:
                            BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context)
                              .dividerColor
                              .withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE7F8EF,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isAdmin
                                  ? Icons
                                      .admin_panel_settings_rounded
                                  : Icons
                                      .person_rounded,
                              color: const Color(
                                0xFF087443,
                              ),
                              size: 30,
                            ),
                          ),

                          const SizedBox(width: 18),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nome,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            isAdmin
                                ? 'Administrador'
                                : 'Cliente',
                            style: TextStyle(
                              color: const Color(
                                0xFF087443,
                              ),
                              fontWeight:
                                  FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    ),
  );
}

  Widget _buildUserCard(
    String nome,
    String email,
    String tipo,
    IconData icon,
  ) {

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(.35),
        ),
      ),

      child: Row(
        children: [

          CircleAvatar(
            backgroundColor:
                lightGreen,

            child: Icon(
              icon,
              color: darkGreen,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  nome,
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w800,
                    color: textColor,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  email,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          Text(
            tipo,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
              color: darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRovers() {

    return _adminPage(
      title: 'Todos os Rovers',
      subtitle:
          'Gerenciamento dos equipamentos',
      icon:
          Icons.smart_toy_rounded,

      child: Column(
        children: [

          Align(
            alignment:
                Alignment.centerRight,

            child: _buildSmallButton(
              'Adicionar Rover',
              Icons.add_rounded,
              _cadastrarRover,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          if (_rovers.isEmpty)
            _empty(
              Icons.smart_toy_outlined,
              'Nenhum rover cadastrado',
            )
          else
            ..._rovers.map(
              (rover) =>
                  _buildRoverCard(rover),
            ),
        ],
      ),
    );
  }

  Widget _buildRoverCard(
    Map<String, String> rover,
  ) {

    final online =
        (rover['status'] ?? '')
            .toLowerCase() ==
        'online';

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(17),

      decoration:
          BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(.35),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 52,
            height: 52,

            decoration:
                BoxDecoration(
              color: lightGreen,
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),

            child: Icon(
              Icons.smart_toy_rounded,
              color: darkGreen,
              size: 28,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  rover['nome'] ??
                      'Rover',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w800,
                    color: textColor,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'Código: ${rover['codigo'] ?? '-'}',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        secondaryTextColor,
                  ),
                ),

                Text(
                  'Talhão: ${rover['talhao'] ?? '-'}',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [

              Text(
                rover['bateria'] ??
                    '100%',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w800,
                  color: textColor,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                rover['status'] ??
                    'Online',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w700,
                  color: online
                      ? green
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTalhoes() {

    return _adminPage(
      title: 'Todos os Talhões',
      subtitle:
          'Gerenciamento das áreas agrícolas',
      icon:
          Icons.grass_rounded,

      child: Column(
        children: [

          Align(
            alignment:
                Alignment.centerRight,

            child: _buildSmallButton(
              'Adicionar Talhão',
              Icons.add_rounded,
              _cadastrarTalhao,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          if (_talhoes.isEmpty)
            _empty(
              Icons.landscape_outlined,
              'Nenhum talhão cadastrado',
            )
          else
            ..._talhoes.map(
              (talhao) =>
                  _buildTalhaoCard(talhao),
            ),
        ],
      ),
    );
  }

  Widget _buildTalhaoCard(
    Map<String, String> talhao,
  ) {

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(17),

      decoration:
          BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(.35),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 52,
            height: 52,

            decoration:
                BoxDecoration(
              color: lightGreen,
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),

            child: Icon(
              Icons.grass_rounded,
              color: darkGreen,
              size: 28,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  talhao['nome'] ??
                      'Talhão',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w800,
                    color: textColor,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'Código: ${talhao['codigo'] ?? '-'}',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        secondaryTextColor,
                  ),
                ),

                Text(
                  'Área: ${talhao['area'] ?? '-'}',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          Text(
            'Ativo',
            style: TextStyle(
              color: darkGreen,
              fontWeight:
                  FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetria() {

    return _adminPage(
      title: 'Telemetria',
      subtitle:
          'Acompanhamento dos dados dos equipamentos',
      icon:
          Icons.sensors_rounded,

      child: Column(
        children: [

          _buildTelemetryMetric(
            Icons.water_drop_outlined,
            'Umidade média',
            '67%',
            'Solo',
          ),

          _buildTelemetryMetric(
            Icons.battery_full_rounded,
            'Bateria média',
            '72%',
            'Rovers',
          ),

          _buildTelemetryMetric(
            Icons.local_gas_station_outlined,
            'Combustível',
            '72%',
            'Rovers',
          ),

          _buildTelemetryMetric(
            Icons.speed_rounded,
            'Velocidade',
            '2,4 km/h',
            'Média',
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryMetric(
    IconData icon,
    String title,
    String value,
    String detail,
  ) {

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(17),

      decoration:
          BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(.35),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 47,
            height: 47,

            decoration:
                BoxDecoration(
              color: lightGreen,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: Icon(
              icon,
              color: darkGreen,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight:
                    FontWeight.w700,
                color: textColor,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.w900,
              color: textColor,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Text(
            detail,
            style: TextStyle(
              fontSize: 10,
              color:
                  secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminPage({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {

    return SingleChildScrollView(
      physics:
          const BouncingScrollPhysics(),

      padding:
          const EdgeInsets.fromLTRB(
        20,
        25,
        20,
        120,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Container(
                width: 48,
                height: 48,

                decoration:
                    BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                child: Icon(
                  icon,
                  color: darkGreen,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w900,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 25,
          ),

          child,
        ],
      ),
    );
  }

  Widget _buildSmallButton(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {

    return MouseRegion(
      cursor:
          SystemMouseCursors.click,

      child: ElevatedButton.icon(
        onPressed: onTap,

        icon: Icon(
          icon,
          size: 18,
        ),

        label: Text(title),

        style:
            ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor:
              Colors.white,
          elevation: 0,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _empty(
    IconData icon,
    String text,
  ) {

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(28),

      decoration:
          BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(.35),
        ),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            size: 45,
            color: darkGreen,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            text,
            textAlign:
                TextAlign.center,

            style: TextStyle(
              color:
                  secondaryTextColor,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}