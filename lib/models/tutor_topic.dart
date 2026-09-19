/// Tema explicativo del tutor local basado en reglas.
class TutorTopic {
  const TutorTopic({
    required this.id,
    required this.pregunta,
    required this.respuesta,
    required this.palabrasClave,
  });

  final String id;
  final String pregunta;
  final String respuesta;
  final List<String> palabrasClave;
}

/// Respuesta entregada por el tutor.
class TutorAnswer {
  const TutorAnswer({
    required this.titulo,
    required this.contenido,
    required this.origen,
    this.temaRelacionado,
  });

  final String titulo;
  final String contenido;

  /// Origen de la respuesta: util para distinguir reglas locales de una futura
  /// integracion con IA.
  final String origen;

  final TutorTopic? temaRelacionado;
}
