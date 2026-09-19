/// Variable de una formula educativa, con su significado y unidad.
class FormulaVariable {
  const FormulaVariable({
    required this.simbolo,
    required this.nombre,
    required this.unidad,
    this.valor,
  });

  final String simbolo;
  final String nombre;
  final String unidad;
  final String? valor;
}

/// Explicacion completa de un calculo educativo.
///
/// Toda pantalla de calculo de Fragmenta Lab debe mostrar esta estructura:
/// formula, variables, unidades, resultado, interpretacion y limitaciones.
class FormulaExplanation {
  const FormulaExplanation({
    required this.titulo,
    required this.formula,
    required this.variables,
    required this.resultado,
    required this.unidadResultado,
    required this.interpretacion,
    required this.limitaciones,
  });

  final String titulo;
  final String formula;
  final List<FormulaVariable> variables;
  final String resultado;
  final String unidadResultado;
  final String interpretacion;
  final String limitaciones;
}
