import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/calculators/geometry_calculator.dart';
import 'package:fragmenta_lab/models/blast_design.dart';
import 'package:fragmenta_lab/models/education_config.dart';
import 'package:fragmenta_lab/models/tutor_topic.dart';
import 'package:fragmenta_lab/services/tutor_service.dart';

void main() {
  const LocalRuleTutorEngine tutor = LocalRuleTutorEngine();
  final EducationConfig config = EducationConfig.porDefecto();
  const GeometryCalculator geometria = GeometryCalculator();

  group('Tutor local basado en reglas', () {
    test('no requiere conexion', () {
      expect(tutor.requiereConexion, isFalse);
      expect(tutor.nombre.isNotEmpty, isTrue);
    });

    test('cubre los temas obligatorios del MVP', () {
      final List<String> ids =
          tutor.temas().map((TutorTopic t) => t.id).toList();
      for (final String esperado in <String>[
        'burden_grande',
        'burden_pequeno',
        'espaciamiento',
        'relacion_sb',
        'diametro',
        'taco',
        'subperforacion',
        'desviacion',
        'agua',
        'secuencia',
      ]) {
        expect(ids, contains(esperado));
      }
    });

    test('responde por palabras clave', () async {
      final TutorAnswer r =
          await tutor.responder('que pasa si el burden es muy grande');
      expect(r.temaRelacionado?.id, 'burden_grande');
      expect(r.origen, 'reglas locales');
    });

    test('indica cuando la consulta esta vacia', () async {
      final TutorAnswer r = await tutor.responder('   ');
      expect(r.titulo, contains('Escribe'));
    });

    test('admite no tener respuesta en vez de improvisar', () async {
      final TutorAnswer r = await tutor.responder('zzz qqq xyz');
      expect(r.temaRelacionado, isNull);
      expect(r.titulo, contains('Sin coincidencia'));
    });

    test('diagnostica el ejercicio activo', () {
      final BlastDesign d = BlastDesign.ejemploEducativo();
      final List<String> notas =
          tutor.diagnosticar(d, geometria.calcular(d), config);
      expect(notas, isNotEmpty);
    });

    test('detecta un burden fuera de rango en el diagnostico', () {
      final BlastDesign d =
          BlastDesign.ejemploEducativo().copyWith(burdenM: 8.0);
      final List<String> notas =
          tutor.diagnosticar(d, geometria.calcular(d), config);
      expect(
        notas.any((String n) => n.contains('por encima del rango educativo')),
        isTrue,
      );
    });
  });

  group('Motor remoto reservado', () {
    test('declara que requiere conexion y no se ejecuta en el MVP', () async {
      const RemoteTutorEngine remoto = RemoteTutorEngine();
      expect(remoto.requiereConexion, isTrue);
      expect(remoto.temas(), isEmpty);
      // El motor remoto existe solo como punto de extension: invocarlo en el
      // MVP debe fallar de forma explicita, nunca hacer una llamada de red.
      await expectLater(
        remoto.responder('consulta'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
