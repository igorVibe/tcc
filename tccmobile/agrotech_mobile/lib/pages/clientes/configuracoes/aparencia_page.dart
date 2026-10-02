import 'package:flutter/material.dart';

import 'package:agrotech_mobile/services/theme_service.dart';

class AparenciaPage extends StatefulWidget {
  const AparenciaPage({
    super.key,
  });

  @override
  State<AparenciaPage> createState() =>
      _AparenciaPageState();
}

class _AparenciaPageState
    extends State<AparenciaPage> {
  // ============================================================
  // CONFIGURAÇÕES
  // ============================================================

  bool animacoes = true;

  bool modoCompacto = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    ThemeService.themeMode.addListener(
      _temaMudou,
    );
  }

  // ============================================================
  // TEMA MUDOU
  // ============================================================

  void _temaMudou() {
    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    ThemeService.themeMode.removeListener(
      _temaMudou,
    );

    super.dispose();
  }

  // ============================================================
  // TEMA SELECIONADO
  // ============================================================

  int get temaSelecionado {
    switch (ThemeService.themeMode.value) {
      case ThemeMode.light:
        return 0;

      case ThemeMode.dark:
        return 1;

      case ThemeMode.system:
        return 2;
    }
  }

  // ============================================================
  // CORES DINÂMICAS
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: background,

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: Icon(
            Icons.arrow_back_rounded,

            color: textColor,
          ),
        ),

        title: Text(
          'Aparência',

          style: TextStyle(
            color: textColor,

            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: ListView(
        padding:
            const EdgeInsets.all(20),

        children: [

          // ======================================================
          // TEMA
          // ======================================================

          Text(
            'Tema',

            style: TextStyle(
              fontSize: 17,

              fontWeight:
                  FontWeight.w800,

              color: textColor,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // ======================================================
          // CLARO
          // ======================================================

          _buildThemeOption(
            index: 0,

            icon:
                Icons.light_mode_outlined,

            title:
                'Claro',

            subtitle:
                'Usar o tema claro do AgroTech',
          ),

          // ======================================================
          // ESCURO
          // ======================================================

          _buildThemeOption(
            index: 1,

            icon:
                Icons.dark_mode_outlined,

            title:
                'Escuro',

            subtitle:
                'Usar o tema escuro',
          ),

          // ======================================================
          // AUTOMÁTICO
          // ======================================================

          _buildThemeOption(
            index: 2,

            icon:
                Icons.settings_brightness_outlined,

            title:
                'Automático',

            subtitle:
                'Seguir a configuração do dispositivo',
          ),

          const SizedBox(
            height: 25,
          ),

          // ======================================================
          // INTERFACE
          // ======================================================

          Text(
            'Interface',

            style: TextStyle(
              fontSize: 17,

              fontWeight:
                  FontWeight.w800,

              color: textColor,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          // ======================================================
          // ANIMAÇÕES
          // ======================================================

          _buildSwitch(
            title:
                'Animações',

            subtitle:
                'Ativar animações e efeitos visuais',

            value:
                animacoes,

            onChanged: (value) {
              setState(() {
                animacoes = value;
              });
            },
          ),

          // ======================================================
          // MODO COMPACTO
          // ======================================================

          _buildSwitch(
            title:
                'Modo compacto',

            subtitle:
                'Usar elementos menores na interface',

            value:
                modoCompacto,

            onChanged: (value) {
              setState(() {
                modoCompacto = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OPÇÃO DE TEMA
  // ============================================================

  Widget _buildThemeOption({
    required int index,

    required IconData icon,

    required String title,

    required String subtitle,
  }) {
    final selecionado =
        temaSelecionado == index;

    return GestureDetector(
      onTap: () async {
        ThemeMode novoTema;

        // ======================================================
        // ESCOLHER TEMA
        // ======================================================

        switch (index) {
          case 0:
            novoTema =
                ThemeMode.light;

            break;

          case 1:
            novoTema =
                ThemeMode.dark;

            break;

          case 2:
            novoTema =
                ThemeMode.system;

            break;

          default:
            novoTema =
                ThemeMode.light;
        }

        // ======================================================
        // SALVAR TEMA
        // ======================================================

        await ThemeService.mudarTema(
          novoTema,
        );

        if (!mounted) return;

        // ======================================================
        // MENSAGEM
        // ======================================================

        ScaffoldMessenger.of(context)
            .hideCurrentSnackBar();

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Tema "$title" selecionado.',
            ),

            behavior:
                SnackBarBehavior.floating,

            duration:
                const Duration(
              seconds: 2,
            ),
          ),
        );
      },

      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),

        padding:
            const EdgeInsets.all(16),

        decoration:
            BoxDecoration(
          color: surface,

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          border: Border.all(
            color: selecionado
                ? green
                : Theme.of(context)
                    .colorScheme
                    .outlineVariant,

            width:
                selecionado
                    ? 1.5
                    : 1,
          ),
        ),

        child: Row(
          children: [

            // ==================================================
            // ÍCONE
            // ==================================================

            Container(
              width: 45,

              height: 45,

              decoration:
                  BoxDecoration(
                color: lightGreen,

                borderRadius:
                    BorderRadius.circular(
                  13,
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

            // ==================================================
            // TEXTOS
            // ==================================================

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

                      color:
                          textColor,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    subtitle,

                    style: TextStyle(
                      color:
                          secondaryTextColor,

                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // RADIO BUTTON
            // ==================================================

            Icon(
              selecionado
                  ? Icons
                      .radio_button_checked
                  : Icons
                      .radio_button_off,

              color: selecionado
                  ? green
                  : Theme.of(context)
                      .colorScheme
                      .outline,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SWITCH
  // ============================================================

  Widget _buildSwitch({
    required String title,

    required String subtitle,

    required bool value,

    required ValueChanged<bool>
        onChanged,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color: surface,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant,
        ),
      ),

      child: Row(
        children: [

          // ==================================================
          // TEXTOS
          // ==================================================

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

                    color:
                        textColor,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  subtitle,

                  style: TextStyle(
                    color:
                        secondaryTextColor,

                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // SWITCH
          // ==================================================

          Switch(
            value: value,

            activeColor:
                green,

            onChanged:
                onChanged,
          ),
        ],
      ),
    );
  }
}