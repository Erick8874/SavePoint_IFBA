import 'package:flutter/material.dart';
import 'package:save_point/gerenciador_estado.dart';
import 'package:save_point/telas/detalhes.dart';
import 'package:save_point/telas/galeria.dart';
import 'package:save_point/telas/login.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const GaleriaBugs());
}

class GaleriaBugs extends StatelessWidget {
  const GaleriaBugs({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GerenciadorEstado(),
      child: MaterialApp(
        title: 'SavePoint',
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          overscroll: false,
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7C4DFF),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const TelaPrincipal(),
      ),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  @override
  Widget build(BuildContext context) {
    estadoApp = context.watch<GerenciadorEstado>();

    Widget tela = const SizedBox.shrink();
    if (estadoApp.exibicao == EmExibicao.telaGaleria) {
      tela = const Galeria();
    } else if (estadoApp.exibicao == EmExibicao.telaDetalhes) {
      tela = const Detalhes();
    } else if (estadoApp.exibicao == EmExibicao.telaLogin) {
      tela = const Login();
    }

    return tela;
  }
}
