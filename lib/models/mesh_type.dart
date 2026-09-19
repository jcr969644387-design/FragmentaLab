/// Contexto de explotacion al que corresponde la malla del ejercicio.
///
/// No describe la forma de la malla (para eso existe `MeshGeometry`), sino el
/// entorno minero en el que esa geometria tiene sentido: un frente o tajeo
/// subterraneo, un banco a cielo abierto, o ambos cuando los parametros caen
/// en la franja comun a los dos metodos.
enum MeshEnvironment { subterranea, superficial, ambas }

extension MeshEnvironmentX on MeshEnvironment {
  String get etiqueta {
    switch (this) {
      case MeshEnvironment.subterranea:
        return 'Malla subterranea';
      case MeshEnvironment.superficial:
        return 'Malla superficial';
      case MeshEnvironment.ambas:
        return 'Ambas: subterranea y superficial';
    }
  }

  /// Texto corto para la insignia de la pantalla de simulacion.
  String get etiquetaCorta {
    switch (this) {
      case MeshEnvironment.subterranea:
        return 'Subterranea';
      case MeshEnvironment.superficial:
        return 'Superficial';
      case MeshEnvironment.ambas:
        return 'Ambas';
    }
  }

  String get descripcion {
    switch (this) {
      case MeshEnvironment.subterranea:
        return 'Los parametros corresponden a perforacion en labores '
            'subterraneas: diametros pequenos, taladros cortos y sin '
            'subperforacion, como en un frente o un tajeo.';
      case MeshEnvironment.superficial:
        return 'Los parametros corresponden a voladura de banco a cielo '
            'abierto: diametros mayores, taladros largos y subperforacion '
            'bajo el piso del banco.';
      case MeshEnvironment.ambas:
        return 'Los parametros caen en la franja comun a los dos metodos: '
            'la misma malla podria plantearse en un banco pequeno o en una '
            'labor subterranea de seccion amplia.';
    }
  }
}

/// Rasgo geometrico evaluado para reconocer el tipo de malla.
///
/// Cada criterio guarda su compatibilidad con los dos metodos por separado,
/// de modo que la pantalla pueda mostrar por que se llego a la clasificacion
/// en lugar de limitarse al resultado.
class MeshTypeCriterion {
  const MeshTypeCriterion({
    required this.nombre,
    required this.valor,
    required this.referencia,
    required this.compatibleSubterranea,
    required this.compatibleSuperficial,
  });

  /// Rasgo evaluado, por ejemplo `Diametro de perforacion`.
  final String nombre;

  /// Valor del ejercicio activo, ya formateado con su unidad.
  final String valor;

  /// Rangos academicos usados para decidir, escritos para el estudiante.
  final String referencia;

  final bool compatibleSubterranea;
  final bool compatibleSuperficial;

  /// `true` cuando el rasgo no distingue entre los dos metodos.
  bool get esComun => compatibleSubterranea && compatibleSuperficial;
}

/// Resultado completo de la clasificacion del tipo de malla.
class MeshTypeAssessment {
  const MeshTypeAssessment({
    required this.tipo,
    required this.criterios,
    required this.coincidenciasSubterranea,
    required this.coincidenciasSuperficial,
    required this.resumen,
  });

  final MeshEnvironment tipo;
  final List<MeshTypeCriterion> criterios;

  /// Numero de rasgos compatibles con cada metodo, sobre `criterios.length`.
  final int coincidenciasSubterranea;
  final int coincidenciasSuperficial;

  /// Lectura en una frase de por que la malla quedo clasificada asi.
  final String resumen;
}
