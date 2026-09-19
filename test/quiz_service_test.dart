import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/models/quiz.dart';
import 'package:fragmenta_lab/services/quiz_service.dart';

void main() {
  const QuizService servicio = QuizService();
  final List<QuizQuestion> preguntas = servicio.preguntas();

  group('Banco de preguntas', () {
    test('contiene quince preguntas', () {
      expect(servicio.total, 15);
      expect(preguntas.length, 15);
    });

    test('todas las preguntas tienen identificador unico', () {
      final Set<String> ids =
          preguntas.map((QuizQuestion p) => p.id).toSet();
      expect(ids.length, preguntas.length);
    });

    test('el indice correcto es valido y el enunciado no esta vacio', () {
      for (final QuizQuestion p in preguntas) {
        expect(p.opciones.length, greaterThanOrEqualTo(3));
        expect(p.indiceCorrecto, greaterThanOrEqualTo(0));
        expect(p.indiceCorrecto, lessThan(p.opciones.length));
        expect(p.enunciado.isNotEmpty, isTrue);
        expect(p.explicacion.isNotEmpty, isTrue);
        expect(p.respuestaCorrecta, p.opciones[p.indiceCorrecto]);
      }
    });

    test('cubre los temas obligatorios del curso', () {
      final Set<QuizTopic> temas =
          preguntas.map((QuizQuestion p) => p.tema).toSet();
      for (final QuizTopic esperado in <QuizTopic>[
        QuizTopic.burden,
        QuizTopic.espaciamiento,
        QuizTopic.relacionSB,
        QuizTopic.diametro,
        QuizTopic.taco,
        QuizTopic.subperforacion,
        QuizTopic.desviacion,
        QuizTopic.agua,
        QuizTopic.secuencia,
        QuizTopic.fragmentacion,
        QuizTopic.seguridad,
      ]) {
        expect(temas, contains(esperado));
      }
    });
  });

  group('Calificacion', () {
    test('cuenta correctamente las respuestas acertadas', () {
      final List<QuizAnswer> respuestas = preguntas
          .map(
            (QuizQuestion p) => QuizAnswer(
              pregunta: p,
              indiceSeleccionado: p.indiceCorrecto,
            ),
          )
          .toList();
      final QuizResult r = servicio.calificar(respuestas);
      expect(r.correctas, 15);
      expect(r.incorrectas, 0);
      expect(r.porcentaje, 100);
      expect(r.errores, isEmpty);
    });

    test('registra errores y los agrupa por tema', () {
      final List<QuizAnswer> respuestas = preguntas
          .map(
            (QuizQuestion p) => QuizAnswer(
              pregunta: p,
              indiceSeleccionado: (p.indiceCorrecto + 1) % p.opciones.length,
            ),
          )
          .toList();
      final QuizResult r = servicio.calificar(respuestas);
      expect(r.correctas, 0);
      expect(r.incorrectas, 15);
      expect(r.errores.length, 15);
      final Map<QuizTopic, int> porTema = servicio.erroresPorTema(respuestas);
      expect(porTema.isNotEmpty, isTrue);
      expect(
        porTema.values.reduce((int a, int b) => a + b),
        15,
      );
    });

    test('la valoracion cambia segun el desempeno', () {
      final List<QuizAnswer> todasBien = preguntas
          .map(
            (QuizQuestion p) => QuizAnswer(
              pregunta: p,
              indiceSeleccionado: p.indiceCorrecto,
            ),
          )
          .toList();
      final List<QuizAnswer> todasMal = preguntas
          .map(
            (QuizQuestion p) => QuizAnswer(
              pregunta: p,
              indiceSeleccionado: (p.indiceCorrecto + 1) % p.opciones.length,
            ),
          )
          .toList();
      expect(
        servicio.calificar(todasBien).valoracion,
        isNot(servicio.calificar(todasMal).valoracion),
      );
    });
  });
}
