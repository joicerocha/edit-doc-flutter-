import 'package:flutter/material.dart';

// Parte visual compartilhada pelas telas.
// (No DartPad eram _gradiente, _decoracao, _estiloBotao, _barra e _TituloSecao;
//  o "_" foi removido para poderem ser usados em outros arquivos.)

const String nomeDesenvolvedor = 'Joice Rocha';

LinearGradient gradiente(BuildContext context) {
  final cores = Theme.of(context).colorScheme;
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cores.primary, cores.tertiary],
  );
}

// Campo preenchido e arredondado, usado em todos os formulários
InputDecoration decoracao(BuildContext context, String rotulo, IconData icone) {
  final cores = Theme.of(context).colorScheme;
  return InputDecoration(
    labelText: rotulo,
    prefixIcon: Icon(icone),
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cores.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cores.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cores.error, width: 2),
    ),
  );
}

// Botão principal largo e arredondado
ButtonStyle estiloBotao(BuildContext context) {
  final cores = Theme.of(context).colorScheme;
  return ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    backgroundColor: cores.primary,
    foregroundColor: cores.onPrimary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

// AppBar com degradê
PreferredSizeWidget barra(BuildContext context, String titulo,
    {List<Widget>? acoes}) {
  return AppBar(
    title: Text(titulo),
    centerTitle: true,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace:
        Container(decoration: BoxDecoration(gradient: gradiente(context))),
    actions: acoes,
  );
}

// Título de seção com ícone
class TituloSecao extends StatelessWidget {
  final IconData icone;
  final String texto;
  const TituloSecao(this.icone, this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          texto,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}