/// Severidad de un mensaje de validacion.
enum IssueSeverity { informacion, advertencia, error }

/// Mensaje de validacion asociado a un campo del diseno educativo.
class ValidationIssue {
  const ValidationIssue({
    required this.campo,
    required this.mensaje,
    required this.severidad,
  });

  final String campo;
  final String mensaje;
  final IssueSeverity severidad;

  @override
  String toString() => '[${severidad.name}] $campo: $mensaje';
}

/// Resultado de validar un conjunto de parametros.
class ValidationResult {
  const ValidationResult(this.issues);

  const ValidationResult.valido() : issues = const <ValidationIssue>[];

  final List<ValidationIssue> issues;

  List<ValidationIssue> get errores => issues
      .where((ValidationIssue e) => e.severidad == IssueSeverity.error)
      .toList();

  List<ValidationIssue> get advertencias => issues
      .where((ValidationIssue e) => e.severidad == IssueSeverity.advertencia)
      .toList();

  List<ValidationIssue> get informativos => issues
      .where((ValidationIssue e) => e.severidad == IssueSeverity.informacion)
      .toList();

  /// Un diseno es calculable cuando no existen errores bloqueantes.
  bool get esValido => errores.isEmpty;

  bool get tieneAdvertencias => advertencias.isNotEmpty;

  int get total => issues.length;
}
