// Modelo de dados: uma LINHA da tabela "usuarios"
class Usuario {
  final int id;
  final String nome;
  final String email;
  final String senha;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
  });

  // Objeto -> linha da tabela (como o SQLite recebe os dados)
  Map<String, Object?> toMap() => {
        'id': id,
        'nome': nome,
        'email': email,
        'senha': senha,
      };

  // Linha da tabela -> objeto
  factory Usuario.fromMap(Map<String, Object?> mapa) => Usuario(
        id: mapa['id'] as int,
        nome: mapa['nome'] as String,
        email: mapa['email'] as String,
        senha: mapa['senha'] as String,
      );
}
