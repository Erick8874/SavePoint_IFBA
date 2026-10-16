import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_point/autenticador.dart';
import 'package:save_point/componentes/cartao_captura.dart';
import 'package:save_point/gerenciador_estado.dart';
import 'package:save_point/util/tipo_captura.dart';
import 'package:toast/toast.dart';

class Galeria extends StatefulWidget {
  const Galeria({super.key});

  @override
  State<StatefulWidget> createState() => _GaleriaState();
}

class _GaleriaState extends State<Galeria> {
  List<dynamic> _capturas = [];
  bool _carregandoCapturas = false;
  bool _falhaAoCarregarCapturas = false;
  String _filtro = "";
  String _tipoSelecionado = TipoCaptura.todos;

  final TextEditingController _controladorFiltro = TextEditingController();

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _carregarCapturas();
  }

  @override
  void dispose() {
    _controladorFiltro.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _acessarCapturas() async {
    final String conteudo = await rootBundle.loadString(
      "recursos/jsons/capturas.json",
    );
    final dynamic dicionario = json.decode(conteudo);
    return dicionario["capturas"];
  }

  bool _correspondeFiltro(dynamic captura, String filtro) {
    if (filtro.isEmpty) {
      return true;
    }

    final texto =
        '${captura["captura"]["titulo"]} ${captura["jogo"]["nome"]} ${captura["captura"]["local"]}'
            .toLowerCase();
    return texto.contains(filtro.toLowerCase());
  }

  bool _correspondeTipo(dynamic captura) {
    if (_tipoSelecionado == TipoCaptura.todos) {
      return true;
    }
    return captura["tipo"] == _tipoSelecionado;
  }

  Future<void> _carregarCapturas() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _carregandoCapturas = true;
      _falhaAoCarregarCapturas = false;
    });

    try {
      final capturas = await _acessarCapturas();
      if (!mounted) {
        return;
      }

      setState(() {
        _capturas = capturas
            .where(_correspondeTipo)
            .where((captura) => _correspondeFiltro(captura, _filtro))
            .toList();
        _carregandoCapturas = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _capturas = [];
        _carregandoCapturas = false;
        _falhaAoCarregarCapturas = true;
      });
    }
  }

  Future<void> _atualizarCapturas() async {
    _capturas = [];
    _controladorFiltro.text = "";
    _filtro = "";
    _tipoSelecionado = TipoCaptura.todos;
    _carregarCapturas();
  }

  void _aplicarFiltro(String filtro) {
    _filtro = filtro;
    _capturas.clear();
    _carregarCapturas();
  }

  void _selecionarTipo(String tipo) {
    setState(() {
      _tipoSelecionado = tipo;
    });
    _capturas.clear();
    _carregarCapturas();
  }

  Future<void> _alternarSessao() async {
    if (estadoApp.usuarioLogado) {
      await Autenticador.logout();
      estadoApp.logout();
      Toast.show(
        "Você saiu da conta. Continuando como visitante",
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );
      return;
    }

    estadoApp.exibirLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Galeria de Jogos"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: estadoApp.usuarioLogado ? "Sair" : "Entrar",
              onPressed: _alternarSessao,
              icon: Icon(estadoApp.usuarioLogado ? Icons.logout : Icons.login),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _controladorFiltro,
              onSubmitted: _aplicarFiltro,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Buscar jogo, local ou título",
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: TipoCaptura.filtros.map((tipo) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _tipoSelecionado == tipo,
                    label: Text(TipoCaptura.rotulo(tipo)),
                    avatar: Icon(TipoCaptura.icone(tipo), size: 16),
                    onSelected: (_) => _selecionarTipo(tipo),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                estadoApp.usuarioLogado
                    ? "Logado como ${estadoApp.usuario!.nome}"
                    : "Modo visitante: veja as capturas. Entre para curtir e comentar.",
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
          Expanded(
            child: _carregandoCapturas
                ? const Center(child: CircularProgressIndicator())
                : _falhaAoCarregarCapturas
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      const Icon(Icons.error_outline, size: 40),
                      Center(
                        child: const Text(
                          "Não foi possível carregar as capturas",
                        ),
                      ),
                      Center(
                        child: TextButton.icon(
                          onPressed: _carregarCapturas,
                          icon: Icon(Icons.refresh),
                          label: Text("Tentar novamente"),
                        ),
                      ),
                    ],
                  )
                : RefreshIndicator(
                    color: Colors.deepPurpleAccent,
                    onRefresh: _atualizarCapturas,
                    child: _capturas.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              Icon(Icons.search_off, size: 40),
                              Center(child: Text("Nenhuma captura encontrada")),
                            ],
                          )
                        : GridView.builder(
                            scrollDirection: Axis.vertical,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(6),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 6,
                                  childAspectRatio: 0.62,
                                ),
                            itemCount: _capturas.length,
                            itemBuilder: (context, index) {
                              return CartaoCaptura(captura: _capturas[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
