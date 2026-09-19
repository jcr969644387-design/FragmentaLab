import 'risk_level.dart';

/// Resultado cualitativo de la evaluacion conceptual de una malla.
///
/// No es una prediccion: es la salida de un conjunto de reglas educativas
/// declaradas en `docs/formulas.md`, pensadas para que el estudiante observe
/// tendencias al mover un parametro a la vez.
class FragmentationOutlook {
  const FragmentationOutlook({
    required this.indiceEficiencia,
    required this.fragmentacion,
    required this.desplazamiento,
    required this.uniformidad,
    required this.sobreexcavacion,
    required this.subexcavacion,
    required this.nivelRiesgo,
    required this.observaciones,
  });

  /// Indice conceptual 0-100. Solo sirve para comparar variantes del mismo
  /// ejercicio entre si.
  final int indiceEficiencia;

  final String fragmentacion;
  final String desplazamiento;
  final String uniformidad;
  final String sobreexcavacion;
  final String subexcavacion;
  final RiskLevel nivelRiesgo;
  final List<String> observaciones;

  double get eficienciaNormalizada => indiceEficiencia / 100.0;
}
