import 'package:flutter/material.dart';

class ControlesUsuario extends StatelessWidget {
  final bool usuarioLogado;
  final bool usuarioCurtiu;

  final VoidCallback onAlternarCurtida;
  final void Function()? onPedirLogin;

  const ControlesUsuario({
    super.key,
    required this.usuarioLogado,
    required this.usuarioCurtiu,
    required this.onAlternarCurtida,
    this.onPedirLogin,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: usuarioCurtiu ? "Remover curtida" : "Curtir captura",
      onPressed: () {
        if (!usuarioLogado) {
          onPedirLogin?.call();
          return;
        }
        onAlternarCurtida();
      },
      icon: Icon(usuarioCurtiu ? Icons.favorite : Icons.favorite_border),
      color: usuarioCurtiu ? Colors.red : Colors.white70,
      iconSize: 32,
    );
  }
}
