import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartaoComentario extends StatelessWidget {
  final dynamic comentario;
  final bool somenteLeitura;

  const CartaoComentario({
    super.key,
    required this.comentario,
    required this.somenteLeitura,
  });

  @override
  Widget build(BuildContext context) {
    String dataFormatada = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(DateTime.parse(comentario["datetime"]));

    return Card(
      color: somenteLeitura
          ? const Color(0xFF2C2838)
          : const Color(0xFF2A3D32),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 6, right: 6),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                comentario["content"],
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, left: 6.0),
                  child: Text(
                    dataFormatada,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    comentario["user"]["name"],
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
