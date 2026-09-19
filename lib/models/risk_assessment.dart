import 'risk_level.dart';

/// Hallazgo individual del clasificador de riesgo educativo.
class RiskFinding {
  const RiskFinding({
    required this.criterio,
    required this.valor,
    required this.rangoReferencia,
    required this.nivel,
    required this.mensaje,
  });

  final String criterio;
  final String valor;
  final String rangoReferencia;
  final RiskLevel nivel;
  final String mensaje;
}

/// Resultado global de la clasificacion de riesgo conceptual.
class RiskAssessment {
  const RiskAssessment({
    required this.nivel,
    required this.hallazgos,
    required this.puntaje,
  });

  final RiskLevel nivel;
  final List<RiskFinding> hallazgos;

  /// Puntaje 0-100 donde 100 significa que todos los criterios educativos
  /// evaluados quedaron dentro de rango.
  final int puntaje;

  List<RiskFinding> get criticos => hallazgos
      .where((RiskFinding h) => h.nivel == RiskLevel.alto)
      .toList();

  List<RiskFinding> get atencion => hallazgos
      .where((RiskFinding h) => h.nivel == RiskLevel.medio)
      .toList();

  List<RiskFinding> get conformes => hallazgos
      .where((RiskFinding h) => h.nivel == RiskLevel.bajo)
      .toList();
}
