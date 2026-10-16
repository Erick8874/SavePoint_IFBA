// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:save_point/autenticador.dart';
import 'package:save_point/componentes/controles_usuario.dart';
import 'package:save_point/gerenciador_estado.dart';
import 'package:save_point/main.dart';
import 'package:save_point/usuario.dart';

void main() {
  test('Somente a conta admin pode entrar', () async {
    final usuario = await Autenticador.login(usuario: 'admin', senha: 'admin');
    final contaAntiga = await Autenticador.login(
      usuario: 'erick@galeria.com',
      senha: '123456',
    );

    expect(usuario?.nome, 'Administrador');
    expect(usuario?.email, 'admin');
    expect(contaAntiga, isNull);
  });

  testWidgets('A curtida alterna o coração e não oferece compartilhamento', (
    WidgetTester tester,
  ) async {
    var usuarioCurtiu = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ControlesUsuario(
              usuarioLogado: true,
              usuarioCurtiu: usuarioCurtiu,
              onAlternarCurtida: () {
                setState(() {
                  usuarioCurtiu = !usuarioCurtiu;
                });
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Curtir captura'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.share), findsNothing);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).color,
      Colors.white70,
    );

    await tester.tap(find.byTooltip('Curtir captura'));
    await tester.pump();

    expect(find.byTooltip('Remover curtida'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).color,
      Colors.red,
    );

    await tester.tap(find.byTooltip('Remover curtida'));
    await tester.pump();

    expect(find.byTooltip('Curtir captura'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  test('As capturas referenciam imagens disponíveis', () async {
    final data = jsonDecode(
      await rootBundle.loadString('recursos/jsons/capturas.json'),
    ) as Map<String, dynamic>;
    final capturas = data['capturas'] as List<dynamic>;

    expect(capturas, hasLength(4));
    for (final item in capturas) {
      final captura = item as Map<String, dynamic>;
      final detalhes = captura['captura'] as Map<String, dynamic>;
      final blobs = detalhes['blobs'] as List<dynamic>;
      final imagem = blobs.first as Map<String, dynamic>;

      await rootBundle.load(imagem['file'] as String);
    }
  });

  test('Os comentários estão ligados às capturas existentes', () async {
    final capturasData = jsonDecode(
      await rootBundle.loadString('recursos/jsons/capturas.json'),
    ) as Map<String, dynamic>;
    final comentariosData = jsonDecode(
      await rootBundle.loadString('recursos/jsons/comentarios_capturas.json'),
    ) as Map<String, dynamic>;
    final idsCapturas = (capturasData['capturas'] as List<dynamic>)
        .map((captura) => (captura as Map<String, dynamic>)['_id'])
        .toSet();
    final comentarios = comentariosData['comentarios'] as List<dynamic>;

    expect(comentarios, hasLength(4));
    for (final item in comentarios) {
      final comentario = item as Map<String, dynamic>;
      expect(idsCapturas, contains(comentario['capturaId']));
      expect(comentario['user']['email'], isNotEmpty);
      expect(comentario['user']['name'], isNotEmpty);
    }
  });

  test('Curtidas e comentários permanecem durante a sessão', () async {
    final estado = GerenciadorEstado();
    const email = 'erick@galeria.com';
    estado.login(Usuario('Erick Gamer', email));

    final data = jsonDecode(
      await rootBundle.loadString('recursos/jsons/comentarios_capturas.json'),
    ) as Map<String, dynamic>;
    estado.carregarComentarios(data['comentarios'] as List<dynamic>);
    estado.adicionarComentario(1, 'Minha captura favorita.');
    estado.alternarCurtida(1, 0, email);

    estado.exibirGaleria();
    estado.exibirDetalhes(1);

    expect(estado.comentariosDaCaptura(1), hasLength(2));
    expect(
      estado.comentariosDaCaptura(1).first['content'],
      'Minha captura favorita.',
    );
    expect(estado.curtidasDaCaptura(1, 0), 1);
    expect(estado.usuarioCurtiuCaptura(1, email), isTrue);

    estado.removerComentario(
      1,
      estado.comentariosDaCaptura(1).first['_id'] as int,
    );
    expect(estado.comentariosDaCaptura(1), hasLength(1));
  });

  testWidgets('A galeria inicializa', (WidgetTester tester) async {
    await tester.pumpWidget(const GaleriaBugs());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    expect(find.text('SavePoint'), findsOneWidget);
    expect(find.text('Buscar jogo, local ou título'), findsOneWidget);
    expect(find.text('Não foi possível carregar as capturas'), findsNothing);
    expect(find.text('Hollow Knight'), findsOneWidget);
    expect(find.text('Uma referência em Hallownest'), findsOneWidget);
  });
}
