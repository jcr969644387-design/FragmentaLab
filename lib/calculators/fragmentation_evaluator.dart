import '../models/blast_design.dart';
import '../models/delay_sequence.dart';
import '../models/education_config.dart';
import '../models/explosive_concept.dart';
import '../models/fragmentation_outlook.dart';
import '../models/geometry_result.dart';
import '../models/risk_level.dart';
import '../models/rock_context.dart';

/// Evaluador conceptual de fragmentacion, desplazamiento y eficiencia.
///
/// Implementa un sistema de reglas cualitativas documentado en
/// `docs/formulas.md`. No es un modelo fisico ni predictivo: su proposito es
/// que el estudiante observe **tendencias** al modificar un parametro a la vez
/// y pueda explicar por que cambia el resultado.
class FragmentationEvaluator {
  const FragmentationEvaluator(this.config);

  final EducationConfig config;

  FragmentationOutlook evaluar(BlastDesign d, GeometryResult g) {
    final List<String> observaciones = <String>[];
    double puntaje = 50;

    // Regla 1: forma de la celda (relacion S/B).
    final double sb = g.relacionSobreBurden;
    if (config.rangoOptimoSobreBurden.contiene(sb)) {
      puntaje += 12;
      observaciones.add(
        'La relacion S/B esta en el rango educativo de referencia, lo que se '
        'asocia conceptualmente a una distribucion regular en la fila.',
      );
    } else if (config.rangoSobreBurden.contiene(sb)) {
      puntaje += 4;
      observaciones.add(
        'La relacion S/B es admisible pero se aleja del rango de referencia: '
        'la celda deja de ser equilibrada.',
      );
    } else {
      puntaje -= 15;
      observaciones.add(
        'La relacion S/B queda fuera del rango educativo: la geometria domina '
        'negativamente el resultado conceptual.',
      );
    }

    // Regla 2: burden expresado en diametros.
    final double bd = g.burdenEnDiametros;
    if (config.rangoBurdenDiametro.contiene(bd)) {
      puntaje += 8;
    } else if (bd < config.rangoBurdenDiametro.min) {
      puntaje -= 10;
      observaciones.add(
        'Burden pequeno en relacion al diametro: conceptualmente se asocia a '
        'fragmentacion mas fina pero con mayor riesgo de proyeccion.',
      );
    } else {
      puntaje -= 15;
      observaciones.add(
        'Burden grande en relacion al diametro: conceptualmente se asocia a '
        'fragmentacion gruesa y a la aparicion de pie de banco.',
      );
    }

    // Regla 3: confinamiento superior (taco / burden).
    final double tb = g.relacionTacoBurden;
    if (config.rangoTacoBurden.contiene(tb)) {
      puntaje += 8;
    } else if (tb < config.rangoTacoBurden.min) {
      puntaje -= 15;
      observaciones.add(
        'Taco corto: el confinamiento superior disminuye y aumenta el riesgo '
        'conceptual de proyeccion y onda aerea.',
      );
    } else {
      puntaje -= 10;
      observaciones.add(
        'Taco largo: la cresta del banco queda poco influida y aparecen '
        'bloques gruesos en la parte superior.',
      );
    }

    // Regla 4: control del piso (subperforacion en diametros).
    final double jd = g.subperforacionEnDiametros;
    if (config.rangoSubperforacionDiametro.contiene(jd)) {
      puntaje += 4;
    } else if (jd < config.rangoSubperforacionDiametro.min) {
      puntaje -= 10;
    } else {
      puntaje -= 8;
    }

    // Regla 5: relacion entre categoria energetica y dureza de la roca.
    final double balance = d.energia.indiceRelativo / d.dureza.indice;
    if (balance >= 0.95 && balance <= 1.35) {
      puntaje += 8;
    } else if (balance < 0.95) {
      puntaje -= 12;
      observaciones.add(
        'La categoria energetica seleccionada es baja frente a la dureza '
        'declarada de la roca: conceptualmente la fragmentacion tiende a ser '
        'mas gruesa.',
      );
    } else {
      puntaje -= 6;
      observaciones.add(
        'La categoria energetica es alta frente a la dureza declarada: '
        'conceptualmente aumenta el desplazamiento y el riesgo de proyeccion.',
      );
    }

    // Regla 6: compatibilidad conceptual con la presencia de agua.
    if (d.agua != WaterPresence.seco &&
        d.resistenciaAgua == WaterResistance.baja) {
      puntaje -= 15;
      observaciones.add(
        'Se declaro presencia de agua junto con una categoria de baja '
        'resistencia al agua: conceptualmente la energia disponible se degrada '
        'y el resultado pierde uniformidad.',
      );
    } else if (d.agua == WaterPresence.saturado) {
      puntaje -= 3;
      observaciones.add(
        'Con taladros con agua, la seleccion conceptual de categoria debe '
        'priorizar resistencia al agua antes que energia.',
      );
    }

    // Regla 7: uniformidad segun geometria declarada.
    if (d.geometria == MeshGeometry.tresbolillo) {
      puntaje += 4;
    }

    // Regla 8: esbeltez del taladro.
    if (!config.rangoEsbeltez.contiene(g.esbeltez)) {
      puntaje -= 6;
    }

    // Regla 9: coherencia geometrica de la longitud de perforacion.
    if (g.desviacionLongitudRelativa.abs() >
        config.toleranciaLongitudPerforacion) {
      puntaje -= 10;
      observaciones.add(
        'La longitud de perforacion no es coherente con la altura de banco: '
        'cualquier lectura de eficiencia queda invalidada.',
      );
    }

    final int indice = puntaje.clamp(5.0, 95.0).round();

    return FragmentationOutlook(
      indiceEficiencia: indice,
      fragmentacion: _etiquetaFragmentacion(sb, bd, balance),
      desplazamiento: _etiquetaDesplazamiento(d, balance, tb),
      uniformidad: _etiquetaUniformidad(d, sb),
      sobreexcavacion: _etiquetaSobreexcavacion(jd, bd),
      subexcavacion: _etiquetaSubexcavacion(jd, bd),
      nivelRiesgo: _nivel(indice),
      observaciones: observaciones.isEmpty
          ? <String>[
              'El conjunto de relaciones geometricas se mantiene dentro de los '
                  'rangos educativos configurados.',
            ]
          : observaciones,
    );
  }

  String _etiquetaFragmentacion(double sb, double bd, double balance) {
    double tendencia = 0;
    if (bd > config.rangoBurdenDiametro.max) {
      tendencia += 2;
    } else if (bd > config.rangoBurdenDiametro.centro) {
      tendencia += 1;
    } else if (bd < config.rangoBurdenDiametro.min) {
      tendencia -= 2;
    } else {
      tendencia -= 1;
    }
    if (!config.rangoOptimoSobreBurden.contiene(sb)) {
      tendencia += 1;
    }
    if (balance < 0.95) {
      tendencia += 1;
    } else if (balance > 1.35) {
      tendencia -= 1;
    }

    if (tendencia >= 2) {
      return 'Tendencia a fragmentacion gruesa';
    }
    if (tendencia <= -2) {
      return 'Tendencia a fragmentacion fina';
    }
    return 'Tendencia a fragmentacion media';
  }

  String _etiquetaDesplazamiento(BlastDesign d, double balance, double tb) {
    if (balance > 1.35 || tb < config.rangoTacoBurden.min) {
      return 'Desplazamiento conceptual alto';
    }
    if (balance < 0.95) {
      return 'Desplazamiento conceptual bajo';
    }
    if (d.secuencia == DelayPattern.uniforme) {
      return 'Desplazamiento conceptual concentrado en el frente';
    }
    return 'Desplazamiento conceptual moderado';
  }

  String _etiquetaUniformidad(BlastDesign d, double sb) {
    final bool geometriaFavorable = d.geometria == MeshGeometry.tresbolillo;
    final bool relacionFavorable = config.rangoOptimoSobreBurden.contiene(sb);
    if (geometriaFavorable && relacionFavorable) {
      return 'Distribucion conceptual homogenea';
    }
    if (geometriaFavorable || relacionFavorable) {
      return 'Distribucion conceptual aceptable';
    }
    return 'Distribucion conceptual irregular';
  }

  String _etiquetaSobreexcavacion(double jd, double bd) {
    if (jd > config.rangoSubperforacionDiametro.max ||
        bd < config.rangoBurdenDiametro.min) {
      return 'Riesgo conceptual de sobreexcavacion: alto';
    }
    if (jd > config.rangoSubperforacionDiametro.centro) {
      return 'Riesgo conceptual de sobreexcavacion: moderado';
    }
    return 'Riesgo conceptual de sobreexcavacion: bajo';
  }

  String _etiquetaSubexcavacion(double jd, double bd) {
    if (jd < config.rangoSubperforacionDiametro.min ||
        bd > config.rangoBurdenDiametro.max) {
      return 'Riesgo conceptual de subexcavacion o pie de banco: alto';
    }
    if (jd < config.rangoSubperforacionDiametro.centro) {
      return 'Riesgo conceptual de subexcavacion o pie de banco: moderado';
    }
    return 'Riesgo conceptual de subexcavacion o pie de banco: bajo';
  }

  RiskLevel _nivel(int indice) {
    if (indice >= 70) {
      return RiskLevel.bajo;
    }
    if (indice >= 45) {
      return RiskLevel.medio;
    }
    return RiskLevel.alto;
  }
}
