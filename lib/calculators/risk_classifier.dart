import '../models/blast_design.dart';
import '../models/education_config.dart';
import '../models/geometry_result.dart';
import '../models/risk_assessment.dart';
import '../models/risk_level.dart';

/// Clasificador educativo de riesgo geometrico.
///
/// Compara las relaciones geometricas del ejercicio contra los rangos
/// declarados en la configuracion educativa. El resultado es una lectura de
/// aula sobre la coherencia interna del diseno, **no** una calificacion de
/// seguridad operacional.
class RiskClassifier {
  const RiskClassifier(this.config);

  final EducationConfig config;

  RiskAssessment clasificar(BlastDesign d, GeometryResult g) {
    final List<RiskFinding> hallazgos = <RiskFinding>[
      _evaluarRelacionSB(g),
      _evaluarBurdenDiametro(g),
      _evaluarTaco(g),
      _evaluarSubperforacion(g),
      _evaluarEsbeltez(g),
      _evaluarLongitud(g),
      _evaluarGeometria(d, g),
    ];

    final RiskLevel nivel =
        nivelMasSevero(hallazgos.map((RiskFinding h) => h.nivel));

    int puntos = 0;
    for (final RiskFinding h in hallazgos) {
      switch (h.nivel) {
        case RiskLevel.bajo:
          puntos += 2;
        case RiskLevel.medio:
          puntos += 1;
        case RiskLevel.alto:
          puntos += 0;
      }
    }
    final int maximo = hallazgos.length * 2;
    final int puntaje = maximo == 0 ? 0 : ((puntos / maximo) * 100).round();

    return RiskAssessment(
      nivel: nivel,
      hallazgos: hallazgos,
      puntaje: puntaje,
    );
  }

  RiskFinding _evaluarRelacionSB(GeometryResult g) {
    final double v = g.relacionSobreBurden;
    if (config.rangoOptimoSobreBurden.contiene(v)) {
      return RiskFinding(
        criterio: 'Relacion S/B',
        valor: v.toStringAsFixed(2),
        rangoReferencia: 'Optimo educativo ${config.rangoOptimoSobreBurden}',
        nivel: RiskLevel.bajo,
        mensaje: 'La celda es ligeramente mas ancha que profunda, dentro del '
            'rango de referencia usado en clase.',
      );
    }
    if (config.rangoSobreBurden.contiene(v)) {
      return RiskFinding(
        criterio: 'Relacion S/B',
        valor: v.toStringAsFixed(2),
        rangoReferencia: 'Aceptable educativo ${config.rangoSobreBurden}',
        nivel: RiskLevel.medio,
        mensaje: 'La relacion es admisible para el ejercicio pero se aleja del '
            'rango optimo: justifica por que eligiste esta forma de celda.',
      );
    }
    return RiskFinding(
      criterio: 'Relacion S/B',
      valor: v.toStringAsFixed(2),
      rangoReferencia: 'Educativo ${config.rangoSobreBurden}',
      nivel: RiskLevel.alto,
      mensaje: v < config.rangoSobreBurden.min
          ? 'Relacion muy baja: la malla queda alargada en la direccion del '
              'burden y la distribucion conceptual resulta poco uniforme.'
          : 'Relacion muy alta: quedan zonas amplias entre taladros dentro de '
              'la fila, con riesgo conceptual de fragmentacion deficiente.',
    );
  }

  RiskFinding _evaluarBurdenDiametro(GeometryResult g) {
    final double v = g.burdenEnDiametros;
    final Rango r = config.rangoBurdenDiametro;
    if (r.contiene(v)) {
      return RiskFinding(
        criterio: 'Burden en diametros (B/D)',
        valor: '${v.toStringAsFixed(1)} D',
        rangoReferencia: 'Educativo $r',
        nivel: RiskLevel.bajo,
        mensaje: 'El burden guarda una proporcion razonable con el diametro '
            'del taladro para fines academicos.',
      );
    }
    final bool bajo = v < r.min;
    return RiskFinding(
      criterio: 'Burden en diametros (B/D)',
      valor: '${v.toStringAsFixed(1)} D',
      rangoReferencia: 'Educativo $r',
      nivel: bajo && v < r.min * 0.7 || !bajo && v > r.max * 1.3
          ? RiskLevel.alto
          : RiskLevel.medio,
      mensaje: bajo
          ? 'Burden pequeno respecto al diametro: conceptualmente se asocia a '
              'exceso de energia por unidad de roca, mayor proyeccion y mayor '
              'riesgo de sobreexcavacion.'
          : 'Burden grande respecto al diametro: conceptualmente se asocia a '
              'confinamiento elevado, fragmentacion gruesa y aparicion de pie '
              'de banco.',
    );
  }

  RiskFinding _evaluarTaco(GeometryResult g) {
    final double v = g.relacionTacoBurden;
    final Rango r = config.rangoTacoBurden;
    if (r.contiene(v)) {
      return RiskFinding(
        criterio: 'Relacion taco / burden',
        valor: v.toStringAsFixed(2),
        rangoReferencia: 'Educativo $r',
        nivel: RiskLevel.bajo,
        mensaje: 'La longitud de taco guarda proporcion con el burden, lo que '
            'en clase se asocia a un confinamiento adecuado del taladro.',
      );
    }
    if (v < r.min) {
      return RiskFinding(
        criterio: 'Relacion taco / burden',
        valor: v.toStringAsFixed(2),
        rangoReferencia: 'Educativo $r',
        nivel: v < r.min * 0.6 ? RiskLevel.alto : RiskLevel.medio,
        mensaje: 'Taco corto: conceptualmente el confinamiento en la parte '
            'superior del taladro disminuye y aumenta el riesgo teorico de '
            'proyeccion y de onda aerea.',
      );
    }
    return RiskFinding(
      criterio: 'Relacion taco / burden',
      valor: v.toStringAsFixed(2),
      rangoReferencia: 'Educativo $r',
      nivel: v > r.max * 1.4 ? RiskLevel.alto : RiskLevel.medio,
      mensaje: 'Taco largo: la parte superior del banco queda poco influida y '
          'conceptualmente aparecen bloques de gran tamano en la cresta.',
    );
  }

  RiskFinding _evaluarSubperforacion(GeometryResult g) {
    final double v = g.subperforacionEnDiametros;
    final Rango r = config.rangoSubperforacionDiametro;
    if (r.contiene(v)) {
      return RiskFinding(
        criterio: 'Subperforacion en diametros',
        valor: '${v.toStringAsFixed(1)} D',
        rangoReferencia: 'Educativo $r',
        nivel: RiskLevel.bajo,
        mensaje: 'La subperforacion se mantiene en el rango educativo usado '
            'para discutir el control del piso del banco.',
      );
    }
    if (v < r.min) {
      return RiskFinding(
        criterio: 'Subperforacion en diametros',
        valor: '${v.toStringAsFixed(1)} D',
        rangoReferencia: 'Educativo $r',
        nivel: v <= 0 ? RiskLevel.alto : RiskLevel.medio,
        mensaje: 'Subperforacion escasa: conceptualmente se asocia a piso '
            'irregular y aparicion de resaltes al final del banco.',
      );
    }
    return RiskFinding(
      criterio: 'Subperforacion en diametros',
      valor: '${v.toStringAsFixed(1)} D',
      rangoReferencia: 'Educativo $r',
      nivel: v > r.max * 1.5 ? RiskLevel.alto : RiskLevel.medio,
      mensaje: 'Subperforacion excesiva: conceptualmente se asocia a dano bajo '
          'el nivel de piso y a sobreexcavacion innecesaria.',
    );
  }

  RiskFinding _evaluarEsbeltez(GeometryResult g) {
    final double v = g.esbeltez;
    final Rango r = config.rangoEsbeltez;
    if (r.contiene(v)) {
      return RiskFinding(
        criterio: 'Esbeltez (L/B)',
        valor: v.toStringAsFixed(1),
        rangoReferencia: 'Educativo $r',
        nivel: RiskLevel.bajo,
        mensaje: 'La longitud del taladro y el burden guardan una proporcion '
            'coherente para el ejercicio.',
      );
    }
    return RiskFinding(
      criterio: 'Esbeltez (L/B)',
      valor: v.toStringAsFixed(1),
      rangoReferencia: 'Educativo $r',
      nivel: RiskLevel.medio,
      mensaje: v < r.min
          ? 'Taladro corto frente al burden: el banco se comporta como un '
              'bloque muy confinado en el analisis conceptual.'
          : 'Taladro muy largo frente al burden: aumenta la importancia de la '
              'desviacion de perforacion, porque un pequeno error angular '
              'desplaza mucho el fondo del taladro.',
    );
  }

  RiskFinding _evaluarLongitud(GeometryResult g) {
    final double desviacion = g.desviacionLongitudRelativa.abs();
    if (desviacion <= config.toleranciaLongitudPerforacion / 2) {
      return RiskFinding(
        criterio: 'Coherencia de longitud de perforacion',
        valor: '${(g.desviacionLongitudRelativa * 100).toStringAsFixed(1)} %',
        rangoReferencia:
            '± ${(config.toleranciaLongitudPerforacion * 50).toStringAsFixed(0)} %',
        nivel: RiskLevel.bajo,
        mensaje: 'La longitud ingresada coincide con la longitud geometrica '
            'teorica (altura / cos de la inclinacion + subperforacion).',
      );
    }
    if (desviacion <= config.toleranciaLongitudPerforacion) {
      return RiskFinding(
        criterio: 'Coherencia de longitud de perforacion',
        valor: '${(g.desviacionLongitudRelativa * 100).toStringAsFixed(1)} %',
        rangoReferencia:
            '± ${(config.toleranciaLongitudPerforacion * 100).toStringAsFixed(0)} %',
        nivel: RiskLevel.medio,
        mensaje: 'La longitud ingresada se aparta de la longitud teorica: '
            'revisa la altura de banco, la inclinacion y la subperforacion.',
      );
    }
    return RiskFinding(
      criterio: 'Coherencia de longitud de perforacion',
      valor: '${(g.desviacionLongitudRelativa * 100).toStringAsFixed(1)} %',
      rangoReferencia:
          '± ${(config.toleranciaLongitudPerforacion * 100).toStringAsFixed(0)} %',
      nivel: RiskLevel.alto,
      mensaje: 'La longitud ingresada es geometricamente incompatible con la '
          'altura de banco declarada. El ejercicio no es consistente.',
    );
  }

  RiskFinding _evaluarGeometria(BlastDesign d, GeometryResult g) {
    final double relacion = g.relacionSobreBurden;
    switch (d.geometria) {
      case MeshGeometry.cuadrada:
        final bool coherente = (relacion - 1.0).abs() <= 0.05;
        return RiskFinding(
          criterio: 'Coherencia de la geometria declarada',
          valor: 'Cuadrada, S/B = ${relacion.toStringAsFixed(2)}',
          rangoReferencia: 'S/B = 1.00',
          nivel: coherente ? RiskLevel.bajo : RiskLevel.medio,
          mensaje: coherente
              ? 'La malla declarada como cuadrada es consistente con los '
                  'valores de burden y espaciamiento ingresados.'
              : 'Declaraste malla cuadrada pero S/B no es 1.00: la malla real '
                  'ingresada es rectangular.',
        );
      case MeshGeometry.rectangular:
        final bool coherente = (relacion - 1.0).abs() > 0.05;
        return RiskFinding(
          criterio: 'Coherencia de la geometria declarada',
          valor: 'Rectangular, S/B = ${relacion.toStringAsFixed(2)}',
          rangoReferencia: 'S/B distinto de 1.00',
          nivel: coherente ? RiskLevel.bajo : RiskLevel.medio,
          mensaje: coherente
              ? 'La celda rectangular declarada es consistente con los datos '
                  'ingresados.'
              : 'Declaraste malla rectangular pero S/B = 1.00: la malla real '
                  'ingresada es cuadrada.',
        );
      case MeshGeometry.tresbolillo:
        return RiskFinding(
          criterio: 'Coherencia de la geometria declarada',
          valor: 'Tresbolillo, S/B = ${relacion.toStringAsFixed(2)}',
          rangoReferencia: 'Distribucion desplazada media fila',
          nivel: RiskLevel.bajo,
          mensaje: 'En tresbolillo el area por taladro no cambia, pero la '
              'distribucion es mas homogenea que en una malla alineada con la '
              'misma relacion S/B.',
        );
    }
  }
}
