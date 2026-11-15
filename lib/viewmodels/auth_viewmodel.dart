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

/// Autenticação, cadastro e carregamento de preferências.
/// Aqui ficam o ESTADO e as REGRAS; as telas só desenham.
class AuthViewModel extends ChangeNotifier {
  // ---------- Tema do app (antes era o temaNotifier global) ----------
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

    // 1) Grava o usuário no banco local (assíncrono)
    final inserido = await BancoDadosLocal.inserirUsuario(
      nome: nome,
      email: email,
      senha: senha,
    );

    // 2) E-mail repetido -> interrompe
    if (!inserido) {
      salvando = false;
      notifyListeners();
      return false;
    }

    // 3) Grava as preferências (chave-valor)
    await ServicoPreferencias.salvarString('tema', tema);
    await ServicoPreferencias.salvarBool('notificacoes', notificacoes);

    // 4) Aplica o tema escolhido na hora
    themeMode = _modoDoTema(tema);

    salvando = false;
    notifyListeners();
    return true;
  }

  void logout() {
    usuarioLogado = null;
    notifyListeners();
  }

  // ---------- Usados pela Home ----------
  Future<PreferenciasSalvas> lerPreferencias() async {
    final t = await ServicoPreferencias.lerString('tema');
    final n = await ServicoPreferencias.lerBool('notificacoes');
    return PreferenciasSalvas(tema: t, notificacoes: n);
  }

  Future<List<Usuario>> listarUsuarios() => BancoDadosLocal.listarUsuarios();
}