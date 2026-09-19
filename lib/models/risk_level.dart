/// Nivel de riesgo conceptual de un diseno educativo.
enum RiskLevel { bajo, medio, alto }

extension RiskLevelX on RiskLevel {
  String get etiqueta {
    switch (this) {
      case RiskLevel.bajo:
        return 'Riesgo bajo';
      case RiskLevel.medio:
        return 'Riesgo medio';
      case RiskLevel.alto:
        return 'Riesgo alto';
    }
  }

  String get descripcion {
    switch (this) {
      case RiskLevel.bajo:
        return 'Las relaciones geometricas ingresadas se mantienen dentro de '
            'los rangos educativos configurados.';
      case RiskLevel.medio:
        return 'Hay relaciones geometricas en el limite de los rangos '
            'educativos. Conviene revisarlas y justificarlas.';
      case RiskLevel.alto:
        return 'Existen relaciones geometricas fuera de los rangos educativos '
            'configurados. El diseno debe replantearse como ejercicio.';
    }
  }

  int get orden {
    switch (this) {
      case RiskLevel.bajo:
        return 0;
      case RiskLevel.medio:
        return 1;
      case RiskLevel.alto:
        return 2;
    }
  }
}

/// Devuelve el nivel mas severo de una lista de niveles.
RiskLevel nivelMasSevero(Iterable<RiskLevel> niveles) {
  RiskLevel resultado = RiskLevel.bajo;
  for (final RiskLevel nivel in niveles) {
    if (nivel.orden > resultado.orden) {
      resultado = nivel;
    }
  }
  return resultado;
}
