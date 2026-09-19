import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/calculators/delay_sequencer.dart';
import 'package:fragmenta_lab/models/delay_sequence.dart';

void main() {
  const DelaySequencer secuenciador = DelaySequencer();

  DelayPlan generar(DelayPattern patron) => secuenciador.generar(
        patron: patron,
        filas: 3,
        taladrosPorFila: 4,
      );

  group('Secuencia de retardos', () {
    test('genera un paso por taladro', () {
      final DelayPlan plan = generar(DelayPattern.porFilas);
      expect(plan.totalTaladros, 12);
      expect(plan.pasos.length, 12);
    });

    test('la secuencia uniforme usa un solo orden', () {
      final DelayPlan plan = generar(DelayPattern.uniforme);
      expect(plan.ordenesDistintos, 1);
      expect(plan.pasos.every((DelayStep p) => p.orden == 1), isTrue);
      expect(
        plan.pasos.every((DelayStep p) => p.intervaloRelativo == 0),
        isTrue,
      );
    });

    test('la secuencia por filas usa un orden por fila', () {
      final DelayPlan plan = generar(DelayPattern.porFilas);
      expect(plan.ordenesDistintos, 3);
      expect(plan.taladrosPorOrden, closeTo(4.0, 1e-9));
      final DelayStep primero =
          plan.pasos.firstWhere((DelayStep p) => p.fila == 0);
      expect(primero.orden, 1);
      final DelayStep ultimo =
          plan.pasos.firstWhere((DelayStep p) => p.fila == 2);
      expect(ultimo.orden, 3);
    });

    test('la secuencia por taladros usa un orden por taladro', () {
      final DelayPlan plan = generar(DelayPattern.porTaladros);
      expect(plan.ordenesDistintos, 12);
      expect(plan.taladrosPorOrden, closeTo(1.0, 1e-9));
      expect(
        plan.pasos.map((DelayStep p) => p.orden).reduce(
              (int a, int b) => a > b ? a : b,
            ),
        12,
      );
    });

    test('la secuencia escalonada avanza en diagonal', () {
      final DelayPlan plan = generar(DelayPattern.escalonada);
      // filas + columnas - 1 diagonales distintas.
      expect(plan.ordenesDistintos, 6);
      final DelayStep esquina = plan.pasos.firstWhere(
        (DelayStep p) => p.fila == 0 && p.columna == 0,
      );
      expect(esquina.orden, 1);
      final DelayStep opuesta = plan.pasos.firstWhere(
        (DelayStep p) => p.fila == 2 && p.columna == 3,
      );
      expect(opuesta.orden, 6);
    });

    test('el intervalo relativo es el orden menos uno', () {
      final DelayPlan plan = generar(DelayPattern.porTaladros);
      expect(
        plan.pasos.every(
          (DelayStep p) => p.intervaloRelativo == p.orden - 1,
        ),
        isTrue,
      );
    });

    test('cada patron declara direccion y efectos conceptuales', () {
      for (final DelayPattern patron in DelayPattern.values) {
        final DelayPlan plan = generar(patron);
        expect(plan.direccionDesplazamiento.isNotEmpty, isTrue);
        expect(plan.efectoFragmentacion.isNotEmpty, isTrue);
        expect(plan.efectoVibracion.isNotEmpty, isTrue);
        expect(patron.etiqueta.isNotEmpty, isTrue);
        expect(patron.descripcion.isNotEmpty, isTrue);
      }
    });

    test('tolera conteos no validos sin fallar', () {
      final DelayPlan plan = secuenciador.generar(
        patron: DelayPattern.porFilas,
        filas: 0,
        taladrosPorFila: -3,
      );
      expect(plan.totalTaladros, 1);
    });
  });
}
