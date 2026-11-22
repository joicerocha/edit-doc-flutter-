import 'package:flutter/material.dart';

import '../models/services/banco_local_service.dart';
import '../models/services/preferences_service.dart';
import '../models/usuario.dart';

/// Preferências lidas do armazenamento (usado pelo card da Home).
class PreferenciasSalvas {
  final String? tema;
  final bool? notificacoes;
  const PreferenciasSalvas({this.tema, this.notificacoes});
}

/// Autenticação, cadastro, sessão e preferências.
/// Aqui ficam o ESTADO e as REGRAS; as telas só desenham.
class AuthViewModel extends ChangeNotifier {
  // ---------- Tema do app ----------
  ThemeMode themeMode = ThemeMode.light;

  ThemeMode _modoDoTema(String? tema) =>
      tema == 'Escuro' ? ThemeMode.dark : ThemeMode.light;

  // ---------- Sessão ----------
  Usuario? usuarioLogado;

  // ---------- Estado da tela de Login ----------
  bool carregando = false;

  // ---------- Estado da tela de Cadastro ----------
  String tema = 'Claro';
  bool notificacoes = true;
  bool salvando = false;

  /// Chamado no main() antes de abrir o app:
  /// lê o tema salvo e restaura a sessão do usuário logado (se houver).
  Future<void> iniciar() async {
    final temaSalvo = await ServicoPreferencias.lerString('tema');
    if (temaSalvo != null) themeMode = _modoDoTema(temaSalvo);

    final emailSessao = await ServicoPreferencias.lerSessao();
    if (emailSessao != null) {
      usuarioLogado = await BancoDadosLocal.buscarUsuarioPorEmail(emailSessao);
    }
    notifyListeners();
  }

  /// Zera as escolhas do formulário ao abrir a tela de cadastro.
  void iniciarCadastro() {
    tema = 'Claro';
    notificacoes = true;
    salvando = false;
  }

  void setTema(String valor) {
    tema = valor;
    notifyListeners();
  }

  void setNotificacoes(bool valor) {
    notificacoes = valor;
    notifyListeners();
  }

  /// Alterna entre claro e escuro e salva a escolha.
  Future<void> alternarTema() async {
    themeMode =
        themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await ServicoPreferencias.salvarString(
      'tema',
      themeMode == ThemeMode.dark ? 'Escuro' : 'Claro',
    );
  }

  /// Retorna true se o login deu certo.
  Future<bool> login(String email, String senha) async {
    carregando = true;
    notifyListeners();

    final usuario = await BancoDadosLocal.autenticar(email, senha);
    if (usuario == null) {
      carregando = false;
      notifyListeners();
      return false;
    }

    final temaSalvo = await ServicoPreferencias.lerString('tema');
    if (temaSalvo != null) themeMode = _modoDoTema(temaSalvo);

    await ServicoPreferencias.salvarSessao(usuario.email);

    usuarioLogado = usuario;
    carregando = false;
    notifyListeners();
    return true;
  }

  /// Retorna false se o e-mail já estiver cadastrado.
  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    salvando = true;
    notifyListeners();

    final inserido = await BancoDadosLocal.inserirUsuario(
      nome: nome,
      email: email,
      senha: senha,
    );

    if (!inserido) {
      salvando = false;
      notifyListeners();
      return false;
    }

    await ServicoPreferencias.salvarString('tema', tema);
    await ServicoPreferencias.salvarBool('notificacoes', notificacoes);
    themeMode = _modoDoTema(tema);

    salvando = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    usuarioLogado = null;
    notifyListeners();
    await ServicoPreferencias.limparSessao();
  }

  // ---------- Usados pela Home ----------
  Future<PreferenciasSalvas> lerPreferencias() async {
    final t = await ServicoPreferencias.lerString('tema');
    final n = await ServicoPreferencias.lerBool('notificacoes');
    return PreferenciasSalvas(tema: t, notificacoes: n);
  }

  Future<List<Usuario>> listarUsuarios() => BancoDadosLocal.listarUsuarios();
}