import 'package:flutter/material.dart';

import '../models/documento.dart';
import '../models/services/documento_storage_service.dart';

/// Listagem e operações CRUD dos documentos.
/// A tela (editor_view) nunca fala direto com o armazenamento.
class DocumentosViewModel extends ChangeNotifier {
  List<Documento> _documentos = [];
  int _indice = 0;
  bool _modoLeitura = false;
  bool _carregando = false;

  List<Documento> get documentos => _documentos;
  int get indice => _indice;
  bool get modoLeitura => _modoLeitura;
  bool get carregando => _carregando;

  Documento? get documentoAtual =>
      _documentos.isEmpty ? null : _documentos[_indice];

  // READ
  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();
    _documentos = await DocumentoStorageService.listar();
    _indice = 0;
    _carregando = false;
    notifyListeners();
  }

  // Salva o documento aberto antes de trocar de documento ou criar outro
  Future<void> _persistirAtual() async {
    final doc = documentoAtual;
    if (doc != null) await DocumentoStorageService.atualizar(doc);
  }

  Future<void> selecionar(int novoIndice) async {
    await _persistirAtual();
    _indice = novoIndice;
    notifyListeners();
  }

  // Guardam o que foi digitado em memória (o Salvar grava no armazenamento)
  void editarTitulo(String texto) {
    documentoAtual?.titulo = texto;
    notifyListeners();
  }

  void editarConteudo(String texto) {
    documentoAtual?.conteudo = texto;
  }

  // CREATE
  Future<void> novoDocumento() async {
    await _persistirAtual();
    final doc = await DocumentoStorageService.criar(
      titulo: 'Novo Documento ${_documentos.length + 1}.txt',
    );
    _documentos.add(doc);
    _indice = _documentos.length - 1;
    _modoLeitura = false;
    notifyListeners();
  }

  // UPDATE
  Future<void> salvar() async {
    await _persistirAtual();
  }

  // DELETE
  Future<void> excluirAtual() async {
    final doc = documentoAtual;
    if (doc == null) return;
    await DocumentoStorageService.excluir(doc.id);
    _documentos.removeAt(_indice);
    _indice = 0;
    notifyListeners();
  }

  void alternarModoLeitura() {
    _modoLeitura = !_modoLeitura;
    notifyListeners();
  }
}