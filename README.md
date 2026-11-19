# DocReader: Migração para MVVM (Fase 1)
 
Nesta fase eu peguei o app que fiz no DartPad (Login, Cadastro e Home), que estava todo em um arquivo só, e organizei na arquitetura MVVM. O app continua funcionando do mesmo jeito, só que agora dividido em pastas.
 
## 1. Onde cada coisa ficou apos a divisão
 
| O que era no DartPad | Onde ficou agora |
|---|---|
| `Usuario` (modelo) | `models/usuario.dart` |
| `ServicoPreferencias` (guarda tema e notificações) | `models/services/preferences_service.dart` |
| `BancoDadosLocal` (guarda os usuários) | `models/services/banco_local_service.dart` |
| `temaNotifier`, `_modoDoTema` e a lógica do `_fazerLogin` e do `_cadastrar` | `viewmodels/auth_viewmodel.dart` (virou `themeMode`, `login()` e `cadastrar()`) |
| `TelaLogin`, `TelaCadastro` e `TelaHome` | `views/login_view.dart`, `cadastro_view.dart` e `home_view.dart` (agora `LoginView`, `CadastroView` e `HomeView`) |
| `validarNome`, `validarEmail` e `validarSenha` | `utils/validadores.dart` |
| Funções visuais (`_gradiente`, `_decoracao`, `_estiloBotao`, `_barra`, `_TituloSecao`) e `nomeDesenvolvedor` | `utils/componentes.dart` |
| `main()`, `MeuApp` e as rotas | `main.dart` |
 
## 2. O que foi preciso mudar ao dividir o arquivo
 
- **Nomes com `_`:** no Dart, o `_` deixa o nome privado dentro do arquivo. Como as funções visuais (`gradiente`, `decoracao`, `estiloBotao`, `barra` e `TituloSecao`) passaram a ser usadas em várias telas, tirei o `_` para elas ficarem públicas. O `_modoDoTema` continuou privado porque só o ViewModel usa.
- **Construtores:** as telas continuam com construtor `const` e `super.key`, só mudei os nomes. O `TituloSecao` ganhou `{super.key}`. Também criei a classe `PreferenciasSalvas` para o ViewModel entregar o tema e as notificações para a Home.
- **Imports:** em cada arquivo importei só o que ele usa. As views importam os ViewModels e o utils, os ViewModels importam os models, e nenhuma view importa os models direto.
- **Rotas nomeadas:** ficaram no `main.dart` (`/`, `/cadastro` e `/home`), com `initialRoute: '/'`. O nome do usuário não vai mais por `arguments`: a Home pega do `usuarioLogado`, que fica no ViewModel.
- **Provider:** instalei o pacote `provider` e coloquei o `ChangeNotifierProvider` acima do `MaterialApp`, para todas as telas usarem o mesmo ViewModel.
## 3. O que mudou no estado
 
- **`setState` que saíram das telas (8):** no Login foram 3 (do `_carregando`) e no Cadastro foram 5 (3 do `_salvando`, 1 do `_tema` no Dropdown e 1 do `_notificacoes` no Switch). A Home já era `StatelessWidget`, então não tinha nenhum.
- **Variáveis que foram para o `AuthViewModel`:** `carregando`, `salvando`, `tema`, `notificacoes`, `themeMode` (que era o `temaNotifier`) e `usuarioLogado` (que antes vinha por `arguments`). Quando o estado muda, o ViewModel chama `notifyListeners()`.
- **Como as telas atualizam:** usei o `provider`, que escuta o `ChangeNotifier` e reconstrói a tela quando recebe o `notifyListeners()` (faz o mesmo papel do `ListenableBuilder`). No `MeuApp` usei `context.select` no `themeMode`, no lugar do `ValueListenableBuilder`. Nas telas uso `context.watch` para ler o estado e `context.read` para chamar os métodos.