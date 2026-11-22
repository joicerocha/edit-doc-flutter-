import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../usuario.dart';

/// Tabela de usuários, agora salva de forma permanente:
/// a lista vira JSON (jsonEncode) e fica no shared_preferences.
class BancoDadosLocal {
  static const String _chave = 'usuarios';

  static Future<List<Usuario>> _lerTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString(_chave);
    if (texto == null) return [];
    final lista = jsonDecode(texto) as List<dynamic>;
    return lista
        .map((item) => Usuario.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<void> _salvarTodos(List<Usuario> usuarios) async {
    final prefs = await SharedPreferences.getInstance();
    final texto = jsonEncode(usuarios.map((u) => u.toMap()).toList());
    await prefs.setString(_chave, texto);
  }

  // INSERT: devolve false se o e-mail já existir (regra UNIQUE)
  static Future<bool> inserirUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final usuarios = await _lerTodos();
    final emailNormalizado = email.trim().toLowerCase();
    if (usuarios.any((u) => u.email == emailNormalizado)) return false;

    // AUTOINCREMENT: maior id existente + 1
    final proximoId =
        usuarios.fold<int>(0, (maior, u) => u.id > maior ? u.id : maior) + 1;

    usuarios.add(Usuario(
      id: proximoId,
      nome: nome.trim(),
      email: emailNormalizado,
      senha: senha,
    ));
    await _salvarTodos(usuarios);
    return true;
  }

  // SELECT * FROM usuarios
  static Future<List<Usuario>> listarUsuarios() => _lerTodos();

  // SELECT * FROM usuarios WHERE email = ?
  static Future<Usuario?> buscarUsuarioPorEmail(String email) async {
    final emailNormalizado = email.trim().toLowerCase();
    final usuarios = await _lerTodos();
    for (final u in usuarios) {
      if (u.email == emailNormalizado) return u;
    }
    return null;
  }

  // SELECT * FROM usuarios WHERE email = ? AND senha = ?
  static Future<Usuario?> autenticar(String email, String senha) async {
    final u = await buscarUsuarioPorEmail(email);
    return (u != null && u.senha == senha) ? u : null;
  }
}