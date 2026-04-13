import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/root_shell.dart';
import 'theme/nyiha_theme.dart';

class NyihaApp extends StatelessWidget {
  const NyihaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        final dark = app.isDark;
        return MaterialApp(
          title: 'Nyiha Society',
          debugShowCheckedModeBanner: false,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          theme: buildNyihaTheme(Brightness.light),
          darkTheme: buildNyihaTheme(Brightness.dark),
          home: const RootShell(),
        );
      },
    );
  }
}
