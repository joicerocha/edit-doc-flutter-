// Teste básico do app: abre a tela de Login e confere a validação do formulário.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:edit_doc_flutter/main.dart';
import 'package:edit_doc_flutter/viewmodels/auth_viewmodel.dart';

// O MeuApp lê o AuthViewModel, então precisa do Provider por cima
// (igual ao que o main() faz).
Widget _criarApp() {
  return ChangeNotifierProvider<AuthViewModel>(
    create: (_) => AuthViewModel(),
    child: const MeuApp(),
  );
}

void main() {
  testWidgets('Abre a tela de Login', (WidgetTester tester) async {
    await tester.pumpWidget(_criarApp());

    expect(find.text('DocReader'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Ainda não tem conta? Cadastre-se'), findsOneWidget);
  });

  testWidgets('Login vazio mostra as mensagens de validação',
      (WidgetTester tester) async {
    await tester.pumpWidget(_criarApp());

    // Garante que o botão está visível na tela de teste antes de tocar
    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget);
  });
}