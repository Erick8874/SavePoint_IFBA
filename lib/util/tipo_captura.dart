import 'package:flutter/material.dart';

class TipoCaptura {
  static const String todos = "todos";
  static const String bug = "bug";
  static const String easterEgg = "easter_egg";
  static const String local = "local";
  static const String cena = "cena";

  static const List<String> filtros = [
    todos,
    bug,
    easterEgg,
    local,
    cena,
  ];

  static String rotulo(String tipo) {
    switch (tipo) {
      case bug:
        return "Bug";
      case easterEgg:
        return "Easter Egg";
      case local:
        return "Local";
      case cena:
        return "Cena";
      case todos:
        return "Todos";
      default:
        return tipo;
    }
  }

  static IconData icone(String tipo) {
    switch (tipo) {
      case bug:
        return Icons.bug_report;
      case easterEgg:
        return Icons.auto_awesome;
      case local:
        return Icons.place;
      case cena:
        return Icons.movie_filter;
      default:
        return Icons.sports_esports;
    }
  }

  static Color cor(String tipo) {
    switch (tipo) {
      case bug:
        return const Color(0xFFFF6B6B);
      case easterEgg:
        return const Color(0xFFFFC857);
      case local:
        return const Color(0xFF4ECDC4);
      case cena:
        return const Color(0xFF9B8CFF);
      default:
        return const Color(0xFF90CAF9);
    }
  }
}
