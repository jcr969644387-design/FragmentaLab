import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/calculators/geometry_calculator.dart';
import 'package:fragmenta_lab/models/blast_design.dart';
import 'package:fragmenta_lab/models/geometry_result.dart';

void main() {
  const GeometryCalculator calc = GeometryCalculator();

  group('Relacion espaciamiento / burden', () {
    test('calcula S/B correctamente', () {
      expect(calc.relacionSobreBurden(3.0, 2.5), closeTo(1.2, 1e-9));
    });

    test('una malla cuadrada tiene S/B igual a 1', () {
      expect(calc.relacionSobreBurden(3.0, 3.0), closeTo(1.0, 1e-9));
    });

    test('devuelve cero si el burden no es valido', () {
      expect(calc.relacionSobreBurden(3.0, 0), 0);
      expect(calc.relacionSobreBurden(3.0, -2), 0);
    });
  });

  group('Area influenciada por taladro', () {
    test('es el producto burden por espaciamiento', () {
      expect(calc.areaPorTaladro(2.5, 3.0), closeTo(7.5, 1e-9));
    });

    test('devuelve cero con dimensiones no validas', () {
      expect(calc.areaPorTaladro(0, 3.0), 0);
      expect(calc.areaPorTaladro(2.5, -1), 0);
    });
  });

  group('Numero total de taladros', () {
    test('multiplica filas por taladros por fila', () {
      expect(calc.totalTaladros(3, 6), 18);
    });

    test('devuelve cero si algun conteo no es valido', () {
      expect(calc.totalTaladros(0, 6), 0);
      expect(calc.totalTaladros(3, -1), 0);
    });
  });

  group('Volumen conceptual', () {
    test('volumen por taladro es B x S x H', () {
      expect(calc.volumenPorTaladro(2.5, 3.0, 8.0), closeTo(60.0, 1e-9));
    });

    test('volumen total escala con el numero de taladros', () {
      final BlastDesign d = BlastDesign.ejemploEducativo().copyWith(
        burdenM: 2.5,
        espaciamientoM: 3.0,
        alturaBancoM: 8.0,
        filas: 3,
        taladrosPorFila: 6,
      );
      final GeometryResult g = calc.calcular(d);
      expect(g.totalTaladros, 18);
      expect(g.volumenPorTaladroM3, closeTo(60.0, 1e-9));
      expect(g.volumenConceptualM3, closeTo(1080.0, 1e-9));
    });
  });

  group('Longitudes', () {
    test('longitud cargada conceptual descuenta el taco', () {
      expect(calc.longitudCargadaConceptual(9.0, 2.5), closeTo(6.5, 1e-9));
    });

    test('longitud cargada nunca es negativa', () {
      expect(calc.longitudCargadaConceptual(2.0, 3.0), 0);
    });

    test('longitud teorica vertical es altura mas subperforacion', () {
      expect(calc.longitudTeorica(10.0, 1.0, 0), closeTo(11.0, 1e-9));
    });

    test('longitud teorica crece con la inclinacion', () {
      final double vertical = calc.longitudTeorica(10.0, 1.0, 0);
      final double inclinada = calc.longitudTeorica(10.0, 1.0, 20);
      expect(inclinada, greaterThan(vertical));
      expect(inclinada, closeTo(10.0 / 0.9396926 + 1.0, 1e-4));
    });
  });

  group('Relaciones adimensionales', () {
    test('expresa una longitud en diametros', () {
      expect(calc.enDiametros(2.67, 89), closeTo(30.0, 1e-2));
    });

    test('esbeltez es longitud sobre burden', () {
      expect(calc.esbeltez(9.0, 3.0), closeTo(3.0, 1e-9));
    });

    test('el calculo completo es consistente con el ejemplo educativo', () {
      final GeometryResult g = calc.calcular(BlastDesign.ejemploEducativo());
      expect(g.relacionSobreBurden, closeTo(3.0 / 2.6, 1e-9));
      expect(g.areaPorTaladroM2, closeTo(7.8, 1e-9));
      expect(g.totalTaladros, 18);
      expect(g.longitudCargadaConceptualM, closeTo(6.5, 1e-9));
      expect(g.longitudTeoricaM, closeTo(8.9, 1e-9));
      expect(g.desviacionLongitudRelativa.abs(), lessThan(0.001));
      expect(g.anchoMallaM, closeTo(15.0, 1e-9));
      expect(g.profundidadMallaM, closeTo(5.2, 1e-9));
    });
  });
}
