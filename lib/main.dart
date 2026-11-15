import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'views/cadastro_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

// Ponto de entrada: registra o ViewModel e inicia o app
void main() {
  runApp(
    ChangeNotifierProvider<AuthViewModel>(
      create: (_) => AuthViewModel(),
      child: const MeuApp(),
    ),
  );
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeData reativo: reconstrói o MaterialApp quando o themeMode muda
    final modo = context.select<AuthViewModel, ThemeMode>((vm) => vm.themeMode);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aula de Persistência de Dados',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: modo,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/cadastro': (context) => const CadastroView(),
        '/home': (context) => const HomeView(),
      },
    );
  }
}