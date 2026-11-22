import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../documento.dart';

/// CRUD de documentos.
/// A lista de objetos vira texto JSON (jsonEncode) para ser gravada no
/// shared_preferences, e volta a ser lista de objetos (jsonDecode) na leitura.
class DocumentoStorageService {
  static const String _chave = 'documentos';

  // ---------- READ ----------
  static Future<List<Documento>> listar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_chave);

    // Primeira vez que o app abre: cria os documentos de exemplo
    if (texto == null) {
      final iniciais = _documentosIniciais();
      await _salvarTodos(iniciais);
      return iniciais;
    }

    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((item) =>
            Documento.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  // ---------- CREATE ----------
  static Future<Documento> criar({
    required String titulo,
    String conteudo = '',
    String tipoIcone = 'novo',
  }) async {
    final docs = await listar();
    final novo = Documento(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: titulo,
      conteudo: conteudo,
      tipoIcone: tipoIcone,
    );
    docs.add(novo);
    await _salvarTodos(docs);
    return novo;
  }

  // ---------- UPDATE ----------
  static Future<void> atualizar(Documento doc) async {
    final docs = await listar();
    final i = docs.indexWhere((d) => d.id == doc.id);
    if (i == -1) return;
    docs[i] = doc;
    await _salvarTodos(docs);
  }

  // ---------- DELETE ----------
  static Future<void> excluir(String id) async {
    final docs = await listar();
    docs.removeWhere((d) => d.id == id);
    await _salvarTodos(docs);
  }

  // ---------- Auxiliares ----------
  static Future<void> _salvarTodos(List<Documento> docs) async {
    final prefs = await SharedPreferences.getInstance();
    final texto = jsonEncode(docs.map((d) => d.toMap()).toList());
    await prefs.setString(_chave, texto);
  }

  static List<Documento> _documentosIniciais() => [
        Documento(
          id: 'inicial-1',
          titulo: 'Relatório.pdf',
          conteudo: 'Relatório de atividades do mês.\n\n'
              'Aqui você pode ler e editar o conteúdo do documento.',
          tipoIcone: 'pdf',
        ),
        Documento(
          id: 'inicial-2',
          titulo: 'Anotações.txt',
          conteudo: 'Lista de tarefas:\n- Estudar Flutter\n- Fazer a atividade\n'
              '- Entregar no Blackboard',
          tipoIcone: 'txt',
        ),
        Documento(
          id: 'inicial-3',
          titulo: 'Ideias.md',
          conteudo: '# Ideias\n\nUm aplicativo para ler e editar documentos!',
          tipoIcone: 'md',
        ),
      ];
}