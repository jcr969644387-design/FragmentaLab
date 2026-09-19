/// Tema al que pertenece una pregunta de evaluacion.
enum QuizTopic {
  burden,
  espaciamiento,
  relacionSB,
  diametro,
  taco,
  subperforacion,
  desviacion,
  agua,
  secuencia,
  fragmentacion,
  seguridad,
}

extension QuizTopicX on QuizTopic {
  String get etiqueta {
    switch (this) {
      case QuizTopic.burden:
        return 'Burden';
      case QuizTopic.espaciamiento:
        return 'Espaciamiento';
      case QuizTopic.relacionSB:
        return 'Relacion S/B';
      case QuizTopic.diametro:
        return 'Diametro de perforacion';
      case QuizTopic.taco:
        return 'Taco';
      case QuizTopic.subperforacion:
        return 'Subperforacion';
      case QuizTopic.desviacion:
        return 'Desviacion de taladros';
      case QuizTopic.agua:
        return 'Influencia del agua';
      case QuizTopic.secuencia:
        return 'Secuencia de retardos';
      case QuizTopic.fragmentacion:
        return 'Fragmentacion';
      case QuizTopic.seguridad:
        return 'Seguridad en voladura';
    }
  }
}

/// Pregunta de seleccion multiple con explicacion tecnica.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.tema,
    required this.enunciado,
    required this.opciones,
    required this.indiceCorrecto,
    required this.explicacion,
  });

  final String id;
  final QuizTopic tema;
  final String enunciado;
  final List<String> opciones;
  final int indiceCorrecto;
  final String explicacion;

  String get respuestaCorrecta => opciones[indiceCorrecto];
}

/// Respuesta registrada por el estudiante.
class QuizAnswer {
  const QuizAnswer({
    required this.pregunta,
    required this.indiceSeleccionado,
  });

  final QuizQuestion pregunta;
  final int indiceSeleccionado;

  bool get esCorrecta => indiceSeleccionado == pregunta.indiceCorrecto;
}

/// Resultado final de una evaluacion.
class QuizResult {
  const QuizResult({
    required this.respuestas,
    required this.correctas,
    required this.total,
  });

  final List<QuizAnswer> respuestas;
  final int correctas;
  final int total;

  double get porcentaje => total == 0 ? 0 : (correctas / total) * 100;

  int get incorrectas => total - correctas;

  List<QuizAnswer> get errores =>
      respuestas.where((QuizAnswer r) => !r.esCorrecta).toList();

  String get valoracion {
    final double p = porcentaje;
    if (p >= 90) {
      return 'Dominio solido de los conceptos geometricos evaluados.';
    }
    if (p >= 70) {
      return 'Buen nivel. Revisa los temas donde aparecieron errores.';
    }
    if (p >= 50) {
      return 'Nivel intermedio. Conviene repasar el modulo de parametros '
          'tecnicos y volver a intentarlo.';
    }
    return 'Nivel inicial. Recorre el tutor local y el glosario de parametros '
        'antes de repetir la evaluacion.';
  }
}
