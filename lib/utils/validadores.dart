// FUNÇÕES EXTERNAS DE VALIDAÇÃO

String? validarNome(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Informe seu nome completo';
  }
  return null;
}

// Validação ESTRITA: precisa de @ e terminar em .com ou .com.br para ser válido
String? validarEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Informe seu e-mail';
  }
  final email = value.trim().toLowerCase();
  if (!email.contains('@')) {
    return 'O e-mail deve conter o caractere @';
  }
  if (!(email.endsWith('.com') || email.endsWith('.com.br'))) {
    return 'O e-mail deve terminar com .com ou .com.br';
  }
  // Formato geral: texto antes do @ e um domínio antes do .com / .com.br
  final formato = RegExp(r'^[^@\s]+@[^@\s]+\.(com|com\.br)$');
  if (!formato.hasMatch(email)) {
    return 'Informe um e-mail válido (ex.: nome@dominio.com)';
  }
  return null;
}

String? validarSenha(String? value) {
  if (value == null || value.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  return null;
}