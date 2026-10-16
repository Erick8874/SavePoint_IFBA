import 'package:flutter/material.dart';
import 'package:save_point/componentes/imagem_captura.dart';
import 'package:save_point/gerenciador_estado.dart';
import 'package:save_point/util/tipo_captura.dart';
import 'package:provider/provider.dart';

class CartaoCaptura extends StatelessWidget {
  final dynamic captura;

  const CartaoCaptura({super.key, required this.captura});

  String get _tipo => captura["tipo"] as String;

  String get _primeiraImagem {
    final blobs = captura["captura"]["blobs"] as List<dynamic>;
    if (blobs.isEmpty) {
      return "recursos/imagens/placeholder.jpg";
    }
    return blobs.first["file"] as String;
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<GerenciadorEstado>();
    final curtidas = estado.curtidasDaCaptura(
      captura["_id"] as int,
      captura["likes"] as int,
    );

    return GestureDetector(
      onTap: () => estadoApp.exibirDetalhes(captura["_id"]),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImagemCaptura(caminho: _primeiraImagem, tipo: _tipo),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: TipoCaptura.cor(_tipo).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        TipoCaptura.rotulo(_tipo),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                captura["jogo"]["nome"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                captura["captura"]["titulo"],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                children: [
                  const Icon(Icons.place, size: 14, color: Colors.white54),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      captura["captura"]["local"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  const Icon(
                    Icons.favorite_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    curtidas.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
