/// Resultados geometricos conceptuales de una malla educativa.
///
/// Todos los valores son geometricos: no existe ninguna magnitud de energia,
/// masa ni carga. El volumen se denomina "conceptual" porque supone un banco
/// ideal sin perdidas, desviacion ni discontinuidades.
class GeometryResult {
  const GeometryResult({
    required this.relacionSobreBurden,
    required this.areaPorTaladroM2,
    required this.totalTaladros,
    required this.volumenPorTaladroM3,
    required this.volumenConceptualM3,
    required this.longitudCargadaConceptualM,
    required this.tacoM,
    required this.relacionTacoBurden,
    required this.burdenEnDiametros,
    required this.espaciamientoEnDiametros,
    required this.subperforacionEnDiametros,
    required this.esbeltez,
    required this.longitudTeoricaM,
    required this.desviacionLongitudRelativa,
    required this.anchoMallaM,
    required this.profundidadMallaM,
  });

  /// Relacion S/B (adimensional).
  final double relacionSobreBurden;

  /// Area teorica influenciada por taladro: B x S.
  final double areaPorTaladroM2;

  final int totalTaladros;

  /// Volumen conceptual por taladro: B x S x H.
  final double volumenPorTaladroM3;

  /// Volumen conceptual total de la malla.
  final double volumenConceptualM3;

  /// Longitud de taladro no ocupada por el taco (solo geometria).
  final double longitudCargadaConceptualM;

  final double tacoM;
  final double relacionTacoBurden;
  final double burdenEnDiametros;
  final double espaciamientoEnDiametros;
  final double subperforacionEnDiametros;

  /// Relacion longitud de perforacion / burden.
  final double esbeltez;

  /// Longitud geometrica teorica: H / cos(inclinacion) + subperforacion.
  final double longitudTeoricaM;

  /// Desviacion relativa entre la longitud ingresada y la teorica.
  final double desviacionLongitudRelativa;

  /// Ancho aproximado cubierto por la malla (direccion del espaciamiento).
  final double anchoMallaM;

  /// Profundidad aproximada cubierta por la malla (direccion del burden).
  final double profundidadMallaM;

  /// Porcentaje de la longitud del taladro ocupado por el taco.
  double get porcentajeTaco {
    final double total = longitudCargadaConceptualM + tacoM;
    if (total <= 0) {
      return 0;
    }
    return (tacoM / total) * 100;
  }
}
