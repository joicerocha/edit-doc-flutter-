import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/componentes.dart';
import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';

// TELA DE LOGIN (rota: /)
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await context
        .read<AuthViewModel>()
        .login(_emailController.text, _senhaController.text);
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('E-mail ou senha incorretos (ou usuário não cadastrado).'),
        ),
      );
      return;
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final carregando = context.watch<AuthViewModel>().carregando;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho com degradê e cantos arredondados
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                gradient: gradiente(context),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: cores.onPrimary,
                      child: Icon(Icons.auto_stories,
                          size: 46, color: cores.primary),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'DocReader',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: cores.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Leitura e edição de documentos',
                      style: TextStyle(color: cores.onPrimary),
                    ),
                  ],
                ),
              ),
            ),

            // Cartão do formulário "sobreposto" ao cabeçalho
            Transform.translate(
              offset: const Offset(0, -36),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bem-vindo(a) de volta',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('Entre com a sua conta para continuar'),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: decoracao(
                                context, 'E-mail', Icons.alternate_email),
                            keyboardType: TextInputType.emailAddress,
                            validator: validarEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _senhaController,
                            decoration: decoracao(
                                context, 'Senha', Icons.key_outlined),
                            obscureText: true,
                            validator: validarSenha,
                          ),
                          const SizedBox(height: 22),
                          ElevatedButton(
                            style: estiloBotao(context),
                            onPressed: carregando ? null : _fazerLogin,
                            child: Text(carregando ? 'Verificando...' : 'Entrar'),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/cadastro');
                              },
                              child:
                                  const Text('Ainda não tem conta? Cadastre-se'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}