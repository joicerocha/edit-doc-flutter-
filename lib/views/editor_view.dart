import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/componentes.dart';
import '../viewmodels/documentos_viewmodel.dart';

// TELA DE EDIÇÃO E CRIAÇÃO DE DOCUMENTOS (rota: /editor)
class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<DocumentosViewModel>().carregar();
      if (!mounted) return;
      _sincronizar();
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  /// Copia o documento atual do ViewModel para os campos de texto.
  void _sincronizar() {
    final doc = context.read<DocumentosViewModel>().documentoAtual;
    _tituloController.text = doc?.titulo ?? '';
    _conteudoController.text = doc?.conteudo ?? '';
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _selecionar(int i) async {
    await context.read<DocumentosViewModel>().selecionar(i);
    if (!mounted) return;
    _sincronizar();
  }

  Future<void> _novo() async {
    await context.read<DocumentosViewModel>().novoDocumento();
    if (!mounted) return;
    _sincronizar();
    _mensagem('Novo documento criado!');
  }

  Future<void> _salvar() async {
    final vm = context.read<DocumentosViewModel>();
    final titulo = vm.documentoAtual?.titulo ?? '';
    await vm.salvar();
    if (!mounted) return;
    _mensagem('"$titulo" salvo com sucesso!');
  }

  void _exportarPdf() {
    final titulo = context.read<DocumentosViewModel>().documentoAtual?.titulo;
    _mensagem('Exportando "$titulo" para PDF (simulado)...');
  }

  Future<void> _excluir() async {
    final vm = context.read<DocumentosViewModel>();
    final titulo = vm.documentoAtual?.titulo ?? '';

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir documento'),
        content: Text('Deseja excluir "$titulo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await vm.excluirAtual();
    if (!mounted) return;
    _sincronizar();
    _mensagem('"$titulo" excluído.');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DocumentosViewModel>();
    final cores = Theme.of(context).colorScheme;
    final doc = vm.documentoAtual;

    return Scaffold(
      appBar: barra(context, 'Meus documentos'),
      body: vm.carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lista horizontal de documentos
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vm.documentos.length,
                      itemBuilder: (context, i) {
                        final d = vm.documentos[i];
                        final ativo = i == vm.indice;
                        return SizedBox(
                          width: 150,
                          child: Card(
                            color: ativo ? cores.primaryContainer : null,
                            child: InkWell(
                              onTap: () => _selecionar(i),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(d.icone, size: 28),
                                    const SizedBox(height: 4),
                                    Text(
                                      d.titulo,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (doc == null)
                    const Expanded(
                      child: Center(
                          child: Text('Nenhum documento. Crie um novo!')),
                    )
                  else ...[
                    // Título + modo atual
                    Row(
                      children: [
                        Expanded(
                          child: vm.modoLeitura
                              ? Text(
                                  doc.titulo,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                )
                              : TextField(
                                  controller: _tituloController,
                                  onChanged: vm.editarTitulo,
                                  decoration: decoracao(
                                      context, 'Título', Icons.title),
                                ),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          avatar: Icon(
                            vm.modoLeitura ? Icons.menu_book : Icons.edit,
                            size: 18,
                          ),
                          label: Text(
                              vm.modoLeitura ? 'Modo leitura' : 'Modo edição'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Área de leitura / edição
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: vm.modoLeitura
                              ? SingleChildScrollView(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      doc.conteudo.isEmpty
                                          ? '(documento vazio)'
                                          : doc.conteudo,
                                      style: const TextStyle(
                                          fontSize: 16, height: 1.5),
                                    ),
                                  ),
                                )
                              : TextField(
                                  controller: _conteudoController,
                                  onChanged: vm.editarConteudo,
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                        'Digite o conteúdo do documento...',
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Botões de ação
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _novo,
                        icon: const Icon(Icons.note_add),
                        label: const Text('Novo'),
                      ),
                      if (doc != null) ...[
                        ElevatedButton.icon(
                          onPressed: _salvar,
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _exportarPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Exportar PDF'),
                        ),
                        OutlinedButton.icon(
                          onPressed: vm.alternarModoLeitura,
                          icon: Icon(
                              vm.modoLeitura ? Icons.edit : Icons.menu_book),
                          label:
                              Text(vm.modoLeitura ? 'Editar' : 'Modo Leitura'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _excluir,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Excluir'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}