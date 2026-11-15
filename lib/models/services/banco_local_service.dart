import '../usuario.dart';

// Banco de dados local simulado (ESTRUTURADO / RELACIONAL)
// Espelha a lógica de uma tabela SQLite:
//   CREATE TABLE usuarios (
//     id INTEGER PRIMARY KEY AUTOINCREMENT,
//     nome TEXT NOT NULL,
//     email TEXT NOT NULL UNIQUE,
//     senha TEXT NOT NULL
//   );
class BancoDadosLocal {
  static final List<Map<String, Object?>> _tabelaUsuarios = [];
  static int _proximoId = 1; // AUTOINCREMENT
  static const Duration _latencia = Duration(milliseconds: 300);

  // INSERT: devolve false se o e-mail já existir (regra UNIQUE)
  static Future<bool> inserirUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    await Future.delayed(_latencia);
    final emailNormalizado = email.trim().toLowerCase();
    final jaExiste =
        _tabelaUsuarios.any((linha) => linha['email'] == emailNormalizado);
    if (jaExiste) return false;

    final novo = Usuario(
      id: _proximoId++,
      nome: nome.trim(),
      email: emailNormalizado,
      senha: senha,
    );
    _tabelaUsuarios.add(novo.toMap());
    return true;
  }

  // SELECT * FROM usuarios
  static Future<List<Usuario>> listarUsuarios() async {
    await Future.delayed(_latencia);
    return _tabelaUsuarios.map(Usuario.fromMap).toList();
  }

  // SELECT * FROM usuarios WHERE email = ? AND senha = ?
  static Future<Usuario?> autenticar(String email, String senha) async {
    await Future.delayed(_latencia);
    final emailNormalizado = email.trim().toLowerCase();
    for (final linha in _tabelaUsuarios) {
      if (linha['email'] == emailNormalizado && linha['senha'] == senha) {
        return Usuario.fromMap(linha);
      }
    }
    return null;
  }
}