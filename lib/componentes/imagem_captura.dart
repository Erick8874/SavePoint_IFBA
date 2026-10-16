import 'package:flutter/material.dart';
import 'package:save_point/util/tipo_captura.dart';

class ImagemCaptura extends StatelessWidget {
  final String caminho;
  final String tipo;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ImagemCaptura({
    super.key,
    required this.caminho,
    this.tipo = TipoCaptura.todos,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      caminho,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return _PlaceholderCaptura(tipo: tipo, width: width, height: height);
      },
    );
  }
}

class _PlaceholderCaptura extends StatelessWidget {
  final String tipo;
  final double? width;
  final double? height;

  const _PlaceholderCaptura({required this.tipo, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final cor = TipoCaptura.cor(tipo);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cor.withValues(alpha: 0.35), const Color(0xFF1A1328)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(TipoCaptura.icone(tipo), size: 48, color: cor),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Adicione a imagem em recursos/imagens",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
