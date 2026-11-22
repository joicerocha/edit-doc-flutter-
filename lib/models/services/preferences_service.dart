import 'package:shared_preferences/shared_preferences.dart';

/// Preferências do app (chave-valor) com o pacote shared_preferences.
/// Guarda o tema, as notificações e a sessão do usuário logado.
class ServicoPreferencias {
  static const String _chaveSessao = 'sessao_email';

  static Future<void> salvarString(String chave, String valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(chave, valor);
  }

  static Future<String?> lerString(String chave) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(chave);
  }

  static Future<void> salvarBool(String chave, bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(chave, valor);
  }

  static Future<bool?> lerBool(String chave) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(chave);
  }

  // ---------- Sessão do usuário logado ----------

  static Future<void> salvarSessao(String email) =>
      salvarString(_chaveSessao, email);

  static Future<String?> lerSessao() => lerString(_chaveSessao);

  static Future<void> limparSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveSessao);
  }
}
