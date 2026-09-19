import 'package:flutter_test/flutter_test.dart';
import 'package:fragmenta_lab/calculators/burden_calculator.dart';
import 'package:fragmenta_lab/models/education_config.dart';
import 'package:fragmenta_lab/models/formula_explanation.dart';

void main() {
  final EducationConfig config = EducationConfig.porDefecto();
  final BurdenCalculator calc = BurdenCalculator(config);

  group('Calculo de burden', () {
    test('aplica el coeficiente configurado sobre el diametro', () {
      // 89 mm -> 0.089 m; con k_B = 30 el burden educativo es 2.67 m.
      expect(calc.burdenDesdeDiametro(89), closeTo(2.67, 1e-9));
    });

    test('permite sobrescribir el coeficiente', () {
      expect(calc.burdenDesdeDiametro(89, factor: 25), closeTo(2.225, 1e-9));
    });

    test('rechaza entradas no validas', () {
      expect(calc.burdenDesdeDiametro(0), 0);
      expect(calc.burdenDesdeDiametro(-89), 0);
      expect(calc.burdenDesdeDiametro(89, factor: 0), 0);
    });
  });

  group('Calculo de espaciamiento', () {
    test('aplica la relacion S/B configurada', () {
      expect(calc.espaciamientoDesdeBurden(2.6), closeTo(2.99, 1e-9));
    });

    test('con k_S igual a 1 el espaciamiento iguala al burden', () {
      expect(calc.espaciamientoDesdeBurden(2.6, factor: 1), closeTo(2.6, 1e-9));
    });

    test('rechaza entradas no validas', () {
      expect(calc.espaciamientoDesdeBurden(0), 0);
      expect(calc.espaciamientoDesdeBurden(2.6, factor: -1), 0);
    });
  });

  group('Relacion S/B y factor implicito', () {
    test('la relacion es el cociente de ambas longitudes', () {
      expect(calc.relacionSobreBurden(3.0, 2.5), closeTo(1.2, 1e-9));
    });

    test('el factor implicito recupera el coeficiente usado', () {
      final double burden = calc.burdenDesdeDiametro(89, factor: 28);
      expect(calc.factorImplicito(burden, 89), closeTo(28, 1e-9));
    });
  });

  group('Explicaciones educativas', () {
    test('la explicacion de burden incluye formula, variables y limites', () {
      final FormulaExplanation exp = calc.explicarBurden(89);
      expect(exp.formula, 'B = k_B x D');
      expect(exp.variables.length, 3);
      expect(exp.unidadResultado, 'm');
      expect(exp.resultado, '2.67');
      expect(exp.limitaciones.isNotEmpty, isTrue);
      expect(exp.interpretacion.isNotEmpty, isTrue);
    });

    test('la explicacion de espaciamiento declara sus unidades', () {
      final FormulaExplanation exp = calc.explicarEspaciamiento(2.6);
      expect(exp.formula, 'S = k_S x B');
      expect(
        exp.variables.every((FormulaVariable v) => v.unidad.isNotEmpty),
        isTrue,
      );
    });

    test('la explicacion de la relacion reconoce el rango de referencia', () {
      final FormulaExplanation exp = calc.explicarRelacion(3.0, 2.6);
      expect(exp.unidadResultado, 'adimensional');
      expect(
          exp.interpretacion.contains('rango educativo de referencia'), isTrue);
    });
  });
}
