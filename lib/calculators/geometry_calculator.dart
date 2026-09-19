import 'dart:math' as math;

import '../models/blast_design.dart';
import '../models/geometry_result.dart';

/// Calculadora geometrica conceptual de la malla.
///
/// Contiene unicamente relaciones geometricas y de conteo. No calcula energia,
/// masa de explosivo, factor de carga ni ningun parametro que permita ejecutar
/// una voladura: su unico proposito es que el estudiante entienda como se
/// relacionan las dimensiones de una malla.
class GeometryCalculator {
  const GeometryCalculator();

  /// Convierte el diametro del taladro de milimetros a metros.
  double diametroEnMetros(double diametroMm) => diametroMm / 1000.0;

  /// Relacion S/B (adimensional).
  double relacionSobreBurden(double espaciamientoM, double burdenM) {
    if (burdenM <= 0) {
      return 0;
    }
    return espaciamientoM / burdenM;
  }

  /// Area teorica influenciada por taladro: B x S.
  ///
  /// En tresbolillo el area por taladro se mantiene igual, pero la
  /// distribucion de la energia disponible es mas homogenea. Esa diferencia se
  /// evalua en el indice de uniformidad, no en el area.
  double areaPorTaladro(double burdenM, double espaciamientoM) {
    if (burdenM <= 0 || espaciamientoM <= 0) {
      return 0;
    }
    return burdenM * espaciamientoM;
  }

  /// Numero total de taladros de la malla.
  int totalTaladros(int filas, int taladrosPorFila) {
    if (filas <= 0 || taladrosPorFila <= 0) {
      return 0;
    }
    return filas * taladrosPorFila;
  }

  /// Volumen geometrico conceptual por taladro: B x S x H.
  double volumenPorTaladro(
    double burdenM,
    double espaciamientoM,
    double alturaBancoM,
  ) {
    if (alturaBancoM <= 0) {
      return 0;
    }
    return areaPorTaladro(burdenM, espaciamientoM) * alturaBancoM;
  }

  /// Longitud del taladro no ocupada por el taco (solo geometria).
  double longitudCargadaConceptual(
    double longitudPerforacionM,
    double tacoM,
  ) {
    final double resto = longitudPerforacionM - tacoM;
    return resto <= 0 ? 0 : resto;
  }

  /// Longitud geometrica teorica: H / cos(inclinacion) + subperforacion.
  double longitudTeorica(
    double alturaBancoM,
    double subperforacionM,
    double inclinacionGrados,
  ) {
    final double radianes = inclinacionGrados * math.pi / 180.0;
    final double coseno = math.cos(radianes);
    if (coseno <= 0) {
      return alturaBancoM + subperforacionM;
    }
    return (alturaBancoM / coseno) + subperforacionM;
  }

  /// Relacion longitud de perforacion / burden (esbeltez del banco).
  double esbeltez(double longitudPerforacionM, double burdenM) {
    if (burdenM <= 0) {
      return 0;
    }
    return longitudPerforacionM / burdenM;
  }

  /// Expresa una longitud como multiplo del diametro del taladro.
  double enDiametros(double longitudM, double diametroMm) {
    final double diametroM = diametroEnMetros(diametroMm);
    if (diametroM <= 0) {
      return 0;
    }
    return longitudM / diametroM;
  }

  /// Calcula todos los resultados geometricos de un diseno.
  GeometryResult calcular(BlastDesign d) {
    final double area = areaPorTaladro(d.burdenM, d.espaciamientoM);
    final int taladros = totalTaladros(d.filas, d.taladrosPorFila);
    final double volumenTaladro = volumenPorTaladro(
      d.burdenM,
      d.espaciamientoM,
      d.alturaBancoM,
    );
    final double teorica = longitudTeorica(
      d.alturaBancoM,
      d.subperforacionM,
      d.inclinacionGrados,
    );
    final double desviacion =
        teorica <= 0 ? 0 : (d.longitudPerforacionM - teorica) / teorica;

    return GeometryResult(
      relacionSobreBurden: relacionSobreBurden(d.espaciamientoM, d.burdenM),
      areaPorTaladroM2: area,
      totalTaladros: taladros,
      volumenPorTaladroM3: volumenTaladro,
      volumenConceptualM3: volumenTaladro * taladros,
      longitudCargadaConceptualM: longitudCargadaConceptual(
        d.longitudPerforacionM,
        d.tacoM,
      ),
      tacoM: d.tacoM,
      relacionTacoBurden: d.burdenM <= 0 ? 0 : d.tacoM / d.burdenM,
      burdenEnDiametros: enDiametros(d.burdenM, d.diametroMm),
      espaciamientoEnDiametros: enDiametros(d.espaciamientoM, d.diametroMm),
      subperforacionEnDiametros: enDiametros(d.subperforacionM, d.diametroMm),
      esbeltez: esbeltez(d.longitudPerforacionM, d.burdenM),
      longitudTeoricaM: teorica,
      desviacionLongitudRelativa: desviacion,
      anchoMallaM: d.taladrosPorFila <= 0
          ? 0
          : (d.taladrosPorFila - 1) * d.espaciamientoM,
      profundidadMallaM: d.filas <= 0 ? 0 : (d.filas - 1) * d.burdenM,
    );
  }
}
