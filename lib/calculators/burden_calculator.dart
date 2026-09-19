import '../models/education_config.dart';
import '../models/formula_explanation.dart';

/// Calculadora educativa de burden y espaciamiento.
///
/// El modelo es deliberadamente **configurable y no universal**: el burden se
/// expresa como multiplo del diametro y el espaciamiento como relacion del
/// burden. Los coeficientes viven en `assets/config/education_config.json`
/// justamente para que el estudiante compruebe que no existe una unica formula
/// valida para todos los casos.
class BurdenCalculator {
  const BurdenCalculator(this.config);

  final EducationConfig config;

  /// B = k_B x D, con D en metros.
  double burdenDesdeDiametro(double diametroMm, {double? factor}) {
    final double k = factor ?? config.factorBurdenDiametro;
    if (diametroMm <= 0 || k <= 0) {
      return 0;
    }
    return (diametroMm / 1000.0) * k;
  }

  /// S = k_S x B.
  double espaciamientoDesdeBurden(double burdenM, {double? factor}) {
    final double k = factor ?? config.factorEspaciamientoBurden;
    if (burdenM <= 0 || k <= 0) {
      return 0;
    }
    return burdenM * k;
  }

  /// Relacion S/B (adimensional).
  double relacionSobreBurden(double espaciamientoM, double burdenM) {
    if (burdenM <= 0) {
      return 0;
    }
    return espaciamientoM / burdenM;
  }

  /// Factor inverso: cuantos diametros representa un burden dado.
  double factorImplicito(double burdenM, double diametroMm) {
    if (diametroMm <= 0) {
      return 0;
    }
    return burdenM / (diametroMm / 1000.0);
  }

  /// Explicacion completa del calculo de burden.
  FormulaExplanation explicarBurden(double diametroMm, {double? factor}) {
    final double k = factor ?? config.factorBurdenDiametro;
    final double burden = burdenDesdeDiametro(diametroMm, factor: k);
    return FormulaExplanation(
      titulo: 'Burden a partir del diametro',
      formula: 'B = k_B x D',
      variables: <FormulaVariable>[
        FormulaVariable(
          simbolo: 'B',
          nombre: 'Burden (distancia a la cara libre)',
          unidad: 'm',
          valor: burden.toStringAsFixed(2),
        ),
        FormulaVariable(
          simbolo: 'k_B',
          nombre: 'Coeficiente educativo configurable',
          unidad: 'adimensional',
          valor: k.toStringAsFixed(2),
        ),
        FormulaVariable(
          simbolo: 'D',
          nombre: 'Diametro del taladro',
          unidad: 'm',
          valor: (diametroMm / 1000.0).toStringAsFixed(3),
        ),
      ],
      resultado: burden.toStringAsFixed(2),
      unidadResultado: 'm',
      interpretacion: _interpretarFactorBurden(k, burden),
      limitaciones:
          'El coeficiente k_B no es una constante universal. En la practica el '
          'burden depende de la roca, de la categoria de energia disponible, '
          'del equipo de perforacion, de la altura y confinamiento del banco, '
          'de la presencia de agua y de la experiencia de campo del equipo. '
          'Este resultado es un ejercicio geometrico de aula.',
    );
  }

  /// Explicacion completa del calculo de espaciamiento.
  FormulaExplanation explicarEspaciamiento(double burdenM, {double? factor}) {
    final double k = factor ?? config.factorEspaciamientoBurden;
    final double espaciamiento = espaciamientoDesdeBurden(burdenM, factor: k);
    return FormulaExplanation(
      titulo: 'Espaciamiento a partir del burden',
      formula: 'S = k_S x B',
      variables: <FormulaVariable>[
        FormulaVariable(
          simbolo: 'S',
          nombre: 'Espaciamiento entre taladros de una fila',
          unidad: 'm',
          valor: espaciamiento.toStringAsFixed(2),
        ),
        FormulaVariable(
          simbolo: 'k_S',
          nombre: 'Relacion educativa configurable S/B',
          unidad: 'adimensional',
          valor: k.toStringAsFixed(2),
        ),
        FormulaVariable(
          simbolo: 'B',
          nombre: 'Burden',
          unidad: 'm',
          valor: burdenM.toStringAsFixed(2),
        ),
      ],
      resultado: espaciamiento.toStringAsFixed(2),
      unidadResultado: 'm',
      interpretacion: _interpretarRelacion(k),
      limitaciones:
          'La relacion S/B no define por si sola la calidad de un diseno: '
          'interactua con la geometria de la malla, la secuencia de salida y '
          'las estructuras geologicas presentes. Usar un unico valor como '
          'regla universal es un error conceptual frecuente.',
    );
  }

  /// Explicacion de la relacion S/B a partir de dos longitudes conocidas.
  FormulaExplanation explicarRelacion(double espaciamientoM, double burdenM) {
    final double relacion = relacionSobreBurden(espaciamientoM, burdenM);
    return FormulaExplanation(
      titulo: 'Relacion espaciamiento / burden',
      formula: 'S/B = S ÷ B',
      variables: <FormulaVariable>[
        FormulaVariable(
          simbolo: 'S',
          nombre: 'Espaciamiento',
          unidad: 'm',
          valor: espaciamientoM.toStringAsFixed(2),
        ),
        FormulaVariable(
          simbolo: 'B',
          nombre: 'Burden',
          unidad: 'm',
          valor: burdenM.toStringAsFixed(2),
        ),
      ],
      resultado: relacion.toStringAsFixed(2),
      unidadResultado: 'adimensional',
      interpretacion: _interpretarRelacion(relacion),
      limitaciones:
          'La relacion S/B describe la forma de la celda, no su tamano. Dos '
          'mallas con la misma relacion pueden comportarse de manera muy '
          'distinta si el tamano absoluto o el diametro cambian.',
    );
  }

  String _interpretarFactorBurden(double k, double burden) {
    final String base =
        'Con k_B = ${k.toStringAsFixed(2)} el burden resulta '
        '${burden.toStringAsFixed(2)} m. ';
    if (!config.rangoBurdenDiametro.contiene(k)) {
      return '$base El coeficiente esta fuera del rango educativo '
          '(${config.rangoBurdenDiametro}). Analiza en clase que consecuencias '
          'conceptuales tendria: valores muy bajos concentran energia junto a '
          'la cara libre y valores muy altos aumentan el confinamiento.';
    }
    if (k < config.rangoBurdenDiametro.centro) {
      return '$base El coeficiente esta en la mitad baja del rango educativo: '
          'la malla tiende a ser mas cerrada, con fragmentacion mas fina y '
          'mayor riesgo conceptual de proyeccion.';
    }
    return '$base El coeficiente esta en la mitad alta del rango educativo: '
        'la malla tiende a ser mas abierta, con fragmentacion mas gruesa y '
        'mayor confinamiento conceptual.';
  }

  String _interpretarRelacion(double relacion) {
    if (relacion <= 0) {
      return 'No es posible interpretar la relacion con los datos ingresados.';
    }
    if (relacion < config.rangoOptimoSobreBurden.min) {
      return 'Relacion S/B = ${relacion.toStringAsFixed(2)}: la celda es mas '
          'profunda que ancha. Conceptualmente los taladros interactuan poco '
          'entre si dentro de la fila y mucho con la cara libre, lo que suele '
          'asociarse a una distribucion menos uniforme.';
    }
    if (config.rangoOptimoSobreBurden.contiene(relacion)) {
      return 'Relacion S/B = ${relacion.toStringAsFixed(2)}: se encuentra en el '
          'rango educativo de referencia (${config.rangoOptimoSobreBurden}), '
          'donde la celda es ligeramente mas ancha que profunda.';
    }
    if (config.rangoSobreBurden.contiene(relacion)) {
      return 'Relacion S/B = ${relacion.toStringAsFixed(2)}: la celda es '
          'claramente mas ancha que profunda. Conceptualmente aumenta la '
          'interaccion dentro de la fila y puede quedar material grueso entre '
          'taladros si la geometria no se compensa.';
    }
    return 'Relacion S/B = ${relacion.toStringAsFixed(2)}: esta fuera del rango '
        'educativo configurado (${config.rangoSobreBurden}). Revisa los datos '
        'de entrada antes de interpretar el resultado.';
  }
}
