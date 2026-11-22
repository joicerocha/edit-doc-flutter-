import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/componentes.dart';
import '../viewmodels/auth_viewmodel.dart';

// TELA HOME (rota: /home)
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // Card 1: lê as preferências e mostra num AlertDialog
  Future<void> _mostrarPreferencias(BuildContext context) async {
    final prefs = await context.read<AuthViewModel>().lerPreferencias();
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const TituloSecao(Icons.tune, 'Preferências salvas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                    child: Icon(Icons.brightness_6_outlined)),
                title: const Text('Tema do app'),
                subtitle: Text(prefs.tema ?? 'Não definido'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  child: Icon(Icons.notifications_active_outlined),
                ),
                title: const Text('Notificações'),
                subtitle: Text(
                  prefs.notificacoes == null
                      ? 'Não definido'
                      : (prefs.notificacoes! ? 'Ativadas' : 'Desativadas'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // Card 2: consulta o banco e lista os usuários num BottomSheet
  Future<void> _mostrarUsuarios(BuildContext context) async {
    final usuarios = await context.read<AuthViewModel>().listarUsuarios();
    if (!context.mounted) return;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "alça" do bottom sheet
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TituloSecao(Icons.people_alt_outlined,
                  'Usuários cadastrados (${usuarios.length})'),
              const SizedBox(height: 8),
              if (usuarios.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Nenhum usuário cadastrado.'),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: usuarios.length,
                    itemBuilder: (context, i) {
                      final u = usuarios[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text('${u.id}')),
                        title: Text(u.nome),
                        subtitle: Text(u.email),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final nomeUsuario =
        context.watch<AuthViewModel>().usuarioLogado?.nome ?? 'Usuário';
    final inicial = nomeUsuario.trim().isNotEmpty
        ? nomeUsuario.trim()[0].toUpperCase()
        : '?';
    final formaCartao = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );

    return Scaffold(
      appBar: barra(
        context,
        'Painel',
        acoes: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            tooltip: 'Alternar tema',
            onPressed: () => context.read<AuthViewModel>().alternarTema(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              context.read<AuthViewModel>().logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Faixa de boas-vindas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            decoration: BoxDecoration(
              gradient: gradiente(context),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: cores.onPrimary,
                  child: Text(
                    inicial,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: cores.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, $nomeUsuario!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: cores.onPrimary,
                        ),
                      ),
                      Text(
                        'Que bom ter você aqui.',
                        style: TextStyle(color: cores.onPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text(
                  'Seus dados salvos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Os dois cards lado a lado
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      // CARD 1: Preferências do usuário
                      Expanded(
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: cores.primaryContainer,
                          shape: formaCartao,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _mostrarPreferencias(context),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: cores.primary,
                                    child:
                                        Icon(Icons.tune, color: cores.onPrimary),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Preferências',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: cores.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tema e notificações',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cores.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: cores.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // CARD 2: Usuários no banco local
                      Expanded(
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: cores.tertiaryContainer,
                          shape: formaCartao,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _mostrarUsuarios(context),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: cores.tertiary,
                                    child: Icon(
                                      Icons.storage_rounded,
                                      color: cores.onTertiary,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Banco local',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: cores.onTertiaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Usuários cadastrados',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cores.onTertiaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: cores.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Acesso ao editor de documentos (rota /editor)
                ElevatedButton.icon(
                  style: estiloBotao(context),
                  onPressed: () => Navigator.pushNamed(context, '/editor'),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Abrir meus documentos'),
                ),
                const SizedBox(height: 16),

                // Dica
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cores.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app_outlined,
                          color: cores.onSecondaryContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Toque em um card para ver as informações gravadas.',
                          style: TextStyle(color: cores.onSecondaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),

      // Barra inferior obrigatória com o nome do desenvolvedor
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cores.primaryContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.code, color: cores.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Desenvolvido por $nomeDesenvolvedor',
                  style: TextStyle(
                    color: cores.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}