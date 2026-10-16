import 'package:flutter/material.dart';
import 'package:save_point/util/tipo_captura.dart';

class CartaoDetalhesCaptura extends StatelessWidget {
  final dynamic captura;
  final int curtidas;

  const CartaoDetalhesCaptura({
    super.key,
    required this.captura,
    required this.curtidas,
  });

  @override
  Widget build(BuildContext context) {
    final tipo = captura["tipo"] as String;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TipoCaptura.cor(tipo),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    TipoCaptura.rotulo(tipo),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    captura["jogo"]["nome"],
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              captura["captura"]["titulo"],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              captura["captura"]["descricao"],
              style: const TextStyle(fontSize: 13, height: 1.35),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    captura["captura"]["local"],
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.videogame_asset, size: 16),
                const SizedBox(width: 4),
                Text(
                  captura["captura"]["plataforma"],
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                const Icon(Icons.favorite_rounded, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Text(
                  curtidas.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
