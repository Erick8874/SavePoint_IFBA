import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_point/componentes/cartao_comentario.dart';
import 'package:save_point/componentes/cartao_detalhes_captura.dart';
import 'package:save_point/componentes/controles_usuario.dart';
import 'package:save_point/componentes/imagem_captura.dart';
import 'package:save_point/gerenciador_estado.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DetalhesState();
  }
}

class _DetalhesState extends State<Detalhes> {
  dynamic _captura;
  List<dynamic> _comentarios = [];
  bool _carregandoComentarios = false;

  final TextEditingController _controladorNovoComentario =
      TextEditingController();
  final ScrollController _controladorListaComentarios = ScrollController();

  late PageController _controladorSlides;
  late int _slideSelecionado;

  List<dynamic> get _blobs {
    if (_captura == null) {
      return [];
    }
    return _captura["captura"]["blobs"] as List<dynamic>;
  }

  bool _usuarioCurtiu(GerenciadorEstado estado) {
    final usuario = estado.usuario;
    return _captura != null &&
        usuario != null &&
        estado.usuarioCurtiuCaptura(_captura["_id"] as int, usuario.email);
  }

  int _curtidas(GerenciadorEstado estado) {
    if (_captura == null) {
      return 0;
    }

    return estado.curtidasDaCaptura(
      _captura["_id"] as int,
      _captura["likes"] as int,
    );
  }

  @override
  void initState() {
    super.initState();
    ToastContext().init(context);
    _iniciarSlides();
    _carregarCaptura();
  }

  @override
  void dispose() {
    _controladorNovoComentario.dispose();
    _controladorListaComentarios.dispose();
    _controladorSlides.dispose();
    super.dispose();
  }

  void _iniciarSlides() {
    _slideSelecionado = 0;
    _controladorSlides = PageController(initialPage: _slideSelecionado);
  }

  Future<dynamic> _acessarCaptura(int idCaptura) async {
    final String conteudo = await rootBundle.loadString(
      "recursos/jsons/capturas.json",
    );
    final dynamic dicionario = json.decode(conteudo);

    return dicionario["capturas"].firstWhere(
      (captura) => captura["_id"] == idCaptura,
    );
  }

  void _carregarCaptura() {
    _acessarCaptura(estadoApp.idCaptura).then((captura) {
      if (!mounted) {
        return;
      }

      setState(() {
        _captura = captura;
      });
      _carregarComentarios();
    });
  }

  Future<List<dynamic>> _acessarComentarios() async {
    final String conteudo = await rootBundle.loadString(
      "recursos/jsons/comentarios_capturas.json",
    );
    final dynamic dicionario = json.decode(conteudo);
    return dicionario["comentarios"];
  }

  Future<void> _carregarComentarios() async {
    setState(() {
      _carregandoComentarios = true;
    });

    try {
      final comentarios = await _acessarComentarios();
      if (!mounted) {
        return;
      }

      estadoApp.carregarComentarios(comentarios);
      setState(() {
        _comentarios = estadoApp.comentariosDaCaptura(_captura["_id"] as int);
        _carregandoComentarios = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _comentarios = [];
        _carregandoComentarios = false;
      });
    }
  }

  Widget _exibirMensagemComentariosInexistentes() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.comment, size: 26),
            Text("não existem comentários", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _exibirComentarios() {
    return _carregandoComentarios
        ? const Center(child: CircularProgressIndicator())
        : Expanded(
            child: ListView.builder(
              controller: _controladorListaComentarios,
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _comentarios.length,
              itemBuilder: (context, index) {
                final comentario = _comentarios[index];
                bool usuarioLogadoComentou =
                    estadoApp.usuario != null &&
                    estadoApp.usuario!.email == comentario["user"]["email"];

                return SizedBox(
                  height: 90,
                  child: Dismissible(
                    key: UniqueKey(),
                    direction: usuarioLogadoComentou
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    background: Container(
                      alignment: Alignment.centerRight,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12.0),
                        child: Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: const Text("Deseja apagar o comentário?"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("NÃO"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("SIM"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      estadoApp.removerComentario(
                        _captura["_id"] as int,
                        comentario["_id"] as int,
                      );
                      setState(() {
                        _comentarios.removeAt(index);
                      });
                    },
                    child: CartaoComentario(
                      comentario: comentario,
                      somenteLeitura: !usuarioLogadoComentou,
                    ),
                  ),
                );
              },
            ),
          );
  }

  void _adicionarComentario(String conteudo) {
    final texto = conteudo.trim();
    if (texto.isEmpty) {
      Toast.show(
        "Digite um comentário",
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );
      return;
    }

    final idCaptura = _captura["_id"] as int;
    estadoApp.adicionarComentario(idCaptura, texto);
    setState(() {
      _comentarios = estadoApp.comentariosDaCaptura(idCaptura);
      _controladorNovoComentario.clear();
    });

    Toast.show(
      "comentário adicionado",
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
    );
  }

  void _onCurtiuDescurtiu() {
    final usuario = estadoApp.usuario;
    if (usuario == null) {
      return;
    }

    final idCaptura = _captura["_id"] as int;
    final curtidasIniciais = _captura["likes"] as int;
    final vaiCurtir = !estadoApp.usuarioCurtiuCaptura(idCaptura, usuario.email);
    estadoApp.alternarCurtida(idCaptura, curtidasIniciais, usuario.email);

    Toast.show(
      vaiCurtir ? "você curtiu esta captura" : "curtida removida",
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
    );
  }

  void _pedirLogin() {
    Toast.show(
      "Entre na sua conta para curtir e comentar",
      duration: Toast.lengthLong,
      gravity: Toast.bottom,
    );
    estadoApp.exibirLogin();
  }

  Widget _exibirCaptura(GerenciadorEstado estado) {
    final usuarioLogado = estado.usuarioLogado;
    final tipo = _captura["tipo"] as String;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.sports_esports, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _captura["jogo"]["estudio"],
                style: const TextStyle(fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                estadoApp.exibirGaleria();
              },
              child: const Icon(Icons.arrow_back, size: 30),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 230,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: _blobs.length,
                  controller: _controladorSlides,
                  onPageChanged: (slide) {
                    setState(() {
                      _slideSelecionado = slide;
                    });
                  },
                  itemBuilder: (context, pagePosition) {
                    return ImagemCaptura(
                      caminho: _blobs[pagePosition]["file"],
                      tipo: tipo,
                    );
                  },
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: ControlesUsuario(
                    usuarioCurtiu: _usuarioCurtiu(estado),
                    usuarioLogado: usuarioLogado,
                    onAlternarCurtida: _onCurtiuDescurtiu,
                    onPedirLogin: _pedirLogin,
                  ),
                ),
              ],
            ),
          ),
          if (_blobs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: PageViewDotIndicator(
                currentItem: _slideSelecionado,
                count: _blobs.length,
                unselectedColor: Colors.white24,
                selectedColor: Colors.deepPurpleAccent,
                duration: const Duration(milliseconds: 200),
                boxShape: BoxShape.circle,
              ),
            ),
          CartaoDetalhesCaptura(captura: _captura, curtidas: _curtidas(estado)),
          const Center(
            child: Text(
              "Comentários",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          usuarioLogado
              ? Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextField(
                    controller: _controladorNovoComentario,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white54,
                          width: 0.0,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                      hintStyle: const TextStyle(fontSize: 14),
                      hintText: 'Digite aqui seu comentário...',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _adicionarComentario(_controladorNovoComentario.text);
                        },
                        child: const Icon(Icons.send),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: _pedirLogin,
                      icon: const Icon(Icons.login),
                      label: const Text("Entre para comentar esta captura"),
                    ),
                  ),
                ),
          _comentarios.isNotEmpty
              ? _exibirComentarios()
              : _exibirMensagemComentariosInexistentes(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<GerenciadorEstado>();
    Widget detalhes = const SizedBox.expand(
      child: Center(child: CircularProgressIndicator()),
    );

    if (_captura != null) {
      detalhes = _exibirCaptura(estado);
    }

    return detalhes;
  }
}
