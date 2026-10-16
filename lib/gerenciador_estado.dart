import 'package:flutter/material.dart';
import 'package:save_point/usuario.dart';

enum EmExibicao { telaGaleria, telaDetalhes, telaLogin }

class GerenciadorEstado extends ChangeNotifier {
  EmExibicao _exibicao = EmExibicao.telaGaleria;
  EmExibicao get exibicao => _exibicao;

  EmExibicao _telaAnterior = EmExibicao.telaGaleria;

  int _idCaptura = -1;
  int get idCaptura => _idCaptura;

  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  bool get usuarioLogado => _usuario != null;

  final Map<int, int> _curtidasPorCaptura = {};
  final Set<String> _capturasCurtidasPorUsuario = {};
  final Map<int, List<Map<String, dynamic>>> _comentariosPorCaptura = {};
  bool _comentariosCarregados = false;
  int _proximoIdComentario = 1;

  int curtidasDaCaptura(int idCaptura, int curtidasIniciais) {
    return _curtidasPorCaptura[idCaptura] ?? curtidasIniciais;
  }

  bool usuarioCurtiuCaptura(int idCaptura, String email) {
    return _capturasCurtidasPorUsuario.contains('$email:$idCaptura');
  }

  void alternarCurtida(int idCaptura, int curtidasIniciais, String email) {
    final chave = '$email:$idCaptura';
    final curtidasAtuais = curtidasDaCaptura(idCaptura, curtidasIniciais);

    if (_capturasCurtidasPorUsuario.remove(chave)) {
      _curtidasPorCaptura[idCaptura] = (curtidasAtuais - 1).clamp(0, 1 << 31);
    } else {
      _capturasCurtidasPorUsuario.add(chave);
      _curtidasPorCaptura[idCaptura] = curtidasAtuais + 1;
    }

    notifyListeners();
  }

  void carregarComentarios(List<dynamic> comentarios) {
    if (_comentariosCarregados) {
      return;
    }

    for (final item in comentarios) {
      final comentario = Map<String, dynamic>.from(item as Map);
      final idCaptura = comentario['capturaId'] as int;
      _comentariosPorCaptura.putIfAbsent(idCaptura, () => []).add(comentario);
      final idComentario = comentario['_id'] as int;
      if (idComentario >= _proximoIdComentario) {
        _proximoIdComentario = idComentario + 1;
      }
    }

    _comentariosCarregados = true;
    notifyListeners();
  }

  List<Map<String, dynamic>> comentariosDaCaptura(int idCaptura) {
    return List<Map<String, dynamic>>.of(
      _comentariosPorCaptura[idCaptura] ?? const [],
    );
  }

  void adicionarComentario(int idCaptura, String conteudo) {
    final usuarioAtual = _usuario;
    if (usuarioAtual == null) {
      return;
    }

    _comentariosPorCaptura.putIfAbsent(idCaptura, () => []).insert(0, {
      '_id': _proximoIdComentario++,
      'capturaId': idCaptura,
      'user': {
        'userId': usuarioAtual.email,
        'email': usuarioAtual.email,
        'name': usuarioAtual.nome,
      },
      'datetime': DateTime.now().toIso8601String(),
      'content': conteudo,
    });
    notifyListeners();
  }

  void removerComentario(int idCaptura, int idComentario) {
    final comentarios = _comentariosPorCaptura[idCaptura];
    if (comentarios == null) {
      return;
    }

    comentarios.removeWhere((comentario) => comentario['_id'] == idComentario);
    notifyListeners();
  }

  void exibirGaleria() {
    _exibicao = EmExibicao.telaGaleria;
    notifyListeners();
  }

  void exibirDetalhes(int idCaptura) {
    _exibicao = EmExibicao.telaDetalhes;
    _idCaptura = idCaptura;
    notifyListeners();
  }

  void exibirLogin() {
    _telaAnterior = _exibicao;
    _exibicao = EmExibicao.telaLogin;
    notifyListeners();
  }

  void voltarDaLogin() {
    _exibicao = _telaAnterior;
    notifyListeners();
  }

  void login(Usuario? usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  void logout() {
    _usuario = null;
    notifyListeners();
  }
}

GerenciadorEstado estadoApp = GerenciadorEstado();
