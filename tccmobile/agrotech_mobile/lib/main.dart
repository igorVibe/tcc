import 'package:flutter/material.dart';

import 'pages/login/app_start_page.dart';
import 'services/theme_service.dart';
import 'services/user_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ThemeService.carregarTema();

  await UserStorage.carregarNome();

  runApp(
    const AgroTechApp(),
  );
}

class AgroTechApp extends StatelessWidget {
  const AgroTechApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable:
          ThemeService.themeMode,

      builder:
          (context, modo, child) {
        return MaterialApp(
          debugShowCheckedModeBanner:
              false,

          title:
              'AgroTech',

          themeMode:
              modo,

          theme:
              ThemeData(
            useMaterial3:
                true,

            brightness:
                Brightness.light,

            colorScheme:
                ColorScheme.fromSeed(
              seedColor:
                  ThemeService.primaryColor,

              brightness:
                  Brightness.light,
            ),

            scaffoldBackgroundColor:
                const Color(
              0xFFF7F9F7,
            ),
          ),

          darkTheme:
              ThemeData(
            useMaterial3:
                true,

            brightness:
                Brightness.dark,

            colorScheme:
                ColorScheme.fromSeed(
              seedColor:
                  ThemeService.primaryColor,

              brightness:
                  Brightness.dark,
            ),

            scaffoldBackgroundColor:
                const Color(
              0xFF101412,
            ),
          ),

          home:
              const AppStartPage(),
        );
      },
    );
  }
}