import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/componentes.dart';
import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';

// TELA DE CADASTRO (rota: /cadastro)
class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthViewModel>().iniciarCadastro();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    // Gatilho: valida todos os campos do Form
    if (!_formKey.currentState!.validate()) return;

    final ok = await context.read<AuthViewModel>().cadastrar(
          nome: _nomeController.text,
          email: _emailController.text,
          senha: _senhaController.text,
        );
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este e-mail já está cadastrado!')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final cores = Theme.of(context).colorScheme;
    final formaCartao = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );

    return Scaffold(
      appBar: barra(context, 'Criar conta'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---------- SEÇÃO 1: dados pessoais ----------
            Card(
              shape: formaCartao,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TituloSecao(Icons.badge_outlined, 'Dados pessoais'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeController,
                      decoration: decoracao(
                          context, 'Nome completo', Icons.person_outline),
                      validator: validarNome,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      decoration:
                          decoracao(context, 'E-mail', Icons.alternate_email),
                      keyboardType: TextInputType.emailAddress,
                      validator: validarEmail,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _senhaController,
                      decoration:
                          decoracao(context, 'Senha', Icons.key_outlined),
                      obscureText: true,
                      validator: validarSenha,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ---------- SEÇÃO 2: preferências ----------
            Card(
              shape: formaCartao,
              color: cores.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TituloSecao(Icons.tune, 'Suas preferências'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: vm.tema,
                      decoration: decoracao(
                          context, 'Tema do app', Icons.brightness_6_outlined),
                      items: const [
                        DropdownMenuItem(
                            value: 'Claro', child: Text('Tema Claro')),
                        DropdownMenuItem(
                            value: 'Escuro', child: Text('Tema Escuro')),
                      ],
                      onChanged: (valor) {
                        if (valor != null) vm.setTema(valor);
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Notificações ativadas'),
                      subtitle:
                          const Text('Receber avisos sobre seus documentos'),
                      secondary:
                          const Icon(Icons.notifications_active_outlined),
                      value: vm.notificacoes,
                      onChanged: vm.setNotificacoes,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: estiloBotao(context),
              onPressed: vm.salvando ? null : _cadastrar,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(vm.salvando ? 'Salvando...' : 'Cadastrar'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}