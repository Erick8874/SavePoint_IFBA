import 'package:flutter/material.dart';
import 'package:save_point/autenticador.dart';
import 'package:save_point/gerenciador_estado.dart';
import 'package:save_point/usuario.dart';
import 'package:toast/toast.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _controladorUsuario = TextEditingController(
    text: Autenticador.usuarioPadrao,
  );
  final TextEditingController _controladorSenha = TextEditingController(
    text: Autenticador.senhaPadrao,
  );
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
  }

  @override
  void dispose() {
    _controladorUsuario.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() {
      _enviando = true;
    });

    final Usuario? usuario = await Autenticador.login(
      usuario: _controladorUsuario.text,
      senha: _controladorSenha.text,
    );

    setState(() {
      _enviando = false;
    });

    if (usuario == null) {
      Toast.show(
        "E-mail ou senha inválidos",
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );
      return;
    }

    estadoApp.login(usuario);
    estadoApp.exibirGaleria();

    Toast.show(
      "Olá, ${usuario.nome}",
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
    );
  }

  void _continuarComoVisitante() {
    estadoApp.exibirGaleria();
    Toast.show(
      "Modo visitante: você pode ver as capturas, mas não curtir nem comentar",
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entrar"),
        leading: IconButton(
          onPressed: () => estadoApp.voltarDaLogin(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.sports_esports, size: 64),
            const SizedBox(height: 12),
            const Text(
              "Galeria de Bugs, Easter Eggs e Cenas",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Login mockado para a disciplina. Use as credenciais preenchidas ou continue como visitante.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controladorUsuario,
              decoration: const InputDecoration(
                labelText: "Usuário",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controladorSenha,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _enviando ? null : _entrar,
              child: _enviando
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Entrar"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _continuarComoVisitante,
              child: const Text("Continuar como visitante"),
            ),
            const SizedBox(height: 16),
            const Text(
              "Usuário: admin\nSenha: admin",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
