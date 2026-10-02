import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:agrotech_mobile/pages/clientes/rovers/cadastro_rover_page.dart';
import 'package:agrotech_mobile/pages/clientes/talhoes/cadastro_talhoes.dart';

import 'package:agrotech_mobile/services/rover_storage.dart';
import 'package:agrotech_mobile/services/talhao_storage.dart';
import 'package:agrotech_mobile/services/theme_service.dart';
import 'package:agrotech_mobile/services/user_storage.dart';

import 'package:agrotech_mobile/pages/clientes/configuracoes/configuracoes.dart';
import 'package:agrotech_mobile/pages/clientes/configuracoes/notificacoes_page.dart';
import 'package:agrotech_mobile/pages/clientes/configuracoes/ajuda_page.dart';


// ============================================================
// HOME
// ============================================================

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({
    super.key,
    this.userName = 'Usuário',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


// ============================================================
// HOME STATE
// ============================================================

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;

  int _selectedIndex = 0;

  String _searchText = '';

  String _userName = 'Usuário';

  // ============================================================
  // LISTAS
  // ============================================================

  final List<Map<String, String>> _roversCadastrados = [];

  final List<Map<String, String>> _talhoesCadastrados = [];

  bool _carregandoRovers = true;

  bool _carregandoTalhoes = true;

  // ============================================================
  // CORES
  // ============================================================

  Color get green => ThemeService.primaryColor;

  Color get darkGreen => ThemeService.darkPrimaryColor;

  Color get lightGreen => ThemeService.lightPrimaryColor;

  Color get background =>
      Theme.of(context).scaffoldBackgroundColor;

  Color get surface =>
      Theme.of(context).colorScheme.surface;

  Color get textColor =>
      Theme.of(context).colorScheme.onSurface;

  Color get secondaryTextColor =>
      Theme.of(context).colorScheme.onSurfaceVariant;


  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _userName = widget.userName;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1400,
      ),
    );

    _animationController.forward();

    ThemeService.themeMode.addListener(_temaMudou);

    _carregarNome();

    _carregarRovers();

    _carregarTalhoes();
  }


  // ============================================================
  // CARREGAR NOME
  // ============================================================

  Future<void> _carregarNome() async {
    final nome = await UserStorage.getNome();

    if (!mounted) return;

    setState(() {
      if (nome.trim().isNotEmpty) {
        _userName = nome;
      }
    });
  }


  // ============================================================
  // TEMA
  // ============================================================

  void _temaMudou() {
    if (!mounted) return;

    setState(() {});
  }


  // ============================================================
  // CARREGAR ROVERS
  // ============================================================

  Future<void> _carregarRovers() async {
    try {
      final rovers = await RoverStorage.getRovers();

      if (!mounted) return;

      setState(() {
        _roversCadastrados.clear();

        _roversCadastrados.addAll(
          rovers,
        );

        _carregandoRovers = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoRovers = false;
      });
    }
  }


  // ============================================================
  // CARREGAR TALHÕES
  // ============================================================

  Future<void> _carregarTalhoes() async {
    try {
      final talhoes = await TalhaoStorage.getTalhoes();

      if (!mounted) return;

      setState(() {
        _talhoesCadastrados.clear();

        _talhoesCadastrados.addAll(
          talhoes,
        );

        _carregandoTalhoes = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoTalhoes = false;
      });
    }
  }


  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    ThemeService.themeMode.removeListener(_temaMudou);

    _animationController.dispose();

    super.dispose();
  }


  // ============================================================
  // TROCAR PÁGINA
  // ============================================================

  void _changePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,

          children: [
            _buildDashboard(),

            _buildRoversPage(),

            _buildTalhoesPage(),

            _buildProfilePage(),
          ],
        ),
      ),

      bottomNavigationBar:
          _buildBottomNavigation(),
    );
  }


  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _buildDashboard() {
    final totalRovers = _roversCadastrados.length;
    final totalTalhoes = _talhoesCadastrados.length;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _animatedItem(0, _buildHeader()),
              const SizedBox(height: 24),
              _animatedItem(1, _buildSearchBar()),
              const SizedBox(height: 28),

              _animatedItem(
                2,
                _buildSectionTitle(
                  'Visão geral',
                  'Acompanhe o que já está cadastrado na sua operação',
                ),
              ),
              const SizedBox(height: 14),
              _animatedItem(
                3,
                _buildOverviewCards(
                  totalRovers: totalRovers,
                  totalTalhoes: totalTalhoes,
                ),
              ),
              const SizedBox(height: 30),

              _animatedItem(
                4,
                _buildSectionTitle(
                  'Monitoramento do solo',
                  'Os dados reais aparecerão quando o rover estiver conectado',
                ),
              ),
              const SizedBox(height: 14),
              _animatedItem(5, _buildSoilMonitoringCard()),
              const SizedBox(height: 30),

              _animatedItem(
                6,
                _buildSectionTitle(
                  'Seus Rovers',
                  'Equipamentos cadastrados no aplicativo',
                ),
              ),
              const SizedBox(height: 14),
              _animatedItem(7, _buildRoverDashboardCard()),
              const SizedBox(height: 30),

              _animatedItem(
                8,
                _buildSectionTitle(
                  'Seus Talhões',
                  'Áreas cadastradas para monitoramento',
                ),
              ),
              const SizedBox(height: 14),
              _animatedItem(9, _buildTalhaoDashboardCard()),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards({
    required int totalRovers,
    required int totalTalhoes,
  }) {
    return Row(
      children: [
        Expanded(
          child: _DashboardInfoCard(
            icon: Icons.smart_toy_outlined,
            title: 'Rovers',
            value: totalRovers.toString(),
            detail: totalRovers == 1
                ? 'cadastrado'
                : 'cadastrados',
            iconBackground: lightGreen,
            iconColor: darkGreen,
            onTap: () => _changePage(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DashboardInfoCard(
            icon: Icons.grass_outlined,
            title: 'Talhões',
            value: totalTalhoes.toString(),
            detail: totalTalhoes == 1
                ? 'cadastrado'
                : 'cadastrados',
            iconBackground: const Color(0xFFF0F7EA),
            iconColor: const Color(0xFF4C8C3A),
            onTap: () => _changePage(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSoilMonitoringCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FA),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: Color(0xFF238BA7),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Umidade do solo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Aguardando dados',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Conecte um rover para começar a receber informações do solo.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoverDashboardCard() {
    if (_carregandoRovers) {
      return _buildLoadingDashboardCard();
    }

    if (_roversCadastrados.isEmpty) {
      return _buildEmptyDashboardCard(
        icon: Icons.smart_toy_outlined,
        title: 'Nenhum rover cadastrado',
        message: 'Cadastre um rover para preparar o monitoramento da operação.',
        buttonText: 'Cadastrar Rover',
        onPressed: () => _changePage(1),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          ..._roversCadastrados.take(3).map(
            (rover) {
              final nome = rover['nome'] ?? 'Rover';
              final codigo = rover['codigo'] ?? 'Sem código';
              final talhao = rover['talhao'] ?? 'Sem talhão';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.smart_toy_rounded,
                        color: darkGreen,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$codigo • Talhão: $talhao',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Sem dados',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_roversCadastrados.length > 3)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _changePage(1),
                child: Text(
                  'Ver todos os rovers',
                  style: TextStyle(
                    color: green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTalhaoDashboardCard() {
    if (_carregandoTalhoes) {
      return _buildLoadingDashboardCard();
    }

    if (_talhoesCadastrados.isEmpty) {
      return _buildEmptyDashboardCard(
        icon: Icons.landscape_outlined,
        title: 'Nenhum talhão cadastrado',
        message: 'Cadastre um talhão para organizar as áreas da sua operação.',
        buttonText: 'Cadastrar Talhão',
        onPressed: () => _changePage(2),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          ..._talhoesCadastrados.take(3).map(
            (talhao) {
              final nome = talhao['nome'] ?? 'Talhão';
              final codigo = talhao['codigo'] ?? 'Sem código';
              final area = talhao['area'] ?? 'Área não informada';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7EA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.grass_rounded,
                        color: Color(0xFF4C8C3A),
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$codigo • $area',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_talhoesCadastrados.length > 3)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _changePage(2),
                child: Text(
                  'Ver todos os talhões',
                  style: TextStyle(
                    color: green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingDashboardCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildEmptyDashboardCard({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: darkGreen,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 14),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: green,
                side: BorderSide(color: green.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }



  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Text(
                    'Olá, ',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          secondaryTextColor,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                  Flexible(
                    child: Text(
                      _userName,
                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  const Text(
                    '👋',
                    style:
                        TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 7,
              ),

              Text(
                'AgroTech',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.1,
                  fontWeight:
                      FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                'Tudo sob controle na sua operação.',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      secondaryTextColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        _Pressable(
          onTap: _abrirNotificacoes,

          child: Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: surface,

              borderRadius:
                  BorderRadius.circular(
                16,
              ),

              border: Border.all(
                color:
                    Theme.of(context)
                        .dividerColor
                        .withOpacity(0.5),
              ),
            ),

            child: Icon(
              Icons
                  .notifications_none_rounded,
              color: textColor,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }


  // ============================================================
  // BARRA DE PESQUISA
  // ============================================================

  Widget _buildSearchBar() {
    return Container(
      height: 52,

      decoration: BoxDecoration(
        color: surface,

        borderRadius:
            BorderRadius.circular(
          17,
        ),

        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withOpacity(0.5),
        ),
      ),

      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },

        style: TextStyle(
          color: textColor,
        ),

        decoration:
            InputDecoration(
          hintText:
              'Pesquisar Rover ou Talhão...',

          hintStyle: TextStyle(
            color:
                secondaryTextColor,
            fontSize: 13,
          ),

          prefixIcon: Icon(
            Icons.search_rounded,
            color:
                secondaryTextColor,
          ),

          suffixIcon:
              _searchText.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchText = '';
                        });
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color:
                            secondaryTextColor,
                      ),
                    )
                  : null,

          border:
              InputBorder.none,

          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 15,
          ),
        ),
      ),
    );
  }


  // ============================================================
  // TÍTULO DE SEÇÃO
  // ============================================================

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: TextStyle(
            fontSize: 19,
            fontWeight:
                FontWeight.w800,
            color: textColor,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          subtitle,

          style: TextStyle(
            fontSize: 12.5,
            color:
                secondaryTextColor,
          ),
        ),
      ],
    );
  }


  // ============================================================
  // DESTAQUES
  // ============================================================

  Widget _buildHighlights() {
    return const SizedBox.shrink();
  }



  // ============================================================
  // ESTATÍSTICAS
  // ============================================================

  Widget _buildStatisticsGrid() {
    return const SizedBox.shrink();
  }



  // ============================================================
  // ATIVIDADE RECENTE
  // ============================================================

  Widget _buildActivityList() {
    return const SizedBox.shrink();
  }



  // ============================================================
  // ROVERS
  // ============================================================

  Widget _buildRoversPage() {
    final pesquisa =
        _searchText.toLowerCase();

    final roversFiltrados =
        _roversCadastrados.where(
      (rover) {
        if (pesquisa.isEmpty) {
          return true;
        }

        final nome =
            (rover['nome'] ?? '')
                .toLowerCase();

        final codigo =
            (rover['codigo'] ?? '')
                .toLowerCase();

        final talhao =
            (rover['talhao'] ?? '')
                .toLowerCase();

        return nome.contains(pesquisa) ||
            codigo.contains(pesquisa) ||
            talhao.contains(pesquisa);
      },
    ).toList();

    return _SimplePage(
      title:
          'Meus Rovers',

      subtitle:
          'Acompanhe seus equipamentos',

      icon:
          Icons.smart_toy_rounded,

      child: Column(
        children: [
          Align(
            alignment:
                Alignment.centerRight,

            child: MouseRegion(
              cursor:
                  SystemMouseCursors.click,

              child:
                  ElevatedButton.icon(
                onPressed: () async {
                  final resultado =
                      await Navigator.push<
                          Map<String, String>>(
                    context,

                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const CadastroRoverScreen(),
                    ),
                  );

                  if (resultado != null) {
                    try {
                      await RoverStorage
                          .saveRover(
                        resultado,
                      );
                    } catch (e) {
                      if (!mounted) return;

                      _showMessage(
                        'Erro',
                        'Não foi possível salvar o Rover localmente.',
                      );

                      return;
                    }

                    if (!mounted) return;

                    setState(() {
                      _roversCadastrados.add(
                        resultado,
                      );
                    });

                    _showMessage(
                      'Rover cadastrado',
                      '${resultado['nome']} foi adicionado com sucesso!',
                    );
                  }
                },

                icon:
                    const Icon(
                  Icons.add_rounded,
                  size: 20,
                ),

                label:
                    const Text(
                  'Criar Rover',
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      green,

                  foregroundColor:
                      Colors.white,

                  elevation: 0,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
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
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          if (_carregandoRovers)
            const Padding(
              padding:
                  EdgeInsets.all(30),

              child:
                  CircularProgressIndicator(
                color:
                    ThemeService.primaryColor,
              ),
            )

          else if (roversFiltrados.isNotEmpty) ...[
            Align(
              alignment:
                  Alignment.centerLeft,

              child: Text(
                'Rovers cadastrados',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            ...roversFiltrados.map(
              (rover) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child:
                      _LargeStatusCard(
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

                    color:
                        green,
                  ),
                );
              },
            ),
          ]

          else
            _buildEmptyCard(
              icon:
                  Icons.smart_toy_outlined,

              title:
                  'Nenhum rover cadastrado',

              message:
                  'Clique em "Criar Rover" para adicionar um.',
            ),
        ],
      ),
    );
  }


  // ============================================================
  // TALHÕES
  // ============================================================

  Widget _buildTalhoesPage() {
    final pesquisa =
        _searchText.toLowerCase();

    final talhoesFiltrados =
        _talhoesCadastrados.where(
      (talhao) {
        if (pesquisa.isEmpty) {
          return true;
        }

        final nome =
            (talhao['nome'] ?? '')
                .toLowerCase();

        final codigo =
            (talhao['codigo'] ?? '')
                .toLowerCase();

        final area =
            (talhao['area'] ?? '')
                .toLowerCase();

        return nome.contains(pesquisa) ||
            codigo.contains(pesquisa) ||
            area.contains(pesquisa);
      },
    ).toList();

    return _SimplePage(
      title:
          'Talhões',

      subtitle:
          'Monitoramento da plantação',

      icon:
          Icons.grass_rounded,

      child: Column(
        children: [
          Align(
            alignment:
                Alignment.centerRight,

            child: MouseRegion(
              cursor:
                  SystemMouseCursors.click,

              child:
                  ElevatedButton.icon(
                onPressed: () async {
                  final resultado =
                      await Navigator.push<
                          Map<String, String>>(
                    context,

                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const CadastroTalhaoScreen(),
                    ),
                  );

                  if (resultado != null) {
                    try {
                      await TalhaoStorage
                          .saveTalhao(
                        resultado,
                      );
                    } catch (e) {
                      if (!mounted) return;

                      _showMessage(
                        'Erro',
                        'Não foi possível salvar o Talhão localmente.',
                      );

                      return;
                    }

                    if (!mounted) return;

                    setState(() {
                      _talhoesCadastrados.add(
                        resultado,
                      );
                    });

                    _showMessage(
                      'Talhão cadastrado',
                      '${resultado['nome']} foi adicionado com sucesso!',
                    );
                  }
                },

                icon:
                    const Icon(
                  Icons.add_rounded,
                  size: 20,
                ),

                label:
                    const Text(
                  'Criar Talhão',

                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      green,

                  foregroundColor:
                      Colors.white,

                  elevation: 0,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
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
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          if (_carregandoTalhoes)
            const Padding(
              padding:
                  EdgeInsets.all(30),

              child:
                  CircularProgressIndicator(
                color:
                    ThemeService.primaryColor,
              ),
            )

          else if (talhoesFiltrados.isNotEmpty) ...[
            Align(
              alignment:
                  Alignment.centerLeft,

              child: Text(
                'Talhões cadastrados',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            ...talhoesFiltrados.map(
              (talhao) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child:
                      _CustomTalhaoCard(
                    nome:
                        talhao['nome'] ??
                            'Talhão',

                    codigo:
                        talhao['codigo'] ??
                            'Sem código',

                    area:
                        talhao['area'] ??
                            'Área não informada',

                    color:
                        green,
                  ),
                );
              },
            ),
          ]

          else
            _buildEmptyCard(
              icon:
                  Icons.landscape_outlined,

              title:
                  'Nenhum talhão cadastrado',

              message:
                  'Clique em "Criar Talhão" para adicionar um.',
            ),
        ],
      ),
    );
  }


  // ============================================================
  // PERFIL
  // ============================================================

  Widget _buildProfilePage() {
    return _SimplePage(
      title:
          'Meu perfil',

      subtitle:
          'Configurações da conta',

      icon:
          Icons.person_rounded,

      child: Column(
        children: [
          Container(
            width:
                double.infinity,

            padding:
                const EdgeInsets.all(
              24,
            ),

            decoration:
                BoxDecoration(
              color:
                  surface,

              borderRadius:
                  BorderRadius.circular(
                24,
              ),

              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withOpacity(
                    0.04,
                  ),

                  blurRadius:
                      18,

                  offset:
                      const Offset(
                    0,
                    7,
                  ),
                ),
              ],
            ),

            child: Column(
              children: [
                Container(
                  width: 78,
                  height: 78,

                  decoration:
                      BoxDecoration(
                    color:
                        lightGreen,

                    shape:
                        BoxShape.circle,
                  ),

                  child:
                      Icon(
                    Icons.person_rounded,
                    size: 40,
                    color:
                        darkGreen,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                Text(
                  _userName,

                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                    color: textColor,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'Integrante AgroTech',

                  style: TextStyle(
                    color:
                        secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          _ProfileOption(
            icon:
                Icons.settings_outlined,

            title:
                'Configurações',

            onTap:
                _abrirConfiguracoes,
          ),

          _ProfileOption(
            icon:
                Icons.notifications_none_rounded,

            title:
                'Notificações',

            onTap:
                _abrirNotificacoes,
          ),

          _ProfileOption(
            icon:
                Icons.help_outline_rounded,

            title:
                'Ajuda',

            onTap:
                _abrirAjuda,
          ),
        ],
      ),
    );
  }


  // ============================================================
  // CARD VAZIO
  // ============================================================

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        24,
      ),

      decoration:
          BoxDecoration(
        color:
            surface,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border: Border.all(
          color:
              Theme.of(context)
                  .dividerColor
                  .withOpacity(0.5),
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,

            size: 45,

            color:
                green,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            title,

            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
              color: textColor,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            message,

            textAlign:
                TextAlign.center,

            style: TextStyle(
              color:
                  secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }


  // ============================================================
  // NOTIFICAÇÕES
  // ============================================================

  void _abrirNotificacoes() {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (context) =>
                const NotificacoesPage(),
      ),
    );
  }


  // ============================================================
  // CONFIGURAÇÕES
  // ============================================================

  Future<void> _abrirConfiguracoes() async {
    final resultado =
        await Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (context) =>
                ConfiguracoesPage(
          userName:
              _userName,
        ),
      ),
    );

    if (resultado is String &&
        resultado.trim().isNotEmpty &&
        mounted) {
      setState(() {
        _userName =
            resultado.trim();
      });
    }

    await _carregarNome();
  }


  // ============================================================
  // AJUDA
  // ============================================================

  void _abrirAjuda() {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (context) =>
                const AjudaPage(),
      ),
    );
  }


  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    final items = [
      (
        Icons.home_rounded,
        'Início',
      ),

      (
        Icons.smart_toy_rounded,
        'Rovers',
      ),

      (
        Icons.grass_rounded,
        'Talhões',
      ),

      (
        Icons.person_rounded,
        'Perfil',
      ),
    ];

    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          14,
        ),

        child: Container(
          height: 68,

          decoration:
              BoxDecoration(
            color:
                Colors.black,

            borderRadius:
                BorderRadius.circular(
              25,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.18,
                ),

                blurRadius:
                    25,

                offset:
                    const Offset(
                  0,
                  10,
                ),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceAround,

            children:
                items.asMap().entries.map(
              (entry) {
                final index =
                    entry.key;

                final item =
                    entry.value;

                final selected =
                    _selectedIndex ==
                        index;

                return MouseRegion(
                  cursor:
                      SystemMouseCursors.click,

                  child:
                      GestureDetector(
                    onTap: () =>
                        _changePage(
                      index,
                    ),

                    child:
                        AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 250,
                      ),

                      curve:
                          Curves.easeOut,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 9,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            selected
                                ? green
                                : Colors.transparent,

                        borderRadius:
                            BorderRadius.circular(
                          17,
                        ),
                      ),

                      child: Row(
                        children: [
                          Icon(
                            item.$1,

                            color:
                                selected
                                    ? Colors.black
                                    : Colors.white70,

                            size: 21,
                          ),

                          AnimatedSize(
                            duration:
                                const Duration(
                              milliseconds:
                                  250,
                            ),

                            child:
                                selected
                                    ? Row(
                                        children: [
                                          const SizedBox(
                                            width: 7,
                                          ),

                                          Text(
                                            item.$2,

                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.black,
                                              fontWeight:
                                                  FontWeight.w700,
                                              fontSize:
                                                  12,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }


  // ============================================================
  // ANIMAÇÃO
  // ============================================================

  Widget _animatedItem(
    int index,
    Widget child,
  ) {
    final begin =
        math.min(
      index * 0.08,
      0.65,
    );

    final end =
        math.min(
      begin + 0.35,
      1.0,
    );

    final animation =
        CurvedAnimation(
      parent:
          _animationController,

      curve:
          Interval(
        begin,
        end,

        curve:
            Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation:
          animation,

      builder:
          (context, child) {
        return Opacity(
          opacity:
              animation.value,

          child:
              Transform.translate(
            offset:
                Offset(
              0,
              30 *
                  (1 -
                      animation.value),
            ),

            child:
                child,
          ),
        );
      },

      child:
          child,
    );
  }


  // ============================================================
  // MENSAGEM
  // ============================================================

  void _showMessage(
    String title,
    String message,
  ) {
    showDialog(
      context:
          context,

      builder:
          (context) {
        return AlertDialog(
          title:
              Text(title),

          content:
              Text(message),

          actions: [
            TextButton(
              onPressed:
                  () =>
                      Navigator.pop(
                context,
              ),

              child:
                  Text(
                'Fechar',

                style:
                    TextStyle(
                  color:
                      green,
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
}


// ================================================================
// HIGHLIGHT CARD
// ================================================================

class _HighlightCard
    extends StatelessWidget {

  final double width;

  final String title;

  final String subtitle;

  final String value;

  final String description;

  final IconData icon;

  final Color color;

  final Color lightColor;

  final VoidCallback onTap;


  const _HighlightCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.onTap,
  });


  @override
  Widget build(
    BuildContext context,
  ) {
    return _Pressable(
      onTap:
          onTap,

      child:
          Container(
        width:
            width,

        padding:
            const EdgeInsets.all(
          20,
        ),

        decoration:
            BoxDecoration(
          color:
              color,

          borderRadius:
              BorderRadius.circular(
            24,
          ),

          boxShadow: [
            BoxShadow(
              color:
                  color.withOpacity(
                0.16,
              ),

              blurRadius:
                  18,

              offset:
                  const Offset(
                0,
                8,
              ),
            ),
          ],
        ),

        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  width:
                      43,

                  height:
                      43,

                  decoration:
                      BoxDecoration(
                    color:
                        lightColor,

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),

                  child:
                      Icon(
                    icon,

                    color:
                        color,

                    size:
                        22,
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons
                      .arrow_outward_rounded,

                  color:
                      Colors.white
                          .withOpacity(
                    0.75,
                  ),

                  size:
                      19,
                ),
              ],
            ),

            const Spacer(),

            Text(
              subtitle,

              style:
                  TextStyle(
                color:
                    Colors.white
                        .withOpacity(
                  0.78,
                ),

                fontSize:
                    12,
              ),
            ),

            const SizedBox(
              height:
                  2,
            ),

            Text(
              title,

              style:
                  const TextStyle(
                color:
                    Colors.white,

                fontSize:
                    15,

                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height:
                  10,
            ),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,

              children: [
                Text(
                  value,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize:
                        27,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  width:
                      8,
                ),

                Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom:
                        4,
                  ),

                  child:
                      Text(
                    description,

                    style:
                        TextStyle(
                      color:
                          Colors.white
                              .withOpacity(
                        0.75,
                      ),

                      fontSize:
                          10,
                    ),
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


// ================================================================
// STAT CARD
// ================================================================

class _StatCard
    extends StatelessWidget {

  final String title;

  final String value;

  final String detail;

  final IconData icon;

  final Color iconBackground;

  final Color iconColor;

  final VoidCallback onTap;


  const _StatCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.onTap,
  });


  @override
  Widget build(
    BuildContext context,
  ) {
    final textColor =
        Theme.of(context)
            .colorScheme
            .onSurface;

    final secondary =
        Theme.of(context)
            .colorScheme
            .onSurfaceVariant;

    final surface =
        Theme.of(context)
            .colorScheme
            .surface;

    return _Pressable(
      onTap:
          onTap,

      child:
          Container(
        padding:
            const EdgeInsets.all(
          16,
        ),

        decoration:
            BoxDecoration(
          color:
              surface,

          borderRadius:
              BorderRadius.circular(
            22,
          ),

          border:
              Border.all(
            color:
                Theme.of(context)
                    .dividerColor
                    .withOpacity(0.5),
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.025,
              ),

              blurRadius:
                  15,

              offset:
                  const Offset(
                0,
                6,
              ),
            ),
          ],
        ),

        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  width:
                      38,

                  height:
                      38,

                  decoration:
                      BoxDecoration(
                    color:
                        iconBackground,

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  child:
                      Icon(
                    icon,

                    color:
                        iconColor,

                    size:
                        20,
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons
                      .more_horiz_rounded,

                  color:
                      secondary.withOpacity(
                    0.6,
                  ),
                ),
              ],
            ),

            const Spacer(),

            Text(
              title,

              style:
                  TextStyle(
                color:
                    secondary,

                fontSize:
                    12,
              ),
            ),

            const SizedBox(
              height:
                  2,
            ),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,

              children: [
                Text(
                  value,

                  style:
                      TextStyle(
                    fontSize:
                        21,

                    fontWeight:
                        FontWeight.w900,

                    color:
                        textColor,
                  ),
                ),

                const SizedBox(
                  width:
                      7,
                ),

                Flexible(
                  child:
                      Text(
                    detail,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        TextStyle(
                      fontSize:
                          9,

                      color:
                          secondary,
                    ),
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


// ================================================================
// ACTIVITY DATA
// ================================================================

class _ActivityData {

  final String title;

  final String subtitle;

  final String time;

  final IconData icon;

  final Color color;


  const _ActivityData({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}


// ================================================================
// ACTIVITY CARD
// ================================================================

class _ActivityCard
    extends StatelessWidget {

  final _ActivityData data;

  final VoidCallback onTap;


  const _ActivityCard({
    required this.data,
    required this.onTap,
  });


  @override
  Widget build(
    BuildContext context,
  ) {
    final surface =
        Theme.of(context)
            .colorScheme
            .surface;

    final textColor =
        Theme.of(context)
            .colorScheme
            .onSurface;

    final secondary =
        Theme.of(context)
            .colorScheme
            .onSurfaceVariant;

    return _Pressable(
      onTap:
          onTap,

      child:
          Container(
        padding:
            const EdgeInsets.all(
          14,
        ),

        decoration:
            BoxDecoration(
          color:
              surface,

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          border:
              Border.all(
            color:
                Theme.of(context)
                    .dividerColor
                    .withOpacity(0.5),
          ),
        ),

        child:
            Row(
          children: [
            Container(
              width:
                  46,

              height:
                  46,

              decoration:
                  BoxDecoration(
                color:
                    data.color
                        .withOpacity(
                  0.10,
                ),

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),

              child:
                  Icon(
                data.icon,

                color:
                    data.color,
              ),
            ),

            const SizedBox(
              width:
                  13,
            ),

            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    data.title,

                    style:
                        TextStyle(
                      fontSize:
                          14,

                      fontWeight:
                          FontWeight.w800,

                      color:
                          textColor,
                    ),
                  ),

                  const SizedBox(
                    height:
                        4,
                  ),

                  Text(
                    data.subtitle,

                    style:
                        TextStyle(
                      fontSize:
                          11.5,

                      color:
                          secondary,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              data.time,

              style:
                  TextStyle(
                fontSize:
                    10,

                color:
                    secondary,

                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ================================================================
// LARGE STATUS CARD
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
  Widget build(
    BuildContext context,
  ) {
    final surface =
        Theme.of(context)
            .colorScheme
            .surface;

    final textColor =
        Theme.of(context)
            .colorScheme
            .onSurface;

    final secondary =
        Theme.of(context)
            .colorScheme
            .onSurfaceVariant;

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(
        color:
            surface,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border:
            Border.all(
          color:
              Theme.of(context)
                  .dividerColor
                  .withOpacity(0.5),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.025,
            ),

            blurRadius:
                15,

            offset:
                const Offset(
              0,
              6,
            ),
          ),
        ],
      ),

      child:
          Row(
        children: [
          Container(
            width:
                55,

            height:
                55,

            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(
                0.10,
              ),

              borderRadius:
                  BorderRadius.circular(
                17,
              ),
            ),

            child:
                Icon(
              icon,

              color:
                  color,

              size:
                  28,
            ),
          ),

          const SizedBox(
            width:
                14,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  name,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      TextStyle(
                    fontSize:
                        16,

                    fontWeight:
                        FontWeight.w800,

                    color:
                        textColor,
                  ),
                ),

                const SizedBox(
                  height:
                      5,
                ),

                Row(
                  children: [
                    Container(
                      width:
                          8,

                      height:
                          8,

                      decoration:
                          BoxDecoration(
                        color:
                            status
                                    .toLowerCase()
                                    .contains(
                                      'online',
                                    )
                                ? Colors.green
                                : Colors.orange,

                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(
                      width:
                          6,
                    ),

                    Text(
                      status,

                      style:
                          TextStyle(
                        color:
                            secondary,

                        fontSize:
                            12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height:
                      7,
                ),

                Text(
                  'Talhão: $location',

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      TextStyle(
                    color:
                        secondary,

                    fontSize:
                        11,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [
              Icon(
                Icons
                    .battery_full_rounded,

                color:
                    color,

                size:
                    20,
              ),

              const SizedBox(
                height:
                    4,
              ),

              Text(
                battery,

                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.w800,

                  fontSize:
                      12,

                  color:
                      textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// ================================================================
// CUSTOM TALHÃO CARD
// ================================================================

class _CustomTalhaoCard
    extends StatelessWidget {

  final String nome;

  final String codigo;

  final String area;

  final Color color;


  const _CustomTalhaoCard({
    required this.nome,
    required this.codigo,
    required this.area,
    required this.color,
  });


  @override
  Widget build(
    BuildContext context,
  ) {
    final surface =
        Theme.of(context)
            .colorScheme
            .surface;

    final textColor =
        Theme.of(context)
            .colorScheme
            .onSurface;

    final secondary =
        Theme.of(context)
            .colorScheme
            .onSurfaceVariant;

    return _Pressable(
      onTap: () {
        _mostrarDetalhesTalhao(
          context,
        );
      },

      child:
          Container(
        width:
            double.infinity,

        padding:
            const EdgeInsets.all(
          18,
        ),

        decoration:
            BoxDecoration(
          color:
              surface,

          borderRadius:
              BorderRadius.circular(
            22,
          ),

          border:
              Border.all(
            color:
                Theme.of(context)
                    .dividerColor
                    .withOpacity(0.5),
          ),
        ),

        child:
            Row(
          children: [
            Container(
              width:
                  55,

              height:
                  55,

              decoration:
                  BoxDecoration(
                color:
                    color.withOpacity(
                  0.10,
                ),

                borderRadius:
                    BorderRadius.circular(
                  17,
                ),
              ),

              child:
                  Icon(
                Icons
                    .landscape_rounded,

                color:
                    color,

                size:
                    28,
              ),
            ),

            const SizedBox(
              width:
                  14,
            ),

            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    nome,

                    overflow:
                        TextOverflow.ellipsis,

                    style:
                        TextStyle(
                      fontSize:
                          16,

                      fontWeight:
                          FontWeight.w800,

                      color:
                          textColor,
                    ),
                  ),

                  const SizedBox(
                    height:
                        5,
                  ),

                  Text(
                    'Código: $codigo',

                    style:
                        TextStyle(
                      fontSize:
                          12,

                      color:
                          secondary,
                    ),
                  ),

                  const SizedBox(
                    height:
                        4,
                  ),

                  Text(
                    area,

                    style:
                        TextStyle(
                      fontSize:
                          12,

                      color:
                          color,

                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    10,

                vertical:
                    6,
              ),

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFE7F8EF,
                ),

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child:
                  const Text(
                'Ativo',

                style:
                    TextStyle(
                  color:
                      Color(
                    0xFF087443,
                  ),

                  fontSize:
                      11,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _mostrarDetalhesTalhao(
    BuildContext context,
  ) {
    showDialog(
      context:
          context,

      builder:
          (context) {
        return AlertDialog(
          title:
              Text(nome),

          content:
              Text(
            'Código: $codigo\n'
            'Área: $area\n\n'
            'Status: Ativo',
          ),

          actions: [
            TextButton(
              onPressed:
                  () =>
                      Navigator.pop(
                context,
              ),

              child:
                  const Text(
                'Fechar',
              ),
            ),
          ],
        );
      },
    );
  }
}


// ================================================================
// SIMPLE PAGE
// ================================================================

class _SimplePage
    extends StatelessWidget {

  final String title;

  final String subtitle;

  final IconData icon;

  final Widget child;


  const _SimplePage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });


  @override
  Widget build(
    BuildContext context,
  ) {
    final textColor =
        Theme.of(context)
            .colorScheme
            .onSurface;

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

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width:
                    52,

                height:
                    52,

                decoration:
                    BoxDecoration(
                  color:
                      ThemeService
                          .lightPrimaryColor,

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),

                child:
                    Icon(
                  icon,

                  color:
                      ThemeService
                          .darkPrimaryColor,
                ),
              ),

              const SizedBox(
                width:
                    14,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style:
                          TextStyle(
                        fontSize:
                            27,

                        fontWeight:
                            FontWeight.w900,

                        color:
                            textColor,
                      ),
                    ),

                    const SizedBox(
                      height:
                          3,
                    ),

                    Text(
                      subtitle,

                      style:
                          TextStyle(
                        fontSize:
                            12.5,

                        color:
                            Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
           

            const SizedBox(
            height:
                25,
          ),
          

          child,
        ],
      ),
    );
  }
}


// ================================================================
// PROFILE OPTION
// ================================================================

class _ProfileOption
    extends StatelessWidget {

  final IconData icon;

  final String title;

  final VoidCallback onTap;


  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });


  @override
  Widget build(
    BuildContext context,
  ) {
    final textColor =
        Theme.of(context)
            .colorScheme
            .onSurface;

    final surface =
        Theme.of(context)
            .colorScheme
            .surface;

    final secondary =
        Theme.of(context)
            .colorScheme
            .onSurfaceVariant;

    return _Pressable(
      onTap:
          onTap,

      child:
          Container(
        margin:
            const EdgeInsets.only(
          bottom:
              10,
        ),

        padding:
            const EdgeInsets.all(
          16,
        ),

        decoration:
            BoxDecoration(
          color:
              surface,

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          border:
              Border.all(
            color:
                Theme.of(context)
                    .dividerColor
                    .withOpacity(0.5),
          ),
        ),

        child:
            Row(
          children: [
            Icon(
              icon,

              color:
                  textColor,
            ),

            const SizedBox(
              width:
                  14,
            ),

            Expanded(
              child:
                  Text(
                title,

                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.w700,

                  color:
                      textColor,
                ),
              ),
            ),

            Icon(
              Icons
                  .chevron_right_rounded,

              color:
                  secondary,
            ),
          ],
        ),
      ),
    );
  }
}


// ================================================================
// PRESSABLE
// ================================================================

class _Pressable
    extends StatefulWidget {

  final Widget child;

  final VoidCallback onTap;


  const _Pressable({
    required this.child,
    required this.onTap,
  });


  @override
  State<_Pressable> createState() =>
      _PressableState();
}


class _PressableState
    extends State<_Pressable> {

  bool _pressed = false;


  @override
  Widget build(
    BuildContext context,
  ) {
    return MouseRegion(
      cursor:
          SystemMouseCursors.click,

      child:
          GestureDetector(
        onTapDown: (_) {
          setState(() {
            _pressed = true;
          });
        },

        onTapUp: (_) {
          setState(() {
            _pressed = false;
          });
        },

        onTapCancel: () {
          setState(() {
            _pressed = false;
          });
        },

        onTap:
            widget.onTap,

        child:
            AnimatedScale(
          scale:
              _pressed
                  ? 0.97
                  : 1.0,

          duration:
              const Duration(
            milliseconds:
                120,
          ),

          curve:
              Curves.easeOut,

          child:
              widget.child,
        ),
      ),
    );
  }
}
class _DashboardInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback? onTap;

  const _DashboardInfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.iconBackground,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              detail,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}