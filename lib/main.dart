import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/documentos_viewmodel.dart';
import 'views/cadastro_view.dart';
import 'views/editor_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lê o tema salvo e restaura a sessão antes de abrir o app
  final auth = AuthViewModel();
  await auth.iniciar();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: auth),
        ChangeNotifierProvider<DocumentosViewModel>(
          create: (_) => DocumentosViewModel(),
        ),
      ],
      // Se já existe sessão salva, abre direto na Home
      child: MeuApp(
        rotaInicial: auth.usuarioLogado != null ? '/home' : '/',
      ),
    ),
  );
}

class MeuApp extends StatelessWidget {
  final String rotaInicial;
  const MeuApp({super.key, this.rotaInicial = '/'});

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
      initialRoute: rotaInicial,
      routes: {
        '/': (context) => const LoginView(),
        '/cadastro': (context) => const CadastroView(),
        '/home': (context) => const HomeView(),
        '/editor': (context) => const EditorView(),
      },
    );
  }
}
