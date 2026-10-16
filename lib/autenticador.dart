import 'package:save_point/usuario.dart';

class Autenticador {
  static const String usuarioPadrao = "admin";
  static const String senhaPadrao = "admin";

  static Future<Usuario?> login({
    String usuario = usuarioPadrao,
    String senha = senhaPadrao,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (usuario.trim().toLowerCase() != usuarioPadrao || senha != senhaPadrao) {
      return null;
    }

    return Usuario("Administrador", usuarioPadrao);
  }

  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
