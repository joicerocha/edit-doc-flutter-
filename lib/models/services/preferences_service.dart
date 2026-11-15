// Serviço de preferências (CHAVE-VALOR)
// Simula o pacote shared_preferences, que não roda no DartPad.
// Os métodos têm a mesma ideia do pacote real: tudo assíncrono.
//
// Equivalente com o pacote real:
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString('tema', valor);
//   final tema = prefs.getString('tema');
class ServicoPreferencias {
  static final Map<String, Object> _armazenamento = {};

  static Future<void> salvarString(String chave, String valor) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _armazenamento[chave] = valor;
  }

  static Future<void> salvarBool(String chave, bool valor) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _armazenamento[chave] = valor;
  }

  static Future<String?> lerString(String chave) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _armazenamento[chave] as String?;
  }

  static Future<bool?> lerBool(String chave) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _armazenamento[chave] as bool?;
  }
}